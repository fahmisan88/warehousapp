CarrierWave.configure do |config|
  config.fog_provider = 'fog-aws'                        # required
  config.fog_credentials = {
    provider:              'AWS',                        # required
    aws_access_key_id:     ENV['AWS_ACCESS_KEY_ID'],                        # required
    aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],                        # required
    region:                ENV['AWS_REGION'],                  # optional, defaults to 'us-east-1'
    host:                  'static-content.nyc3.digitaloceanspaces.com',             # optional, defaults to nil
    endpoint:              ENV['AWS_ENDPOINT'] # optional, defaults to nil
  }
  config.fog_directory  = ENV['S3_BUCKET_NAME']                          # required                                       # optional, defaults to true
  config.fog_attributes = { cache_control: "public, max-age=#{30.day.to_i}" } # optional, defaults to {}
end
