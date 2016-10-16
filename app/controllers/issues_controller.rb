class IssuesController < ApplicationController
  def index
    @issues = Issue.includes(:owner)
  end
  def show
    @issue = Issue.find(params[:id])
  end
end
