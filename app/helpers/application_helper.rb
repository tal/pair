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

  def aditional_item_info item, opts={}, &blk
    mytag = begin
      opts |= {}
      if item.youtube?
        u = URL.new("http://www.youtube.com/embed/#{item.detect_type[1]}")
        u[:autohide] = 1
        u[:theme] = 'dark'
        u[:color] = 'white'
        opts |= {class: 'item-content youtube', frameborder: 0}
        opts[:src] = u.to_s
        content_tag :iframe, '', opts
      elsif item.image?
        tag 'img', src: item.value, class: 'item-content image'
      end
    end

    if block_given? && mytag
      yield(mytag)
    else
      mytag
    end
  end

  def og_tags
    props = {}
    props['fb:app_id'] = Rails.fb_app.id

    if controller_name == "items" && @item && !@item.new?
      props['og:type'] = Rails.fb_app.namespace + ':answer'
      props["og:url"] = item_url(@item, group_key: @item.group_key)
      props['og:title'] = @item.value
      props['og:description'] = "In asnwer to the question: "<<@item.item_group.description
      props['og:image'] = @item.fb_image
      props["#{Rails.fb_app.namespace }:question"] = item_group_url(@item.item_group)
    elsif controller_name == 'item_groups' && @item_group && !@item_group.new?
      props['og:type'] = Rails.fb_app.namespace + ':question'
      props["og:url"] = url_for(@item_group)
      props['og:title'] = @item_group.description
      props['og:image'] = 'https://s-static.ak.fbcdn.net/images/devsite/attachment_blank.png'
    end
    
    props.collect do |property, content|
      tag 'meta', property:property, content:content
    end.join("\n").html_safe
  end
end
