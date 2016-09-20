class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :destroy]

  def index
    @events = Event.all.order("created_at DESC")
  end

  def new
    @event = Event.new
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit
    @event = current_user.events.find(params[:id])
  end

  def update
    @event = current_user.events.find(params[:id])

    if @event.update(event_params)
      redirect_to event_path(@event)
    else
      render :edit
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    @event.destroy
    redirect_to events_path
  end

  private

  def event_params
    params.require(:event).permit(:topic, :start_time, :end_time, :location, :owner, :content)
  end
end
