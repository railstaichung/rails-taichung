class IssueRespondsController < ApplicationController
  before_action :find_issue
  def create
    @respond = @issue.responds.build(respond_params)
    @respond.user = current_user
    if @respond.save then
      redirect_to issue_path(@issue), notice: I18n.t('respond_success')
      IssuePostManJob.perform_later(@issue.id)
    end
  end

  def edit
    @respond = IssueRespond.find(params[:id])
  end

  def update
    @respond = @issue.responds.find(params[:id])
    @respond.update(respond_params)
    if @respond.save then
      redirect_to issue_path(@issue)
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
