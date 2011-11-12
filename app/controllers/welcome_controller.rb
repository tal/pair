class WelcomeController < ApplicationController
  def index
    @featured_votes = if request.user
      Setting.featured_questions.collect do |q|
        request.user.get_or_create_vote(q.key).tap.instance_variable_set :@item_group, q
      end
    else
      Setting.featured_questions.collect do |q|
        q.dummy_vote.tap.instance_variable_set :@item_group, q
      end
    end

  end

end
