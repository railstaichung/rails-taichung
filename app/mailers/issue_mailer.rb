class IssueMailer < ApplicationMailer
  def notify_issue_respond(issue, mail)
    @issue = issue
    @issue_responds = @issue.responds
    mail(to: mail, subject:"[Rails台中] #{@issue.title}##{@issue.id}有新的回應")
  end
end
