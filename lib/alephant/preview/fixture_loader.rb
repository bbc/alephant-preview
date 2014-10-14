module Alephant
  module Preview
    class FixtureLoader
      attr_accessor :fixture

      def initialize(fixture)
        @fixture = fixture
      end

      def get(uri)
        fixture
      end
    end
  end
end
