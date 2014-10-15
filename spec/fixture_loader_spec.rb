require 'spec_helper'

describe Alephant::Preview::FixtureLoader do
  let (:base_path) { File.join(File.dirname(__FILE__), 'fixtures', 'components', 'bar') }
  let (:fixture_data) { File.open(File.join(File.dirname(__FILE__), 'fixtures', 'components', 'bar', 'fixtures', 'bar.json')).read }
  subject { described_class.new(base_path) }

  describe ".new" do

    context 'using valid parameters' do
      let (:expected) { described_class }

      specify { expect(subject).to be_a expected }
    end
  end

  describe "#get" do
    let (:uri) { '/test/uri' }

    context 'with a single fixture' do
      specify { expect(subject.get(uri).body).to eq fixture_data}
    end

    context 'with multiple fixtures' do
      let (:base_path) { File.join(File.dirname(__FILE__), 'fixtures', 'components', 'baz') }
      let (:fixture_data) do
        fixtures = Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', 'components', 'baz', 'fixtures', '*'))
        fixtures.map { |fixture| File.open(fixture).read }
      end

      it "should return each fixture on subsequent calls" do
        (0..2).each do |index|
          expect(subject.get(uri).body).to eq fixture_data[index]
        end
      end

    end

  end


end
