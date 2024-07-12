require 'faraday'
require 'json'
require 'vandelay/util/cache'
require 'byebug'

module Vandelay
  module Integrations
    class Api
      # Retrieves patient records from API one
      def self.fetch_api_one_record(patient)
        vendor_id = patient.vendor_id
        base_url = Vandelay::config['integrations']['vendors']['one']['api_base_url']
        records = {}

        # fetch the records from the cache if the redis server has saved
        records = fetch_cache(patient)

        return extracted_records(records) if !records.nil?
        
        # Access the auth token first to make final api call
        resToken = Faraday.get(
          "http://#{base_url}/auth/1",
          { "Accept": 'application/json' }
        )

        auth_token = JSON.parse(resToken.body)['token']
        puts "--- retrieved auth token: #{auth_token}"

        return { 
          "error_message": "Authorization error fetching patient records from API one!"
        } if auth_token.nil?
        
        # Fetch final records for the patient
        resRecord = Faraday.get(
          "http://#{base_url}/patients/#{vendor_id}",
          {
            "Accept": 'application/json',
            "Authorization": "Bearer #{auth_token}"
          }
        )

        records = JSON.parse(resRecord.body)
        # puts "--- retrieved records: #{records}"

        # store the information to cache for future use
        cache_records(patient, records)

        extracted_records(records)
      end

      # Retrieves patient records from API two
      def self.fetch_api_two_record(patient)
        vendor_id = patient.vendor_id
        base_url = Vandelay::config['integrations']['vendors']['two']['api_base_url']
        records = {}

        # fetch the records from the cache if the redis server has saved
        records = fetch_cache(patient)

        return extracted_records(records) if !records.nil?

        # Access the auth token first to make final api call
        resToken = Faraday.get(
          "http://#{base_url}/auth_tokens/1",
          { "Accept": 'application/json' }
        )

        auth_token = JSON.parse(resToken.body)['token']
        # puts "--- retrieved auth token: #{auth_token}"

        return { 
          "error_message": "Authorization error fetching patient records from API two!"
        } if auth_token.nil?

        # Fetch final records for the patient
        resRecord = Faraday.get(
          "http://#{base_url}/records/#{vendor_id}",
          {
            "Accept": 'application/json',
            "Authorization": "Bearer #{auth_token}"
          }
        )

        records = JSON.parse(resRecord.body)
        # puts "--- retrieved records: #{records}"

        # store the information to cache for future use
        cache_records(patient, records)

        extracted_records(records)
      end

      def self.fetch_cache(patient)
        redisCache = Vandelay::Util::Cache.redis
        cachedRecords = redisCache.get("#{patient.vendor_id}")
        puts "--- retrived from cache: #{cachedRecords}"
        return cachedRecords.nil? ? nil : JSON.parse(cachedRecords)
      end

      def self.cache_records(patient, records)
        redisCache = Vandelay::Util::Cache.redis

        redisCache.setex(
          "#{patient.vendor_id}", # should be a base64 hash
          60,                     # expired after 10 mins
          records.to_json
        )
      end

      def self.extracted_records(data)
        # byebug
        data.slice("id", "province", "allergies", "num_medical_visits")
      end
    end
  end
end