require "json"

class BazMapper < Alephant::Publisher::Request::DataMapper
  def data
    (1..3).reduce({}) do |accum, index|
      accum.merge(
        JSON.parse(
          get("/test/call").body
        )
      )
    end
  end
end
