class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:to_active, :to_close, :join, :quit, :new, :edit, :create, :update, :destroy]

  def to_active
    @event = current_user.events.find(params[:id])
    @event.to_active
    flash[:notice] = "活動激活！"
    redirect_to account_my_event_path
  end

  def to_close
    @event = current_user.events.find(params[:id])
    @event.to_close
    flash[:notice] = "活動關閉！"
    redirect_to account_my_event_path
  end

  def active
    @events = Event.where(:is_active => 't').all.order("created_at DESC")
  end

  def close
    @events = Event.where(:is_active => 'f').all.order("created_at DESC")
  end

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
    @event_photo = @event.build_event_photo
  end

  def create
    @event = current_user.events.create(event_params)

    if @event.start_time > @event.end_time
      flash[:warning] = "開始時間錯誤"
      render :new
    else
      if @event.save
        current_user.join!(@event)
        redirect_to event_path(@event), notice: "建立活動成功"
      else
        render :new
      end
    end
  end

  def show
    @event = Event.find(params[:id])
    @hash = Gmaps4rails.build_markers(@event) do |event, marker|
      marker.lat event.latitude
      marker.lng event.longitude
      marker.infowindow event.topic
    end
  end

  def edit
    @event = current_user.events.find(params[:id])

    if @event.event_photo.present?
      @event_photo = @event.event_photo
    else
      @event_photo = @event.build_event_photo
    end
  end

  def update
    @event = current_user.events.find(params[:id])
    if @event.start_time > @event.end_time
      flash[:warning] = "開始時間錯誤"
      render :edit
    else
      if @event.update(event_params)
        redirect_to event_path(@event), notice: "活動修改成功"
      else
        render :edit
      end
    end
  end

  def destroy
    @event = current_user.events.find(params[:id])
    @event.destroy
    redirect_to account_my_events_path, alert: "活動已刪除"
  end

  private

  def event_params
    params.require(:event).permit(:topic, :start_time, :end_time, :location, :content, :is_active, event_photo_attributes: [:image, :id])
  end
end
