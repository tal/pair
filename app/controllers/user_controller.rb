class UserController < ApplicationController

  def login
    if params[:fb_session]
      fbs = FbSession.new(params[:fb_session])
      unless u = User[fbs.uid]
        u = u.new
      end
      u.fb_session = fbs
    end

    if u && u.save
      request.user = u
      # respond_to do |format|
      #   format.json { render json: request.user }
      #   format.html { redirect_to root_path }
      # end
      resp = {success: true, user: u}
      render json: resp
    else
      render json: {success:false, errors: u.try(:errors), user: u}
    end
  end

  def logout
    if request.user
      session.delete(:user_id)
    end

    # respond_to do |format|
    #   format.json { render json: {success: true} }
    #   format.html { redirect_to root_path }
    # end
    render json: {success: true}
  end

end
