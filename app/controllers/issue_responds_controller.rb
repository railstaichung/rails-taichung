class IssueRespondsController < ApplicationController
  before_action :find_issue
  def create
    @respond = @issue.responds.build(respond_params)
    @respond.user = current_user
    if @respond.save then
      redirect_to issue_path(@issue), notice: "建立回應成功"
    end
  end

  def up_vote
    @respond = @issue.responds.find(params[:issue_respond_id])
    @respond.update_columns(vote: @respond.vote + 1)
    @respond.save
    vote = @respond.votes.new
    vote.user = current_user
    vote.vote_num = 1
    vote.save
    redirect_to issue_path(@issue)
  end

  def down_vote
    @respond = @issue.responds.find(params[:issue_respond_id])
    @respond.update_columns(vote: @respond.vote - 1)
    @respond.save
    vote = @respond.votes.new
    vote.user = current_user
    vote.vote_num = -1
    vote.save
    redirect_to issue_path(@issue)
  end

  private
  def find_issue
    @issue = Issue.find(params[:issue_id])
  end
  def respond_params
    params.require(:issue_respond).permit(:content)
  end
end
