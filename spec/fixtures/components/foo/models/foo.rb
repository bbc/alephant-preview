require "alephant/renderer/views/html"

module MyApp
  class Foo < ::Alephant::Renderer::Views::Html
    def content
      "content"
    end
  end
end
