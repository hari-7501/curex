require 'redis'

class RedisService
  DEFAULT_EXPIRY = 5.minutes

  def self.client
    @client ||= Redis.new(url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'))
  end

  def self.set(key, value, ttl: nil)
    ttl ? client.setex(key, ttl, value) : client.set(key, value)
  end

  def self.get(key)
    client.get(key)
  end

  def self.delete(key)
    client.del(key)
  end

  def self.exists?(key)
    client.exists?(key)
  end

  def self.increment(key)
    client.incr(key)
  end

  def self.with_prefix(prefix, key)
    "#{prefix}:#{key}"
  end

  def self.hset(key, hash)
    client.hmset(key, *hash.to_a.flatten)
  end

  def self.hget(key, field)
    client.hget(key, field)
  end

  def self.hgetall(key)
    client.hgetall(key)
  end

  def self.expire(key, ttl = DEFAULT_EXPIRY)
    client.expire(key, ttl)
  end
end
