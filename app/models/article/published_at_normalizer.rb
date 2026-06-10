class Article
  class PublishedAtNormalizer
    def self.call(value, now: Time.current)
      new(value, now).call
    end

    def initialize(value, now)
      @value = value
      @now   = now
    end

    def call
      return @value if @value.blank?

      if date_without_time?
        with_current_time(@value)
      elsif string?
        normalize_string
      elsif midnight_time?
        with_current_time(@value)
      else
        @value
      end
    end

    private

    def date_without_time?
      @value.is_a?(Date) && !@value.is_a?(Time)
    end

    def string?
      @value.is_a?(String)
    end

    def midnight_time?
      @value.respond_to?(:hour) && @value.hour == 0 && @value.min == 0 && @value.sec == 0
    end

    def normalize_string
      parsed = Time.zone.parse(@value) rescue nil
      return @value unless parsed

      if parsed.hour == 0 && parsed.min == 0 && parsed.sec == 0
        with_current_time(parsed)
      else
        parsed.in_time_zone
      end
    end

    def with_current_time(date_value)
      Time.zone.local(
        date_value.year, date_value.month, date_value.day,
        @now.hour, @now.min, @now.sec
      )
    end
  end
end
