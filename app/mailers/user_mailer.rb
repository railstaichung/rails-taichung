class UserMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts={})
    headers["Custom-header"] = "Bar"
    opts[:subject] = "Rails台中-註冊Email驗證"
    @name = record.name if record.name.present?
    super
  end
  def reset_password_instructions(record, token, opts={})
    headers["Custom-header"] = "Bar"
    opts[:subject] = "Rails台中-使用者密碼變更"
    super
  end
end
