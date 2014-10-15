module Alephant
  module Preview
    class FixtureLoader
      attr_reader :base_path, :current_fixture, :fixtures

      def initialize(base_path)
        @base_path = base_path
        @fixtures  = Dir.glob("#{base_path}/fixtures/*")
      end

      def get(uri)
        OpenStruct.new(
          :status => 200,
          :body   => fixture
        )
      end

      protected

      def fixture
        path = fixtures.shift
        raise "There isn't a fixture matching the request call, please add one" if path.nil?
        File.open(path).read
      end

    end
  end
end
