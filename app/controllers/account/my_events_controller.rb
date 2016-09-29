class Account::MyEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = current_user.events.order("created_at DESC")
  end
end
