require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActionmailerExtensions do

  # Creates an anonmyous throw-away class of type=parent, with an additional
  # proc for defining methods on the class.
  def new_anon_class(parent, name="", &proc)
    klass = Class.new(parent)  
    mc = klass.instance_eval{ class << self ; self ; end }
    mc.send(:define_method, :name) {name}
    mc.send(:define_method, :to_s) {name}
    klass.class_eval(&proc) if proc
    klass
  end

  # create a new anonymous ActionMailer::Base descendant class
  def new_mailer_class(name, &proc)
    return new_anon_class(ActionMailer::Base, name, proc) if proc
    new_anon_class(ActionMailer::Base, name){
      def test_email(to="someone@example.com")
        from          "noreply@nowhere.local"
        recipients    to
        subject       "test email"
        content_type  "text/plain"
        body          "test email"
      end
    }
  end

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.perform_deliveries = true
    @test_mailer_klass = new_mailer_class('TestMailer')
  end

  describe "alias chain" do
    it "should create new methods" do
      ActionMailer::Base.instance_methods.include?(:deliver!).should be_true
      ActionMailer::Base.instance_methods.include?(:deliver_with_disk_save!).should be_true
      ActionMailer::Base.instance_methods.include?(:deliver_without_disk_save!).should be_true
    end
  end

  describe "deliver_with_disk_save!" do

    describe "saving emails to disk" do
      before do
        ActionMailer::Base.save_emails_to_disk = true
        ActionMailer::Base.email_output_dir = "/tmp/actionmailer_output_emails"
      end

      after do
        # cleanup any mails we wrote to disk
        FileUtils.rm_r(ActionMailer::Base.email_output_dir) if File.directory?(ActionMailer::Base.email_output_dir)
      end

      it "should create the output dir if it does not exist" do
        File.directory?(ActionMailer::Base.email_output_dir).should be_false
        @test_mailer_klass.deliver_test_email
        File.directory?(ActionMailer::Base.email_output_dir).should be_true
      end

      it "should save email contents to disk if enabled" do
        @mail = @test_mailer_klass.deliver_test_email
        files = Dir[File.join(ActionMailer::Base.email_output_dir, "*")]
        files.size.should == 1
        IO.read(files.first).should == @mail.encoded
      end

      it "should not save email to disk if not enabled" do
        ActionMailer::Base.save_emails_to_disk = false
        @mail = @test_mailer_klass.deliver_test_email
        files = Dir[File.join(ActionMailer::Base.email_output_dir, "*")].size.should == 0
      end
    end

    describe "safe recipients" do
      before do
        ActionMailer::Base.safe_recipients = ['a@example.com', 'b@example.com']
        @test_mailer_klass.create_test_email.to.should == ["someone@example.com"]
      end

      it "should restrict sending when list is empty" do
        ActionMailer::Base.safe_recipients = []
        lambda{
          @test_mailer_klass.deliver_test_email()
        }.should_not change{ActionMailer::Base.deliveries.size}
      end

      it "should restrict sending when list is nil" do
        ActionMailer::Base.safe_recipients = nil
        lambda{
          @test_mailer_klass.deliver_test_email
        }.should_not change{ActionMailer::Base.deliveries.size}
      end

      it "should not restrict sending when recipient is in the list" do
        ActionMailer::Base.safe_recipients = ["someone@example.com"]
        lambda{
          @test_mailer_klass.deliver_test_email
        }.should change{ActionMailer::Base.deliveries.size}.by(1)
      end

      it "should send to any address when safe recipients list contains :any" do
        ActionMailer::Base.safe_recipients = [:any]
        lambda{
          @test_mailer_klass.deliver_test_email
        }.should change{ActionMailer::Base.deliveries.size}.by(1)
      end
      
      it "should send to any address when safe recipients list contains 'any'" do
        ActionMailer::Base.safe_recipients = ['any']
        lambda{
          @test_mailer_klass.deliver_test_email
        }.should change{ActionMailer::Base.deliveries.size}.by(1)
      end
      
      it "should restrict sending when recipient is not in the list" do
        ActionMailer::Base.safe_recipients.include?("someone@example.com").should be_false
        lambda{
          @test_mailer_klass.deliver_test_email
        }.should_not change{ActionMailer::Base.deliveries.size}
      end

      it "should not have side-effects on the safe recipients list" do
        ActionMailer::Base.safe_recipients = [:any, "foo@foo.com", "bar@bar.com"]
        @test_mailer_klass.deliver_test_email
        ActionMailer::Base.safe_recipients.should == [:any, "foo@foo.com", "bar@bar.com"]
      end

      it "should allow sending when multiple recipients are all in the safe list" do
        ActionMailer::Base.safe_recipients = ['a@example.com', 'b@example.com']
        lambda{
          @test_mailer_klass.deliver_test_email(['a@example.com', 'b@example.com'])
        }.should change{ActionMailer::Base.deliveries.size}.by(1)
      end

      it "should restrict sending when not all recipients are in the safe list" do
        ActionMailer::Base.safe_recipients = ['a@example.com', 'b@example.com']
        lambda{
          @test_mailer_klass.deliver_test_email(['a@example.com', 'foo@example.com'])
        }.should_not change{ActionMailer::Base.deliveries.size}
      end

    end

  end

end
