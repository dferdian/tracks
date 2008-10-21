class Emailer < ActionMailer::Base
  require 'net/imap'
  def self.check_pop
    begin
      SmtpSetting.find(:all).each_with_index do |smtp, x|
        @imap_settings = {
          :server => smtp.pop_server,
          :port => smtp.pop_port,
          :user_name => smtp.pop_user_name,
          :password => smtp.pop_password,
          :user_id => smtp.user_id,
          :imap => smtp
        }
        if (@imap_settings[:server] == "imap.gmail.com")   #    imap.gmail.com  
          imap = Net::IMAP.new(@imap_settings[:server], @imap_settings[:port],true)
          return if imap.nil?
          imap.login(@imap_settings[:user_name], @imap_settings[:password])
          imap.select('INBOX')
          imap.search(['UNSEEN']).each do |message_id|
            msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
            @mail = TMail::Mail.parse(msg)
            Todo.create_task_from_email(@mail, @imap_settings[:user_id])
            imap.store(message_id, "+FLAGS", [:Seen])
          end
          imap.expunge()
          imap.logout()
          imap.disconnect()
        else
          imap = Net::IMAP.new(@imap_settings[:server])
          return if imap.nil?
          imap.authenticate('LOGIN', @imap_settings[:user_name], @imap_settings[:password])
          imap.select('INBOX')
          imap.search(['UNSEEN']).each do |message_id|
            msg = imap.fetch(message_id,'RFC822')[0].attr['RFC822']
            @mail = TMail::Mail.parse(msg)
            Todo.create_task_from_email(@mail, @imap_settings[:user_id])
          end
          imap.expunge()
        end
      end
    rescue Exception => msg
      ## rescue for email check error
      begin
        if msg && !msg.to_s.include?("Connection refused") && !msg.to_s.include?("exit")
          #self.deliver_send_error_notification(@imap_settings[:imap], msg)
        end
      rescue
        # handle if IO connection ERROR #<IOError: closed stream>
      end
    end
  end
  
  def send_error_notification(imap, msg)
    setup_email
    @subject  += "[Tracks] Error Notification"
    @body      = {:user => imap.user, :msg => msg}
    @content_type = "text/html"
  end
  
  protected
  
  def setup_email
    @recipients = User.find_by_is_admin(true).email
    @subject    = ""
    @from       = "do-not-reply@tracks-dev.matttessar.com"
    @sent_on    = Time.now
  end
end