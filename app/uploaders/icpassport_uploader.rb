class IcpassportUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :fog

  def store_dir
    if Rails.env.production?
      "identitycards"
    else
      "test"
    end
  end

  process resize_to_fill: [960, 540]
  process watermark: [Rails.root.join('app/assets/images/watermark_icpassport.png')]

  def watermark(path_to_file)
    manipulate! do |img|
      img = img.composite(MiniMagick::Image.open(path_to_file), "jpg") do |c|
        c.gravity "NorthWest"
      end
    end
  end

  def extension_whitelist
    %w(jpg jpeg png)
  end

  def filename
    "#{model.ezi_id}-#{secure_token}.#{file.extension}" if original_filename
  end

  def fog_public
    true
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
