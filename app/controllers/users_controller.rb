class UsersController < ApplicationController
#  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

  def index
    @users = User.all.order("created_at DESC")
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @user.build_profile if @user.profile.nil?
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to user_path(@user), notice: "修改成功"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, profile_attributes: [:id, :kind, :url, :_destroy])
  end
end
