class ActionDispatch::Request

  def user
    @user ||= User.find('4e592a9958c6ba6031000001')
  end

end
