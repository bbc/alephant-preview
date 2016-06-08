require "spec_helper"

describe Alephant::Preview::Server do
  include Rack::Test::Methods
  let (:app) { subject }

  describe "preview endpoint (GET /preview/{id}/{template}/{region}/{fixture})" do
    describe "content" do
      expected_time = 123_456_789

      context "with valid data" do
        before(:each) do
          allow(Time).to receive(:now).and_return(expected_time)

          get "/preview/#{id}/#{template}/#{region}/#{fixture}"
        end
        let (:id) { "foo" }
        let (:template) { id }
        let (:fixture) { id }
        let (:region) { "page_region" }

        specify { expect(last_response.body).to eq("top{\"content\":\"as json\"}bottom\n") }

        expected_headers = {
          "Content-Type"                => "application/json",
          "Access-Control-Allow-Origin" => "*",
          "X-Sequence"                  => expected_time,
          "Content-Length"              => "31",
          "X-Content-Type-Options"      => "nosniff"
        }

        specify { expect(last_response.headers).to eq(expected_headers) }
      end
    end
  end

  describe "component endpoint (GET /component/{id}/{template}/{fixture})" do
    describe "content" do
      expected_time = 123_456_789

      before(:each) do
        allow(Time).to receive(:now).and_return(expected_time)

        get "/component/#{id}/#{template}/#{fixture}"
      end
      let (:response) { last_response.body.chomp }

      context "without a data mapper" do
        let (:id) { "foo" }
        let (:template) { id }
        let (:fixture) { id }

        specify { expect(response).to eq("{\"content\":\"as json\"}") }

        expected_headers = {
          "Content-Type"                => "application/json",
          "Access-Control-Allow-Origin" => "*",
          "X-Sequence"                  => expected_time,
          "Content-Length"              => "21",
          "X-Content-Type-Options"      => "nosniff"
        }

        specify { expect(last_response.headers).to eq(expected_headers) }
      end

      context "with a data mapper" do
        context "using a single fixture" do
          let (:id) { "bar" }
          let (:template) { id }
          let (:fixture) { id }

          specify { expect(response).to eq("data mapped content") }

          expected_headers = {
            "Content-Type"                => "text/html",
            "Access-Control-Allow-Origin" => "*",
            "X-Sequence"                  => expected_time,
            "Content-Length"              => "20",
            "X-XSS-Protection"            => "1; mode=block",
            "X-Content-Type-Options"      => "nosniff",
            "X-Frame-Options"             => "SAMEORIGIN"
          }

          specify { expect(last_response.headers).to eq(expected_headers) }
        end

        context "using multiple fixtures" do
          let (:id) { "baz" }
          let (:template) { id }
          let (:fixture) { id }

          specify { expect(response).to eq("multiple endpoint data mapped content") }

          specify { expect(last_response.headers["Content-Type"]).to eq("text/html") }

          expected_headers = {
            "Content-Type"                => "text/html",
            "Access-Control-Allow-Origin" => "*",
            "X-Sequence"                  => expected_time,
            "Content-Length"              => "38",
            "X-XSS-Protection"            => "1; mode=block",
            "X-Content-Type-Options"      => "nosniff",
            "X-Frame-Options"             => "SAMEORIGIN"
          }

          specify { expect(last_response.headers).to eq(expected_headers) }
        end
      end
    end
  end

  describe 'component batch endpoint (GET /components/batch?components[#{id}]=#{id})' do
    describe "content" do
      expected_time = 123_456_789

      before(:each) do
        allow(Time).to receive(:now).and_return(expected_time)

        get "/components/batch?components[#{id}][component]=#{id}&components[#{id}][options][fixture]=#{id}"
      end

      let (:response) { JSON.parse(last_response.body.chomp, :symbolize_names => true) }

      context "without a data mapper" do
        let (:id) { "foo" }
        let (:template) { id }
        let (:fixture) { id }

        expected = {
          :components => [
            {
              :component    => "foo",
              :options      => {},
              :status       => 200,
              :body         => "{\"content\":\"as json\"}",
              :content_type => "application/json",
              :sequence_id  => expected_time
            }
          ]
        }

        specify { expect(response).to eq(expected) }
      end

      context "with a data mapper" do
        context "using a single fixture" do
          let (:id) { "bar" }
          let (:template) { id }
          let (:fixture) { id }

          expected = {
            :components => [
              {
                :component    => "bar",
                :options      => {},
                :status       => 200,
                :body         => "data mapped content\n",
                :content_type => "text/html",
                :sequence_id  => expected_time
              }
            ]
          }

          specify { expect(response).to eq(expected) }
        end

        context "using multiple fixtures" do
          let (:id) { "baz" }
          let (:template) { id }
          let (:fixture) { id }

          expected = {
            :components => [
              {
                :component    => "baz",
                :options      => {},
                :status       => 200,
                :body         => "multiple endpoint data mapped content\n",
                :content_type => "text/html",
                :sequence_id  => expected_time
              }
            ]
          }

          specify { expect(response).to eq(expected) }
        end
      end
    end
  end

  describe "component batch endpoint (POST /components/batch" do
    describe "content" do
      expected_time = 123_456_789

      before(:each) do
        allow(Time).to receive(:now).and_return(expected_time)

        post "/components/batch", {
          :components => [
            {
              :component => id,
              :options   => {
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
              :component    => "foo",
              :options      => {},
              :status       => 200,
              :body         => "{\"content\":\"as json\"}",
              :content_type => "application/json",
              :sequence_id  => expected_time
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
                :component    => "bar",
                :options      => {},
                :status       => 200,
                :body         => "data mapped content\n",
                :content_type => "text/html",
                :sequence_id  => expected_time
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
                :component    => "baz",
                :options      => {},
                :status       => 200,
                :body         => "multiple endpoint data mapped content\n",
                :content_type => "text/html",
                :sequence_id  => expected_time
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
