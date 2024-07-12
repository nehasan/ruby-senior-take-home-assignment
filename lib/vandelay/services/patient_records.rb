require 'faraday'
require 'json'
require 'vandelay/integrations/api'

module Vandelay
  module Services
    class PatientRecords
      def retrieve_record_for_patient(patient)
        return { "error_message": "Error fetching patient records!" } if patient.nil?

        records = patient.records_vendor == 'one' ?
                    Vandelay::Integrations::Api.fetch_api_one_record(patient) : 
                    Vandelay::Integrations::Api.fetch_api_two_record(patient)
      end
    end
  end
end