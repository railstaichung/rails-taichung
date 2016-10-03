class UsersController < ApplicationController
#  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

  def index
    @users = User.all.order("created_at DESC")
  end

  def show
    @user = User.find(params[:id])
    @profiles = @user.profiles
  end

end
