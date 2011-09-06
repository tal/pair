class ItemsController < ItemGroupController
  
  # GET /items
  # GET /items.json
  def index
    @items = @item_group.item_class.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items }
    end
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = @item_group.item_class.find(params[:id].to_i)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/new
  # GET /items/new.json
  def new
    @item = @item_group.item_class.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = @item_group.item_class.find(params[:id].to_i)
  end

  # POST /items
  # POST /items.json
  def create
    @item = @item_group.item_class.new(params[:item])
    respond_to do |format|
      if @item.save
        # format.html { redirect_to @item, notice: 'Item was successfully created.' }
        format.html { redirect_to "/#{@item_group.key}" }
        format.json { render json: @item, status: :created, location: @item }
      else
        format.html { render action: "new" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.json
  def update
    @item = @item_group.item_class.find(params[:id].to_i)

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to item_path(id:@item.id,group_key:@item.group_key), notice: 'Item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item = @item_group.item_class.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
      format.json { head :ok }
    end
  end

end
