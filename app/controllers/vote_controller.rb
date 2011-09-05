class VoteController < ItemGroupController

  def new
    if @current_vote
      redirect_to votes_url(group_key:@current_vote.group_key,item1:@current_vote.item1,item2:@current_vote.item2)
    else
      render :text => 'Fuck'
    end
  end

  def show
    if params[:item1].to_i > params[:item2].to_i
      redirect_to(vote_item_path(item1:params[:item2],item2:params[:item1]))
    end

    if params[:item1].to_i == params[:item2].to_i
      redirect_to(new_vote_path)
    end

    @item1 = @item_class.where(_id:params[:item1].to_i).first
    @item2 = @item_class.where(_id:params[:item2].to_i).first

    if request.user
      @vote = request.user.find_vote(@item1,@item2)
    else
      @vote = Vote.new
      @vote.add_item(@item1,@item2)
    end
  end

  def choose
    success = if params[:choose] == 'skip'
      @current_vote.skip!
    else
      @choose = @item_class.where(_id:params[:choose].to_i).first
      @current_vote.picked! @choose
    end

    if success
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @current_vote }
      end
    else
      respond_to do |format|
        format.html do
          @item1 = @item_class.where(_id:params[:item1].to_i).first
          @item2 = @item_class.where(_id:params[:item2].to_i).first

          @vote = request.user.find_vote(@item1,@item2)
          render action: "show"
        end
        format.json { render json: @current_vote.errors, status: :unprocessable_entity }
      end
    end
  end

end
