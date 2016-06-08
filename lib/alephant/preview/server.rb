require "alephant/renderer/views/html"
require "alephant/renderer/views/json"
require "alephant/renderer/view_mapper"
require "alephant/publisher/request/data_mapper_factory"
require "alephant/publisher/request/data_mapper"
require "alephant/publisher/request/error"

require "alephant/support/parser"
require "alephant/preview/fixture_loader"
require "alephant/preview/template/base"

require "sinatra/base"
require "sinatra/reloader"
require "faraday"
require "json"
require "uri"

module Alephant
  module Preview
    class Server < Sinatra::Base
      set :bind, "0.0.0.0"

      register Sinatra::Reloader
      also_reload "components/*/models/*.rb"
      also_reload "components/*/mapper.rb"
      also_reload "components/shared/mappers/*.rb"

      BASE_LOCATION = "#{(ENV['BASE_LOCATION'] || Dir.pwd)}/components".freeze

      before do
        response["Access-Control-Allow-Origin"] = "*"
      end

      get "/preview/:id/:template/:region/?:fixture?" do
        response["X-Sequence"] = Time.now.to_i

        render_preview
      end

      get "/component/:template/?:fixture?" do
        params["id"] = find_id_from_template params["template"]
        params["fixture"] = "responsive" unless params["fixture"]

        response["X-Sequence"] = Time.now.to_i

        render_component
      end

      get "/component/:id/:template/?:fixture?" do
        response["X-Sequence"] = Time.now.to_i

        render_component
      end

      get "/components/batch" do
        batch_components = []

        get_batched_components.each do |component|
          component = component[1]
          options = component.fetch("options", {})
          params["template"] = component.fetch("component")
          params["id"] = find_id_from_template params["template"]
          params["fixture"] = options.fetch("fixture", "responsive") || "responsive"
          batch_components << render_batch_component
        end

        { :components => batch_components }.to_json
      end

      post "/components/batch" do
        batch_components = []

        post_batched_components.each do |component|
          options = symbolize component.fetch(:options, {})
          params["template"] = component.fetch(:component)
          params["id"] = find_id_from_template params["template"]
          params["fixture"] = options.fetch(:fixture, "responsive") || "responsive"
          batch_components << render_batch_component
        end

        { :components => batch_components }.to_json
      end

      get "/status" do
        "ok"
      end

      not_found do
        "Not found"
      end

      def find_id_from_template(template)
        files = Dir.glob(BASE_LOCATION + "/**/models/*")
        file = files.select! { |file| file.include? "/#{template}.rb" }.pop

        halt(404) if file.nil?

        result = /#{BASE_LOCATION}\/(\w+)/.match(file)
        result[1]
      end

      def render_preview
        Template::Base.new(
          { region => render_component },
          preview_template_location
        ).render
      end

      def render_component
        view_mapper.generate(fixture_data)[template].render.tap do |content|
          response["Content-Type"] = get_content_type(content)
        end
      end

      def render_batch_component
        content = render_component

        {
          :component    => template,
          :options      => {},
          :status       => 200,
          :body         => content,
          :content_type => get_content_type(content),
          :sequence_id  => Time.now.to_i
        }
      end

      private

      def get_content_type(content)
        if is_json?(content)
          "application/json"
        else
          "text/html"
        end
      end

      def is_json?(content)
        JSON.parse(content)
        true
      rescue Exception => e
        false
      end

      def request_body
        JSON.parse(request.body.read, :symbolize_names => true) || {}
      end

      def query_string
        Rack::Utils.parse_nested_query(request.query_string)
      end

      def post_batched_components
        request_body.fetch(:components, [])
      end

      def get_batched_components
        query_string.fetch("components", [])
      end

      def model
        require model_location
        Alephant::Renderer::Views.get_registered_class(template).new(fixture_data)
      end

      def base_path
        File.join(BASE_LOCATION, id)
      end

      def model_location
        File.join(base_path, "models", "#{template}.rb")
      end

      def template
        params["template"]
      end

      def region
        params["region"]
      end

      def id
        params["id"]
      end

      def fixture
        params["fixture"] || id
      end

      def fixture_data
        if File.exist? "#{base_path}/mapper.rb"
          loader              = Alephant::Preview::FixtureLoader.new(base_path)
          data_mapper_factory = Alephant::Publisher::Request::DataMapperFactory.new(loader, BASE_LOCATION)
          begin
            data_mapper_factory.create(id, params).data
          rescue Alephant::Publisher::Request::InvalidApiResponse
            raise "The JSON passed to the data mapper isn't valid"
          rescue StandardError => e
            puts e.backtrace
            raise "There was an issue with the data mapper class: #{e.message}"
          end
        else
          msg = Struct.new(:body)
                      .new(raw_fixture_data)
          parser.parse msg
        end
      end

      def raw_fixture_data
        File.open(fixture_location).read
      end

      def parser
        @parser ||= ::Alephant::Support::Parser.new
      end

      def fixture_location
        "#{base_path}/fixtures/#{fixture}.json"
      end

      def preview_template_location
        "#{Template.path}/templates/preview.mustache"
      end

      def view_mapper
        Alephant::Renderer::ViewMapper.new(id, BASE_LOCATION)
      end

      def symbolize(hash)
        Hash[hash.map { |k, v| [k.to_sym, v] }]
      end
    end
  end
end
