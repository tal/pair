class ItemGroupController < ApplicationController
  before_filter :get_item_group

  private

  def get_item_group
    @item_group = ItemGroup[params[:group_key]]

    redirect_to(:root) unless @item_group
    
    @item_class = @item_group.item_class
    @current_vote = request.user.get_or_create_vote(@item_group.key)
  end
end
