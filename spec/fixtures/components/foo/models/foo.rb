require "alephant/renderer/views/json"

module MyApp
  class Foo < ::Alephant::Renderer::Views::Json
    def to_h
      { "content" => "as json" }
    end
  end
end
