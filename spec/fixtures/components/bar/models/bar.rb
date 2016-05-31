require "alephant/renderer/views/html"

module MyApp
  class Bar < ::Alephant::Renderer::Views::Html
    def content
      data.bar
    end
  end
end
