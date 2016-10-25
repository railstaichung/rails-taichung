class IssuePostManJob < ApplicationJob
  queue_as :default

  def perform(*args)
    issue = Issue.find(args[0])
    responds = issue.responds
    mail_list = Array.new
    mail_list << issue.owner.email
    responds.each do |respond|
      mail_list << respond.user.email
    end
    mail_list.uniq!
    mail_list.each do |mail|
      IssueMailer.notify_issue_respond(issue,mail).deliver!
    end
  end
end
