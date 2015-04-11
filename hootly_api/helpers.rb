require 'sinatra/base'
require 'json'
#require 'apns'
require 'pushmeup'

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

      def real_user?(user_id, client)
         user_check = !client.query("SELECT * FROM Users WHERE id = '#{user_id}'").first.nil?
         return user_check
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
      APNS.host = 'gateway.push.apple.com'
      APNS.pem = 'push_certs/ck.pem'
      APNS.pass = 'Lorraine42'

      GCM.key = "AIzaSyANiPVXok3rf5HaGC507jLD_sDomQhdQhc"

      def hoot_vote_activity(post_id, client)
         hoot = client.query("SELECT * FROM Hoots WHERE id = '#{post_id}'").first
         user = client.query("SELECT * FROM Users WHERE id = '#{hoot['user_id']}'").first

         return if user.nil?

         device_token = user['device_token']
         return if device_token.nil?

         client.query("Update Users SET notifications = notifications + 1 WHERE id = '#{hoot['user_id']}'")
         notification_count = user['notifications']
         return if notification_count.nil?

         last_notification = user['last_notification']
         last_notification = 0 if last_notification.nil?
         return if Time.now.to_i - last_notification <= NOTIFICATION_THRESHOLD

         # 'person' if 1 'people' if multiple
         person_people = 'person has'
         person_people = 'people have' if hoot['votes'] > 1

         alert = "#{hoot['votes']} #{person_people} voted on your Hoot!"

         if user['device_type'] == "iOS"
            APNS.send_notification(device_token, :badge => notification_count, :alert => alert, :sound => SOUND, :other => {:hoot_id => hoot['id']})
         end
         if user['device_type'] == "android"
            data = { :alert => alert } 
            GCM.send_notification(device_token, data)
         end
         client.query("UPDATE Users SET last_notification = #{Time.now.to_i} WHERE id = '#{user['id']}'")
      end

      def comment_vote_activity(comment_id, client)
         comment = client.query("SELECT * FROM Comments WHERE id = '#{comment_id}'").first
         user = client.query("SELECT * FROM Users WHERE id = '#{comment['user_id']}'").first

         return if user.nil?

         device_token = user['device_token']
         return if device_token.nil?

         last_notification = user['last_notification']
         last_notification = 0 if last_notification.nil?
         return if Time.now.to_i - last_notification <= NOTIFICATION_THRESHOLD

         client.query("Update Users SET notifications = notifications + 1 WHERE id = '#{user['id']}'")
         notification_count = user['notifications']
         return if notification_count.nil?

         person_people = 'person has'
         person_people = 'people have' if comment['votes'] > 1

         alert = "#{comment['votes']} #{person_people} voted on your Comment!"
         if user['device_type'] == "iOS"
            APNS.send_notification(device_token, :alert => alert, :badge => notification_count, :sound => SOUND, :other => {:hoot_id => comment['post_id']})
         end
         if user['device_type'] == "android"
            data = { :alert => alert } 
            GCM.send_notification(device_token, data)
         end

         client.query("UPDATE Users SET last_notification = #{Time.now.to_i} WHERE id = '#{user['id']}'")
      end

      def reply_activity(post_id, client)
         hoot = client.query("SELECT * FROM Hoots WHERE id = '#{post_id}'").first
         user = client.query("SELECT * FROM Users WHERE id = '#{hoot['user_id']}'").first
         return if user.nil?

         client.query("Update Users SET notifications = notifications + 1 WHERE id = '#{user['id']}'")

         comments = client.query("SELECT * FROM Comments WHERE post_id = '#{post_id}'")
         comment_count = comments.count
         device_token = user['device_token']
         return if device_token.nil?

         person_people = 'person has'
         person_people = 'people have' if comment_count > 1
         comment_alert = "#{comment_count} #{person_people} replied to your Comment!"

         comment_device_tokens = {}
         comment_device_tokens[device_token] = true
         comments.each do |comment|
            client.query("Update Users SET notifications = notifications + 1 WHERE id = '#{comment['user_id']}'")
            device_info = client.query("SELECT device_token, notifications, device_type FROM Users WHERE id = '#{comment['user_id']}'").first
            c_device_token = device_info['device_token']
            notification_count = device_info['notifications']
            device_type = device_info['device_type']
            if !c_device_token.nil? and comment_device_tokens[c_device_token].nil? and !device_type.nil?
               if device_type == "iOS"
                  APNS.send_notification(c_device_token, :alert => comment_alert, :badge => notification_count, :sound => SOUND, :other => {:hoot_id => hoot['id']})
               end
               if device_type == "android"
                  data = {:alert => comment_alert}  
                  GCM.send_notification(c_device_token, data)
               end
            end
            comment_device_tokens[c_device_token] = true
         end


         notification_count = user['notifications']
         alert = "#{comment_count} #{person_people} replied to your Hoot!"
         if user['device_type'] == "iOS" 
            APNS.send_notification(device_token, :alert => alert, :badge => notification_count, :sound => SOUND, :other => {:hoot_id => hoot['id']})
         end
         if user['device_type'] == "android"
            data = { :alert => alert } 
            GCM.send_notification(device_token, data)
         end
      end
   end
   helpers ParameterCheck, ParameterEscape, PushNotifications
end
