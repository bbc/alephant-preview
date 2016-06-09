require "spec_helper"

describe Alephant::Preview::Server do
  include Rack::Test::Methods
  let (:app) { subject }

  describe "preview endpoint (GET /preview/{id}/{template}/{region}/{fixture})" do
    describe "content" do
      expected_time = "123456789"

      context "with valid data" do
        before(:each) do
          allow(Time).to receive(:now).and_return(expected_time)

          get "/preview/#{id}/#{template}/#{region}/#{fixture}"
        end
        let (:id) { "foo" }
        let (:template) { id }
        let (:fixture) { id }
        let (:region) { "page_region" }

        it "should return correct response" do
          expect(last_response.body).to eq(%(top{"content":"as json"}bottom\n))
        end

        expected_headers = {
          "Content-Type"                => "application/json",
          "Access-Control-Allow-Origin" => "*",
          "X-Sequence"                  => expected_time,
          "Content-Length"              => "31"
        }

        it "should have correct response headers" do
          expect(last_response.headers).to include(expected_headers)
        end
      end
    end
  end

  describe "component endpoint (GET /component/{id}/{template}/{fixture})" do
    describe "content" do
      expected_time = "123456789"

      before(:each) do
        allow(Time).to receive(:now).and_return(expected_time)

        get "/component/#{id}/#{template}/#{fixture}"
      end
      let (:response) { last_response.body.chomp }

      context "without a data mapper" do
        let (:id) { "foo" }
        let (:template) { id }
        let (:fixture) { id }

        it "should return correct response" do
          expect(response).to eq(%({"content":"as json"}))
        end

        expected_headers = {
          "Content-Type"                => "application/json",
          "Access-Control-Allow-Origin" => "*",
          "X-Sequence"                  => expected_time,
          "Content-Length"              => "21"
        }

        it "should have correct response headers" do
          expect(last_response.headers).to include(expected_headers)
        end
      end

      context "with a data mapper" do
        context "using a single fixture" do
          let (:id) { "bar" }
          let (:template) { id }
          let (:fixture) { id }

          it "should return data mapped content" do
            expect(response).to eq("data mapped content")
          end

          expected_headers = {
            "Content-Type"                => "text/html",
            "Access-Control-Allow-Origin" => "*",
            "X-Sequence"                  => expected_time,
            "Content-Length"              => "20"
          }

          it "should have correct response headers" do
            expect(last_response.headers).to include(expected_headers)
          end
        end

        context "using multiple fixtures" do
          let (:id) { "baz" }
          let (:template) { id }
          let (:fixture) { id }

          it "should return multiple mapped content" do
            expect(response).to eq("multiple endpoint data mapped content")
          end

          expected_headers = {
            "Content-Type"                => "text/html",
            "Access-Control-Allow-Origin" => "*",
            "X-Sequence"                  => expected_time,
            "Content-Length"              => "38"
          }

          it "should have correct response headers" do
            expect(last_response.headers).to include(expected_headers)
          end
        end
      end
    end
  end

  describe 'component batch endpoint (GET /components/batch?components[#{id}]=#{id})' do
    describe "content" do
      expected_time = "123456789"

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
              :body         => %({"content":"as json"}),
              :content_type => "application/json",
              :sequence_id  => expected_time
            }
          ]
        }

        it "should return correct response" do
          expect(response).to eq(expected)
        end
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

          it "should return correct response" do
            expect(response).to eq(expected)
          end
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

          it "should return correct response" do
            expect(response).to eq(expected)
          end
        end
      end
    end
  end

  describe "component batch endpoint (POST /components/batch" do
    describe "content" do
      expected_time = "123456789"

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
              :body         => %({"content":"as json"}),
              :content_type => "application/json",
              :sequence_id  => expected_time
            }
          ]
        }

        it "should return correct response" do
          expect(response).to eq(expected)
        end
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

          it "should return correct response" do
            expect(response).to eq(expected)
          end
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

          it "should return correct response" do
            expect(response).to eq(expected)
          end
        end
      end
    end
  end

  describe "status endpoint (GET /status)" do
    before(:each) do
      get "/status"
    end

    context "status code" do
      it "should return ok status code" do
        expect(last_response.status).to eq(200)
      end
    end
  end
end
