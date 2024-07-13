ENV['APP_ENV'] = 'test'
require_relative '../../server'
require_relative '../spec_helper'
require 'rspec'
require 'rack/test'
require 'json'

RSpec.describe "Vendor Records", type: :request do
  include Rack::Test::Methods

  def app
    RESTServer
  end

  context "Patient records retrieval from vendor" do

    it "api retrieves patients record from vendor one api" do
      get '/patients/2/record'

      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['records']['province']).to eq('QC')
      expect(JSON.parse(last_response.body)['records']['allergies'].class.to_s).to eq('Array')
      expect(JSON.parse(last_response.body)['records']['allergies'][2]).to eq('conformity')
      expect(JSON.parse(last_response.body)['records']['recent_medical_visits']).to eq(1)
    end

    it "fails to retrieve patient unavailable at db" do
      get '/patients/5/record'

      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['records']).to eq(nil)
      expect(JSON.parse(last_response.body)['message']).to eq('patient with id 5 is not available!')
    end

    it "fails to retrieve patient from vendor due to vendor name missing" do
      get '/patients/1/record'

      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)['records']).to eq(nil)
      expect(JSON.parse(last_response.body)['message']).to eq("vendor records data is missing for this patient!")
    end
  end
  
end