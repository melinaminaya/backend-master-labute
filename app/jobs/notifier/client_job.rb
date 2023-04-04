# frozen_string_literal: true

module Notifier
  class ClientJob < ApplicationJob
    queue_as :default

    def perform(notification, data = nil, ids = nil)
      @ids = ids
      @data = data
      @notification = notification
      send_notification
    end

    private

    def send_notification
      notification = data
      mount_destinations(notification)
      notification[:data] = @data unless @data.nil?
      conn = Faraday.new(url: 'https://fcm.googleapis.com/fcm/send')
      conn.post do |req|
        req.headers['Authorization'] = "key=#{ENV['FCM_TOKEN']}"
        req.headers['Content-Type'] = 'application/json'
        req.body = notification.to_json
      end
    end

    # rubocop:disable Metrics/MethodLength
    def data
      {
        notification: {
          sound: 'default',
          click_action: 'FCM_PLUGIN_ACTIVITY',
          icon: 'fcm_push_icon',
          title: @notification[:title],
          body: @notification[:body],
          color: '#0A3E85'
        },
        collapse_key: 'labute',
        priority: 'high',
        restricted_package_name: ENV['CLIENT_APP_PACKAGE']
      }
    end
    # rubocop:enable Metrics/MethodLength

    def mount_destinations(notification)
      if @ids.nil?
        notification[:to] = '/topics/all'
      else
        notification[:registration_ids] = @ids
      end
      notification
    end
  end
end
