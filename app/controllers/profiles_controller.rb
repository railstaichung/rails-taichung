class ProfilesController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @profile = @user.profiles.new
  end

  def create
    @user = User.find(params[:user_id])
    @profile = @user.profiles.build(profile_params)
    if @profile.save
      redirect_to user_path(@user), notice: "新增連結成功！"
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @profile = @user.profiles.find(params[:id])
  end

  def update
    @user = User.find(params[:user_id])
    @profile = @user.profiles.find(params[:id])
    if @profile.update(profile_params)
      redirect_to user_path(@user), notice: "連結修改成功！"
    else
      render :edit
    end
  end

  def destroy
    @user = User.find(params[:user_id])
    @profile = @user.profiles.find(params[:id])

    @profile.destroy
    redirect_to user_path(@user), alert: "連結已刪除成功！"
  end

  private

  def profile_params
    params.require(:profile).permit(:content, :url)
  end

end
