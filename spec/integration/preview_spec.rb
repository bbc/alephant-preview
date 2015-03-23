require 'spec_helper'

describe Alephant::Preview::Server do
  include Rack::Test::Methods
  let (:app) { subject }

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

  describe "status endpoint (GET /status)" do
    before(:each) do
      get "/status"
    end

    context "status code" do
      specify { expect(last_response.status).to eq 200 }
    end
  end
end
