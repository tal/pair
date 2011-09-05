module RailsExt
  def dev?
    env == 'development'
  end

  def fb_app
    configuration.fb_app
  end
end

Rails.extend RailsExt
