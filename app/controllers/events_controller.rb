class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :edit, :create, :update, :destroy]

  def join
    @event = Event.find(params[:id])
      if !current_user.is_member_of?(@event)
        current_user.join!(@event)
        flash[:notice] = "活動報名成功！"
      else
        flash[:warning] = "你無法重複報名本活動了！"
      end
    redirect_to event_path(@event)
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


  def index
    @events = Event.all.order("created_at DESC")
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.create(event_params)

    if @event.save
      current_user.join!(@event)
      redirect_to event_path(@event), notice: "建立活動成功"
    else
      render :new
    end
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
      redirect_to event_path(@event), notice: "活動修改成功"
    else
      render :edit
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    @event.destroy
    redirect_to events_path, alert: "活動已刪除"
  end

  private

  def event_params
    params.require(:event).permit(:topic, :start_time, :end_time, :location, :content)
  end
end
