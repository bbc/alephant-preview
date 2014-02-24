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
    context 'valid component' do
      it "should return the rendered component" do
        get '/component/foo/foo/foo'

        expect(last_response).to be_ok
        expect(last_response.body).to eq("content\n")
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
