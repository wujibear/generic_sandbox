Geocoder.configure(
  # street address geocoding service (default :nominatim)
  lookup: :google,
  use_https: true,
  api_key: Rails.application.credentials.google.api_key,

  # IP address geocoding service (default :ipinfo_io)
  # ip_lookup: :maxmind,

  # to use an API key:

  # geocoding service request timeout, in seconds (default 3):
  timeout: 10_000,

  # set default units to kilometers:
  units: :km,

  # caching (see Caching section below for details):
  cache: Redis.new,
  cache_options: {
    expiration: 1.month # Defaults to `nil`
    # prefix: 'another_key:' # Defaults to `geocoder:`
  }
)
