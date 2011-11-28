class FbInfo
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :user

  field :uid
  field :friend_ids, type:Array, default:[]

  before_save :update_uid

  def friends_with user
    return unless user.fb_info.uid

    friend_ids.include? user.fb_info.uid
  end

  def update_uid
    self.uid = user.fb_session.andand.uid
  end
end