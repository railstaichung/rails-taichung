class Users::SessionsController < Devise::SessionsController
  include SimpleCaptcha::ControllerHelpers
  skip_before_filter :require_no_authentication, :only => [:create]
# before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    if simple_captcha_valid? then
      super
    else
      flash[:alert] = "驗證碼輸入錯誤，請在試試..."
      self.resource = resource_class.new(sign_in_params)
      respond_with_navigational(resource) { render :new }
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
