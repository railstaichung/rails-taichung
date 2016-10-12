class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :edit, :update, :destroy, :following, :followers]

  def index
    @users = User.all.order("created_at DESC")
  end

  def show
    @user = User.find(params[:id])
    @profiles = @user.profiles
    @images = @user.images
  end

  def edit
    @user = User.find(params[:id])
    if @user.user_photo.present?
      @user_photo = @user.user_photo
    else
      @user_photo = @user.build_user_photo
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end

  def follow
    @user = user.find(params[:id])
      if !current_user.is_following?(@user)
        current_user.follow!(@user)
        flash[:notice] = "follow!"
      end
    redirect_to user_path(@user)
  end

  def unfollow
    @user = user.find(params[:id])
      if current_user.is_following?(@user)
        current_user.unfollow!(@user)
        flash[:alert] = "unfollowed！"
      end
    redirect_to user_path(@user)
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.page(1).per(5)
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.page(1).per(5)
    render 'show_follow'
  end


  private

  def user_params
    params.require(:user).permit(:name, user_photo_attributes: [:image, :id])
  end


end
