module EventsHelper
  def event_action(event)
    if event.active?
      if !current_user
        link_to("立刻報名", new_user_session_path, class: "btn btn-primary btn-lg btn-block")
      else
        if current_user.is_member_of?(event)
          #link_to("取消報名", quit_event_path(@event), data: { confirm: "你確定要取消報名嗎？" }, method: :post, class: "btn btn-warning btn-lg btn-block")
          content_tag(:h3, "你已經參加活動")
        else
          link_to("立刻報名", join_event_path(@event), method: :post, class: "btn btn-primary btn-lg btn-block")
        end
      end
    else
      link_to("活動已結束", "#", class: "btn btn-primary btn-lg btn-block", disabled: "disabled")
    end
  end

end
