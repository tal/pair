class FbSession
  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :user

  field :uid
  field :access_token
  field :expires, type: Integer
  field :base_domain
  field :secret
  field :session_key
  field :sig
end
