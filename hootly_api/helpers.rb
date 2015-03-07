require 'sinatra/base'
require 'json'

module Sinatra
   module ParameterCheck

      def check_params(parameters)
         error = ""
         parameters.each do |parameter|
            if params[parameter].nil?
               error = error + "#{parameter} is nil. "
            end
         end
         if !error.empty?
            return error.to_json
         end

         return ""
      end
   end

   module ParameterEscape
      # Pass the parameters and the database client
      def escape_params(parameters, client)
         parameters.each do |parameter|
            params[parameter] = client.escape(params[parameter])
         end
      end
   end
   helpers ParameterCheck, ParameterEscape
end
