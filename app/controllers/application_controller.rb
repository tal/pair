class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_user_from_fb_cookie

private
  
  def get_user_from_fb_cookie
    str = cookies[Rails.fb_app.cookie_name].try(:gsub,"\"",'')
    fb_params =  str ? URL::ParamsHash.from_string(str) : {}

    if Rails.fb_app.valid_params?(fb_params)
      u = User[fb_params[:uid]]
    elsif fb_params[:uid]
      u = User[fb_params[:uid]]
    end

    logger.fatal fb_params.pretty_inspect

    if u
      request.user = u
    end
  end

end
