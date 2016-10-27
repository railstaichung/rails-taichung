class KeywordsController < ApplicationController
  before_action :find_user, except: [:show]

  def show
    @keyword = Keyword.find(params[:id])
    @title = @keyword.content
    @keywordable = Keyword.where(content: @keyword.content)
  end

  def new
    @keyword = @user.keywords.new
  end

  def create
    # TODO: 如果重覆不新增?!
    @keyword = @user.keywords.build(keyword_params)
    if @keyword.save
      redirect_to user_path(@user)
    else
      render :new
    end
  end

  def destroy
    @keyword = @user.keywords.find(params[:id])

    @keyword.destroy
    redirect_to user_path(@user)
  end

  private

  def keyword_params
    params.require(:keyword).permit(:content)
  end

  def find_user
    @user = User.find(params[:user_id])
  end
end
