class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy, :following, :followers]
  before_action :find_user, only: [:show, :edit, :update, :destroy, :follow, :unfollow, :following, :followers]

  def index
    @users = User.all.order('created_at DESC')
  end

  def show
    @profiles = @user.profiles
    @images = @user.images
    @keywords = @user.keywords
  end

  def edit
    @user_photo = if @user.user_photo.present?
                    @user.user_photo
                  else
                    @user.build_user_photo
                  end
  end

  def update
    if @user.update(user_params)
      redirect_to user_path(@user)
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def follow
    unless current_user.is_following?(@user)
      current_user.follow!(@user)
      flash[:notice] = 'follow!'
    end
    redirect_to user_path(@user)
  end

  def unfollow
    if current_user.is_following?(@user)
      current_user.unfollow!(@user)
      flash[:alert] = 'unfollowed！'
    end
    redirect_to user_path(@user)
  end

  def following
    @title = 'Following'
    @users = @user.following.page(1).per(5)
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @users = @user.followers.page(1).per(5)
    render 'show_follow'
  end

  private

  def user_params
    params.require(:user).permit(:name, user_photo_attributes: [:image, :id])
  end

  def find_user
    @user = User.find(params[:id])
  end
end
