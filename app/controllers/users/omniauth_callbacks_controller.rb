class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    basic_omniauth_action("Facebook")
  end

  def google_oauth2
    basic_omniauth_action("Google")
  end

  def github
    basic_omniauth_action("github")
  end

  def line
    basic_omniauth_action("Line")
  end

  def failure
    redirect_to root_path
  end

  private

  def basic_omniauth_action(omniauth_type)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => omniauth_type
    else
      session["devise.#{omniauth_type.downcase}_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end
