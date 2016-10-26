class Account::MyEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @events = current_user.events.order("created_at DESC")
  end

  def show
    @event = current_user.events.find(params[:id])
    @members = @event.members
  end

  def kickout
    @event = current_user.events.find(params[:event_id])
    user = User.find(params[:user_id])
    user.quit!(@event)
    redirect_to account_my_event_path(@event)
  end

  private

  def event_params
    params.require(:event).permit(:topic, :start_time, :end_time, :location, :content, :is_active, :photo, :event_id, :user_id)
  end

  def quit
    @event = Event.find(params[:id])
      if current_user.is_member_of?(@event)
        current_user.quit!(@event)
        flash[:alert] = "你已取消報名本活動！"
      else
        flash[:warning] = "你沒有報名本活動，怎麼取消 XD"
      end
    redirect_to event_path(@event)
  end
end
