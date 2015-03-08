require 'sinatra/base'
require 'json'
require 'apns'

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

   module DatabaseUtils
      def get_user(user_id)
         client.query("SELECT * FROM Users WHERE id = '#{user_id}'").first
      end

      def get_hoot(hoot_id)
         client.query("SELECT * FROM Hoots WHERE id = '#{hoot_id}'").first
      end
   end

   module PushNotifications
      # 15 minutes = 15 * 60 seconds
      NOTIFICATION_THRESHOLD = 15 * 60
      BADGE = 1
      SOUND = 'default'
      APNS.pem = 'push_certs/ck.pem'
      APNS.pass = 'LorraineCucumber42'
      def hoot_vote_activity(post_id, client)
         hoot = client.query("SELECT * FROM Hoots WHERE id = '#{post_id}'").first
         user = client.query("SELECT * FROM Users WHERE id = '#{hoot['user_id']}'").first

         return if user.nil?

         device_token = user['device_token']
         return if device_token.nil?


         last_notification = user['last_notification']
         last_notification = 0 if last_notification.nil?
         return if Time.now.to_i - last_notification <= NOTIFICATION_THRESHOLD

         # 'person' if 1 'people' if multiple
         person_people = 'person has'
         person_people = 'people have' if hoot['votes'] > 1

         alert = "#{hoot['votes']} #{person_people} voted on your Hoot"
         APNS.send_notification(device_token, :alert => alert, :sound => SOUND, :other => {:hoot_id => hoot['id']})
         client.query("UPDATE Users SET last_notification = #{Time.now.to_i} WHERE id = '#{user['id']}'")
      end

      def comment_vote_activity(comment_id, poster_id, client)
      end

      def reply_activity(post_id, user_id, client)
      end
   end
   helpers ParameterCheck, ParameterEscape, PushNotifications
end
