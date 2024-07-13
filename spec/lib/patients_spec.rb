ENV['APP_ENV'] = 'test'
require_relative '../../server'
require_relative '../spec_helper'
require 'rspec'
require 'rack/test'
require 'json'

RSpec.describe "Patients", type: :request do
  include Rack::Test::Methods

  def app
    RESTServer
  end

  context "Patient retrieval endpoints" do

    it "retrieves all patients available in the db" do
      get '/patients'

      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body).class.to_s).to eq('Array')
      # expect(JSON.parse(last_response.body)['patient']['full_name']).to eq('Elaine Benes')
    end

    it "retrieves a patient based on an id provided" do
      get '/patients/1'

      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['patient']['id']).to eq('1')
      expect(JSON.parse(last_response.body)['patient']['full_name']).to eq('Elaine Benes')
    end

    it "fails to retrieve patient with unavailable id" do
      get '/patients/5'

      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['message']).to eq("patient not available with id 5!")
      expect(JSON.parse(last_response.body)['patient']).to eq(nil)
    end
  end

end
