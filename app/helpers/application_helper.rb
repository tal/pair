module ApplicationHelper
  def classes_for_item item, vote = nil
    vote ||= @vote
    cla = []
    if vote && vote.include?(item)
      if vote == @current_vote
        cla << 'voteable' unless vote.completed?
        cla << 'current'
      end

      if vote.skipped?
        cla << 'skipped'
      elsif vote.completed?
        cla << 'completed'
        cla << (vote.winner_id == item.id ? 'winner' : 'loser')
      end
    end

    cla << (vote ? 'has-vote' : 'no-vote')

    cla.join(' ')
  end

  def visible item
    return unless request.user && item.respond_to?(:user)
    item.user == request.user
  end

  def if_visible item, &blk
    if visible item
      blk.call
    end
  end

  def item_stats &blk
    if visible(@item_group) && controller_name == "items"
      blk.call
    end
  end
end
