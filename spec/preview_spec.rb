require 'spec_helper'

describe Alephant::Preview::Server do
  include Rack::Test::Methods

  def app
    Alephant::Preview::Server
  end

  describe '/preview/:id/:template/:region/?:fixture?' do
    context 'valid component' do
      it "should return the rendered component inside the page region specified" do
        get '/preview/foo/foo/page_region/foo'

        expect(last_response).to be_ok
        expect(last_response.body).to eq("topcontent\nbottom\n")
      end
    end
  end

  describe '/component/:id/:template/?:fixture?' do
    let (:id) { 'foo' }
    let (:template) { 'foo' }
    let (:fixture) { 'foo' }
    before(:each) do
      get "/component/#{id}/#{template}/#{fixture}"
    end

    describe 'content' do
      context 'without data mapper' do
        specify { expect(last_response.body.chomp).to eq("content") }
      end

      context 'with data mapper' do
        let (:id) { 'bar' }
        let (:template) { 'bar' }
        let (:fixture) { 'bar' }
        before(:each) do
          get "/component/#{id}/#{template}/#{fixture}"
        end
        specify { expect(last_response.body.chomp).to eq("data mapped content") }
      end
    end
  end

  describe '/status' do
    it "responds with ok" do
      get '/status'

      expect(last_response).to be_ok
      expect(last_response.body).to eq('ok')
    end
  end
end
