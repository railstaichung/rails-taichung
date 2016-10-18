class IssuesController < ApplicationController
  def index
    @issues = Issue.includes(:owner)
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = current_user.issues.new(issue_params)
    if @issue.save then
      redirect_to issue_path(@issue)
    else
      render :new
    end
  end

  private
  def issue_params
    params.require(:issue).permit(:title, :content)
  end
end
