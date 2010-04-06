require 'rubygems'
require 'action_mailer'

module ActionmailerExtensions
  
  def deliver_with_disk_save!(mail = @mail)
    if save_emails_to_disk
      FileUtils.mkdir_p(email_output_dir) unless File.directory?(email_output_dir)
      filename = "#{Time.now.to_i}_#{mail.to.join(',')}.eml"
      File.open(File.join(email_output_dir, filename), "w+") {|f|
        f << mail.encoded
      }
    end
    
    # ensure that the mail's "to" recipients are all contained in the safe_recipients list
    send = case
    when !safe_recipients || safe_recipients.empty? then false
    when (safe_recipients - [:any, 'any']).length < safe_recipients.length then true
    when (mail.to.map(&:downcase) - safe_recipients.map{|r| r.to_s.downcase}).empty? then true
    end
    
    return mail unless send
    
    deliver_without_disk_save!(mail)
    mail
  end
  
end

module ActionMailer
  class Base
    
    # Add some additional class attributes that we need.
    @@safe_recipients = [:any]
    cattr_accessor :safe_recipients
    
    @@save_emails_to_disk = false
    cattr_accessor :save_emails_to_disk
    
    @@email_output_dir = "/tmp/actionmailer_output_emails"
    cattr_accessor :email_output_dir
    
    private
    include ActionmailerExtensions
    alias_method_chain :deliver!, :disk_save
  end
end
