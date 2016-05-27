require "alephant/renderer/views/html"

module MyApp
  class Baz < ::Alephant::Renderer::Views::Html
    def content
      "#{data.a} #{data.b} #{data.c}"
    end
  end
end
