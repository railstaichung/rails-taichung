class Account::MyEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = current_user.events.order("created_at DESC")
  end

  def show
    @event = current_user.events.find(params[:id])
    @members = @event.members
  end

  private

  def event_params
    params.require(:event).permit(:topic, :start_time, :end_time, :location, :content, :is_active, event_photo_attributes: [:image, :id])
  end
end
