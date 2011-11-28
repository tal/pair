class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_user_from_fb_cookie

private
  
  def require_user
    unless request.user
      redirect_to root_path
    end
  end
    
  def get_user_from_fb_cookie
    str = cookies[Rails.fb_app.cookie_name].try(:gsub,"\"",'')
    fb_params =  str ? URL::ParamsHash.from_string(str) : {}

    raise Rails.fb_app.valid_params?(fb_params).to_s + "\n"*4 + fb_params.inspect

    if Rails.fb_app.valid_params?(fb_params)
      u = User[fb_params[:uid]]
    elsif fb_params[:uid]
      u = User[fb_params[:uid]]
    else
      # u = User.first
      u = User.all.to_a.last
    end

    request.user = u if u
  end

end
