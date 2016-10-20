class IssuesController < ApplicationController
  def index
    @issues = Issue.includes(:owner).page params[:page]
  end

  def show
    @issue = Issue.find(params[:id])
    @issue_responds = @issue.responds.includes(:user).order('vote DESC, created_at')
    @respond = @issue.responds.build
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

  def issue_close
    @issue = Issue.find(params[:id])
    @issue.close_issue!
    redirect_to :back
  end

  def issue_reopen
    @issue = Issue.find(params[:id])
    @issue.reopen_issue!
    redirect_to :back
  end

  private
  def issue_params
    params.require(:issue).permit(:title, :content)
  end
end
