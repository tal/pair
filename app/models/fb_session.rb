class FbSession
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :user

  def fb_info
    user.fb_info
  end

  before_save do
    fb_info.uid = uid
  end

  def populate_facebook_friends
    key = friends_key # so it doesn't have to call method over and over

    REDIS.multi do
      get_friend_ids.each do |fbid|
        REDIS.sadd key, fbid
      end
    end
  end

  def get_facebook_friends
    u = URL.new("https://graph.facebook.com/#{uid}/friends")
    u[:access_token] = access_token
    resp = u.get.json
    resp['data'] # only supports up to 5000 friends
  end

  def get_friend_ids
    get_facebook_friends.collect do |friend|
      friend['id']
    end
  end

  def is_friends_with fbid
    REDIS.sismember friends_key, fbid
  end

  def friends_key
    "fb:#{uid}:friends"
  end

  field :uid
  field :access_token
  field :expires, type: Integer
  field :base_domain
  field :secret
  field :session_key
  field :sig

end
