class BazMapper < Alephant::Publisher::Request::DataMapper
  def data
    (1..3).reduce({}) do |accum, index|
      accum.merge(get("/test/call"))
    end
  end
end
