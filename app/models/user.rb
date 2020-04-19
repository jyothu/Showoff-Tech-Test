class User
  REDIS_KEY = "users".freeze

  class << self
    def create(params)
      email = params[:email] || params['email']

      params.each do |key, value|
        redis.hset("#{REDIS_KEY}:#{email}", key, value)
      end
    end

    def find_by_email(email)
      redis.hgetall("#{REDIS_KEY}:#{email}")
    end

    private

    def redis
      @redis ||= Redis.new
    end
  end
end
