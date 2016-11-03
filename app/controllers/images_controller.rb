class ImagesController < ApplicationController
  before_action :find_user

  def new
    @image = @user.images.new
  end

  def create
    @image = @user.images.build(image_params)
    if @image.save
      redirect_to user_path(@user), notice: '圖片已新增成功！'
    else
      render :new
    end
  end

  def destroy
    @image = @user.images.find(params[:id])

    @image.destroy
    redirect_to user_path(@user), alert: '圖片已刪除成功！'
  end

  private

  def image_params
    params.require(:image).permit(:url)
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
