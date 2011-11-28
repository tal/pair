class GetFriends
  @queue = :get_friends
  attr_reader :fb_uid

  def initialize fb_uid
    @fb_uid = fb_uid
  end

  def user
    @user ||= User[fb_uid]
  end

  def validate_user!
    unless user.andand.fb_session
      raise UnknownUser, @fb_uid.to_s
    end

    if user.fb_session.expired?
      raise ExpiredSession, "#{@fb_uid.to_s} expired by #{Time.now - user.fb_session.expires}s"
    end

    true
  end

  def set_friends!
    validate_user!

    user.fb_info.friend_ids = friend_ids
    user.save!
  end

  def friends_url
    @url ||= URL.new("https://graph.facebook.com/#{@fb_uid}/friends").tap do |url|
      url[:access_token] = user.fb_session.access_token
    end
  end

  def friends_hash
    friends_url.get.json.andand['data']
  end

  def friend_ids
    friends_hash.collect do |friend|
      friend['id']
    end
  end

  class << self
    def perform fb_uid
      ff = new(fb_uid)

      ff.set_friends!
    end

    def enqueue fb_uid
      Resque.enqueue self, fb_uid
    end
  end


  class InvalidUser < StandardError; end
  class UnknownUser < InvalidUser; end
  class ExpiredSession < InvalidUser; end
end
