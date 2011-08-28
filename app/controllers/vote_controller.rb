class VoteController < ItemGroupController

  def show
    @item1 = @item_class.find(params[:item1].to_i)
    @item2 = @item_class.find(params[:item2].to_i)
  end

end
