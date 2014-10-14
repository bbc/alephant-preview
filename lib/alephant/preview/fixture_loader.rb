module Alephant
  module Preview
    class FixtureLoader
      attr_reader :fixture

      def initialize(fixture)
        @fixture = fixture
      end

      def get(uri)
        OpenStruct.new(
          :status => 200,
          :body   => fixture
        )
      end
    end
  end
end
