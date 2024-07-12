require 'redis'

module Vandelay
  module Util
    class Cache
      # your code here
      def initialize
        @redis = nil
      end

      def self.redis
        # @redis ||= Redis.new(host: '0.0.0.0', port: '6387')
        redis_url = 'redis://redis:6379'
        @redis ||= Redis.new(url: redis_url)
        connected?
        @redis
      end

      def self.connected?
        @redis.setex('hello', 30, 1) == 'OK' ? true : false
      end
    end
  end
end
