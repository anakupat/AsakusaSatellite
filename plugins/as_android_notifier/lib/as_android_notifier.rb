# -*- encoding: utf-8 -*-
require 'asakusa_satellite/hook'
class AsakusaSatellite::Hook::ASAndroidNotifier < AsakusaSatellite::Hook::Listener

  def after_create_message(context)
    return if ENV["ANDROID_MAIL_ADDRESS"].nil? or ENV["ANDROID_PASSWORD"].nil? or ENV["ANDROID_APPLICATION_NAME"].nil?

    message = context[:message]
    room = context[:room]

    text = "#{message.user.name} / #{message.body}"[0,150]

    members = room.owner_and_members - [ message.user ]
    devices = members.map {|user|
      user.devices
    }.flatten

    android = devices.select {|device|
      device.device_type == 'android'
    }

    AsakusaSatellite::AsyncRunner.run do
      begin
        android.to_a.map{|device|
          { :registration_id => device.name,
            :data => {
              :message => text,
              :id => room.id
            }
          }
        }.tap{|xs|
          C2DM.send_notifications(ENV["ANDROID_MAIL_ADDRESS"],
            ENV["ANDROID_PASSWORD"],
            xs,
            ENV["ANDROID_APPLICATION_NAME"])
        }
      rescue => e
        Rails.logger.error e
      end
    end

  end

end
