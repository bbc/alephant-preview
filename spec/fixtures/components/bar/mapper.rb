class BarMapper < Alephant::Publisher::Request::DataMapper
  def data
    {
      :bar => "data mapped content"
    }
  end
end
