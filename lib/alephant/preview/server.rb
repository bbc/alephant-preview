require 'alephant/models/render_mapper'
require 'alephant/models/parser'

require 'alephant/preview/template/base'

require 'sinatra/base'
require 'faraday'
require 'json'
require 'uri'

module Alephant
  module Preview
    class Server < Sinatra::Base

      get '/preview/:id/:template/:region/?:fixture?' do
        render_preview
      end

      get '/component/:id/:template/?:fixture?' do
        render_component
      end

      def render_preview
        Template::Base.new(
          { region => render_component },
          preview_template_location
        ).render
      end

      def render_component
        ::Alephant::RenderMapper.new(id, base_path).create_renderer(template_file, fixture_data).render
      end

      private
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
        parser.parse raw_fixture_data
      end

      def raw_fixture_data
        File.open(fixture_location).read
      end

      def parser
        @parser ||= Parser.new
      end

      def base_path
        "#{Dir.pwd}/components"
      end

      def fixture_location
        "#{base_path}/#{id}/fixtures/#{fixture}.json"
      end

      def preview_template_location
        "#{Template.path}/templates/preview.mustache"
      end
    end
  end
end
