class AppConfig < ActiveRecord::Base
  class << self
    def [](key)
      pair = find_by_key(key)
      pair.value unless pair.nil?
    end

    def []=(key, value)
      pair = find_by_key(key)
      unless pair
        pair = new
        pair.key, pair.value = key, value
        pair.save
      else
        pair.value = value
        pair.save
      end
      value
    end

    def to_hash
      Hash[ *all.map { |pair| [pair.key, pair.value] }.flatten ]
    end
  end
end
