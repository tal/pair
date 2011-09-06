class ActionDispatch::Request

  def user
    @user #||= User.where(_id: session[:user_id]).first
  end

  def user=u
    # session[:user_id] = u.id
    @user = u
  end

end
