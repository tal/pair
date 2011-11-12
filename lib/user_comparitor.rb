class UserComparitor
  def initialize user
    @user = user
  end

  def everyone user
    true
  end

  def me user
    user == @user
  end

  def friend user
    @user.fb_info.friends_with user
  end

  def method_missing method, user
    everyone(user)
  end

  module Mongoid
    module ClassMethods
      private
      
      def user_can verb, opts = {}
        opts |= {default: 'everyone'}
        can_verb = :"can_#{verb}"
        field can_verb, default: opts[:default]

        define_method "user_can_#{verb}" do |user|
          user_comparitor.send(send(can_verb), user)
        end
      end

    end
    
    module InstanceMethods
      def user_comparitor
        @user_comparitor ||= UserComparitor.new(user)
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end

end
