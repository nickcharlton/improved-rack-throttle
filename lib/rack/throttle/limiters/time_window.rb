module Rack; module Throttle
  ##
  class TimeWindow < Limiter
    ##
    # Returns `true` if fewer than the maximum number of requests permitted
    # for the current window of time have been made.
    #
    # @param  [Rack::Request] request
    # @return [Boolean]
    def allowed?(request)
      count = cache_get(key = cache_key(request)).to_i + 1 rescue 1
      allowed = count <= max_per_window.to_i
      begin
        cache_set(key, count)
        allowed
      rescue => e
        allowed = true
      end
    end

    ##
    # Returns headers containing values following the X-RateLimit convention.
    #
    # @param [Rack::Request] request
    # @param [Hash{String => String}] headers
    # @return [Hash{String => String}]
    def rate_limit_headers(request, headers)
      count = cache_get(cache_key(request)).to_i rescue 1
      remaining = [0, max_per_window - count].max

      headers['X-RateLimit-Limit'] = max_per_window.to_s
      headers['X-RateLimit-Remaining'] = remaining.to_s
      headers
    end
  end
end; end
