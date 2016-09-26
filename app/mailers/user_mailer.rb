class UserMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts={})
    headers["Custom-header"] = "Bar"
    opts[:subject] = "Rails台中Email驗證"
    @name = record.name if record.name.present?
    super
  end
end
