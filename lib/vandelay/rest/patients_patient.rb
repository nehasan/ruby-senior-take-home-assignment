require 'vandelay/services/patients'
require 'vandelay/services/patient_records'

module Vandelay
  module REST
    module PatientsPatient
      def self.patients_srvc
        @patients_srvc ||= Vandelay::Services::Patients.new
      end

      def self.patients_records_srvc
        @patients_records_srvc ||= Vandelay::Services::PatientRecords.new
      end
      
      def self.registered(app)
        # add endpoint code here
        app.get '/patients/:id' do
          # puts "--- params #{params[:id]}"
          patient_id = params[:id]
          patient = Vandelay::REST::PatientsPatient.patients_srvc.retrieve_one(patient_id)
          if patient.nil?
            json({ "error_message": "patient not available with id #{patient_id}" })
          else
            json({ "patient": patient })
          end
        end

        app.get '/patients/:id/record' do
          puts "--- params #{params[:id]}"
          # Fetch the patient first
          patient_id = params[:id]
          patient = Vandelay::REST::PatientsPatient.patients_srvc.retrieve_one(patient_id)
          record = nil

          if patient.nil?
            # Return patient not available message to client
            json({ "error_message": "patient with id #{patient_id} is not available!" })
          elsif patient.records_vendor.nil?
            # Return vendor spec not available message to client
            json({ "error_message": "vendor records data is missing for this patient!" })
          else
            # Fetch the patient records from the vendor and return to client
            records = Vandelay::REST::PatientsPatient.
                        patients_records_srvc.
                        retrieve_record_for_patient(patient)
            json({ "records": records })
          end
        end
      end
    end
  end
end
