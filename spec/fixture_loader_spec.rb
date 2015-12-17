require 'spec_helper'

describe Alephant::Preview::FixtureLoader do
  let (:fixtures_base) { File.join(File.dirname(__FILE__), 'fixtures') }
  let (:base_path) { File.join(fixtures_base, 'components', 'bar') }
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
      let (:fixture_data) { File.open(File.join(fixtures_base, 'components', 'bar', 'fixtures', 'bar.json')).read }
      specify { expect(subject.get(uri).body).to eq fixture_data}
    end

    context 'with multiple fixtures' do
      let (:base_path) { File.join(fixtures_base, 'components', 'baz') }
      let (:fixture_data) do
        fixtures = Dir.glob(File.join(fixtures_base, 'components', 'baz', 'fixtures', '*'))
        fixtures.map { |fixture| File.open(fixture).read }
      end

      context 'using a valid amount of fixtures' do

        it "should return each fixture on subsequent calls" do
          (0..2).each do |index|
            expect(subject.get(uri).body).to eq fixture_data[index]
          end
        end
      end

      context "using incorrect amount of fixtures" do
        it "should raise an exception" do
          (0..2).each { |index| subject.get(uri).body }
          expect do
            subject.get(uri).body
          end.to raise_error(
            RuntimeError, "There isn't a fixture matching the request call, please add one"
          )
        end
      end
    end
  end
end
