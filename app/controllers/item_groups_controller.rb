class ItemGroupsController < ApplicationController
  before_filter :require_user, only: [:mine, :edit, :new, :create, :update]

  # GET /questions
  # GET /questions.json
  def index
    @item_groups = ItemGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @item_groups }
    end
  end

  def mine
    @item_groups = ItemGroup.where(:user_id => request.user.id).all

    respond_to do |format|
      format.html { render :index }
      format.json { render json: @item_groups }
    end
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @item_group = ItemGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @item_group }
    end
  end

  # GET /questions/new
  # GET /questions/new.json
  def new
    @item_group = ItemGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @item_group }
    end
  end

  # GET /questions/1/edit
  def edit
    @item_group = ItemGroup.find(params[:id])
    redirect_to root_path unless @item_group.user == request.user
  end

  # POST /questions
  # POST /questions.json
  def create
    @item_group = ItemGroup.new(params[:item_group])
    @item_group.user = request.user

    respond_to do |format|
      if @item_group.save
        format.html { redirect_to items_path(group_key:@item_group.key), notice: 'Question was successfully created.' }
        format.json { render json: @item_group, status: :created, location: @item_group }
      else
        format.html { render action: "new" }
        format.json { render json: @item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.json
  def update
    @item_group = ItemGroup.find(params[:id])
    redirect_to root_path unless @item_group.user == request.user

    respond_to do |format|
      if @item_group.update_attributes(params[:item_group])
        format.html { redirect_to items_path(group_key:@item_group.key), notice: 'Question was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @item_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @item_group = ItemGroup.find(params[:id])
    redirect_to root_path unless @item_group.user == request.user
    @item_group.destroy

    respond_to do |format|
      format.html { redirect_to item_groups_path }
      format.json { head :ok }
    end
  end
end
