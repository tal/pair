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
end
