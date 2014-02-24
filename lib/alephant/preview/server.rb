require 'alephant/renderer'
require 'alephant/views'

require 'alephant/support/parser'

require 'alephant/preview/template/base'

require 'sinatra/base'
require 'faraday'
require 'json'
require 'uri'

module Alephant
  module Preview
    class Server < Sinatra::Base

      BASE_LOCATION = "#{(ENV['BASE_LOCATION'] || Dir.pwd)}/components"

      get '/preview/:id/:template/:region/?:fixture?' do
        render_preview
      end

      get '/component/:id/:template/?:fixture?' do
        render_component
      end

      get '/status' do
        'ok'
      end

      def render_preview
        Template::Base.new(
          { region => render_component },
          preview_template_location
        ).render
      end

      def render_component
        ::Alephant::Renderer.create(template, base_path, model).render
      end

      private
      def model
        require model_location
        ::Alephant::Views.get_registered_class(template).new(fixture_data)
      end

      def base_path
        File.join(BASE_LOCATION, id)
      end

      def model_location
        File.join(base_path, 'models', "#{template}.rb")
      end

      def template
        params['template']
      end

      def region
        params['region']
      end

      def id
        params['id']
      end

      def fixture
        params['fixture'] || id
      end

      def fixture_data
        msg = Struct.new(:body)
          .new(raw_fixture_data)
        parser.parse msg
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
    end
  end
end
