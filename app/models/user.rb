class User
  include Mongoid::Document
  field :current_vote, type: Hash, default:{}
end
