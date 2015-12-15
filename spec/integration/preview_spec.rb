require 'spec_helper'

describe Alephant::Preview::Server do
  include Rack::Test::Methods
  let (:app) { subject }

  describe 'preview endpoint (GET /preview/{id}/{template}/{region}/{fixture})' do

    describe 'content' do

      context 'with valid data' do
        before(:each) do
          get "/preview/#{id}/#{template}/#{region}/#{fixture}"
        end
        let (:id) { 'foo' }
        let (:template) { id }
        let (:fixture) { id }
        let (:region) { 'page_region' }

        specify { expect(last_response.body).to eq("topcontent\nbottom\n") }
      end
    end
  end

  describe 'component endpoint (GET /component/{id}/{template}/{fixture})' do

    describe 'content' do
      before(:each) do
        get "/component/#{id}/#{template}/#{fixture}"
      end
      let (:response) { last_response.body.chomp }

      context 'without a data mapper' do
        let (:id) { 'foo' }
        let (:template) { id }
        let (:fixture) { id }

        specify { expect(response).to eq("content") }
      end

      context 'with a data mapper' do

        context 'using a single fixture' do
          let (:id) { 'bar' }
          let (:template) { id }
          let (:fixture) { id }

          specify { expect(response).to eq("data mapped content") }
        end

        context 'using multiple fixtures' do
          let (:id) { 'baz' }
          let (:template) { id }
          let (:fixture) { id }

          specify { expect(response).to eq("multiple endpoint data mapped content") }
        end
      end
    end
  end

  describe "component batch endpoint (POST /components/batch" do

    describe "content" do
      before(:each) do
        post "/components/batch", {
          :components => [
            {
              :component => id,
              :options => {
                :fixture => id
              }
            }
          ]
        }.to_json
      end

      let (:response) { JSON.parse(last_response.body.chomp, :symbolize_names => true) }

      context "without a data mapper" do
        let(:id) { "foo" }

        expected = {
          :components => [
            {
              :component => "foo",
              :options => {},
              :status => 200,
              :body => "content\n"
            }
          ]
        }

        specify { expect(response).to eq(expected) }
      end

      context "with a data mapper" do

        context "using a single fixture" do
          let (:id) { "bar" }

          expected = {
            :components => [
              {
                :component => "bar",
                :options => {},
                :status => 200,
                :body => "data mapped content\n"
              }
            ]
          }

          specify { expect(response).to eq(expected) }
        end

        context "using multiple fixtures" do
          let (:id) { "baz" }

          expected = {
            :components => [
              {
                :component => "baz",
                :options => {},
                :status => 200,
                :body => "multiple endpoint data mapped content\n"
              }
            ]
          }

          specify { expect(response).to eq(expected) }
        end
      end
    end
  end

  describe "status endpoint (GET /status)" do
    before(:each) do
      get "/status"
    end

    context "status code" do
      specify { expect(last_response.status).to eq 200 }
    end
  end
end
