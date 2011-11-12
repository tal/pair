class FbInfo
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :user

  field :uid
  field :friend_ids, type:Array, default:[]

  def friends_with user
    return unless user.fb_info.uid

    friend_ids.include? user.fb_info.uid
  end
end