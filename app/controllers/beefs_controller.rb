class BeefsController < ApplicationController

  def index
    if params[:tag]
      @beefs = Beef.tagged_with(params[:tag]).order("created_at DESC").page params[:page]
    else
      @beefs = Beef.includes(:user).order("created_at DESC").page params[:page]
    end
  end

  def new
    @beef = Beef.new
  end

  def create
    @beef = Beef.new(beef_params)
    @beef.user = current_user
    if @beef.save
      redirect_to beefs_path
    else
      render :new
    end
  end
  def create_from_event
    @beef = Beef.new(beef_params)
    @beef.user = current_user
    @beef.event = Event.find(params[:event_id])
    if @beef.save
      redirect_to beefs_path
    else
      render :new
    end
  end
  def show
    @beef = Beef.find(params[:id])
  end

  def edit
    @beef = Beef.find(params[:id])
  end

  def update
    @beef = Beef.find(params[:id])

    if @beef.update(beef_params)
      redirect_to beefs_path, notice: '修改資源成功！'
    else
      render :edit
    end
  end

  def destroy
    @beef = Beef.find(params[:id])
    @beef.destroy
      redirect_to beefs_path, alert: '資源已刪除！'
  end



  private

  def beef_params
    params.require(:beef).permit(:title, :description, :tag_list, :event_id)
  end

end
