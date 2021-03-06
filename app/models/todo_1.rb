class Todo < ActiveRecord::Base
  require 'net/imap'
  require 'pp'
  belongs_to :context
  belongs_to :project
  belongs_to :user
  belongs_to :recurring_todo
  has_many :assets, :as => :contentasset
  STARRED_TAG_NAME = "starred"
  
  acts_as_state_machine :initial => :active, :column => 'state'
  
  # when entering active state, also remove completed_at date. Looks like :exit
  # of state completed is not run, see #679
  state :active, :enter => Proc.new { |t| t[:show_from], t.completed_at = nil, nil }
  state :project_hidden
  state :completed, :enter => Proc.new { |t| t.completed_at = Time.now.utc }, :exit => Proc.new { |t| t.completed_at = nil }
  state :deferred
  
  def self.create_task_from_email(email, user_id)
    task = Todo.new
    task.description = email.subject
    
    ## process content email)
    if email.content_type == 'text/html' || email.body.split("<html>").first.nil?
      content = email.body.split("</head>")[1]
      task.notes = "<html>#{content}"
    else
      content = email.body.split("<html>").first # remove HTML ads
      content = content.split("---------------------------------").first # remove another ads
      task.notes = content if !content.include?("<") && !content.include?(">")
    end

#    ## process to email
#    recipient = email['to'].to_s
#    if recipient.split("<")[1].nil?
#      recipient = recipient.split("<").first
#    elsif !recipient.split("<")[1].nil?
#      recipient = recipient.split("<")[1].split(">").first
#    end
#    unless recipient.nil?
#      mail = TMail::Address.parse(recipient).to_s 
#      #mail = TMail::Address.parse(email['to'].to_s).spec()
#      user = User.find(user_id)
#    end
#    
#    ## check CC user
#    if user.nil?
#      recipient = email['cc'].to_s
#      if recipient.split("<")[1].nil?
#        recipient = recipient.split("<").first
#      elsif !recipient.split("<")[1].nil?
#        recipient = recipient.split("<")[1].split(">").first
#      end
#      unless recipient.nil?
#        mail = TMail::Address.parse(recipient).to_s 
#        #mail = TMail::Address.parse(email['to'].to_s).spec()
#        user = User.find_by_email(recipient)
#      end
#    end
#
#    ## check BCC user
#    if user.nil?
#      recipient = email['bcc'].to_s
#      if recipient.split("<")[1].nil?
#         recipient = recipient.split("<").first
#      elsif !recipient.split("<")[1].nil?
#         recipient = recipient.split("<")[1].split(">").first
#      end
#      unless recipient.nil?
#        mail = TMail::Address.parse(recipient).to_s 
#        #mail = TMail::Address.parse(email['to'].to_s).spec()
#        user = User.find_by_email(recipient)
#      end
#    end 
    p user_id 
    user = User.find(user_id)
    p user
    if user
      task.user_id = user.id      
      task.project_id = user.preference.default_project_for_mail
      task.context_id = user.preference.default_context_for_mail
      task.state = "active"
      task.created_at = email.date
      email.attachments
      unless email.attachments.nil?
        email.attachments.each do |attachment|
          asset = Asset.new()
          asset.uploaded_data = attachment
          task.assets << asset
        end 
      end
      task.save
    end
  end
  
  event :defer do
    transitions :to => :deferred, :from => [:active]
  end
  
  event :complete do
    transitions :to => :completed, :from => [:active, :project_hidden, :deferred]
  end
  
  event :activate do
    transitions :to => :active, :from => [:project_hidden, :completed, :deferred]
  end
    
  event :hide do
    transitions :to => :project_hidden, :from => [:active, :deferred]
  end
  
  event :unhide do
    transitions :to => :deferred, :from => [:project_hidden], :guard => Proc.new{|t| !t.show_from.blank? }
    transitions :to => :active, :from => [:project_hidden]
  end
    
  attr_protected :user

  # Description field can't be empty, and must be < 100 bytes Notes must be <
  # 60,000 bytes (65,000 actually, but I'm being cautious)
  validates_presence_of :description
  validates_length_of :description, :maximum => 100
  validates_length_of :notes, :maximum => 60000, :allow_nil => true 
  validates_presence_of :show_from, :if => :deferred?
  validates_presence_of :context
  
  def validate
    if !show_from.blank? && show_from < user.date
      errors.add("show_from", "must be a date in the future")
    end
  end
  
  def toggle_completion!
    saved = false
    if completed?
      saved = activate!
    else
      saved = complete!
    end
    return saved
  end
  
  def show_from
    self[:show_from]
  end
  
  def show_from=(date)
    activate! if deferred? && date.blank?
    defer! if active? && !date.blank? && date > user.date
    self[:show_from] = date 
  end

  alias_method :original_project, :project

  def project
    original_project.nil? ? Project.null_object : original_project
  end
  
  alias_method :original_set_initial_state, :set_initial_state
  
  def set_initial_state
    if show_from && (show_from > user.date)
      write_attribute self.class.state_column, 'deferred'
    else
      original_set_initial_state
    end
  end
  
  alias_method :original_run_initial_state_actions, :run_initial_state_actions
  
  def run_initial_state_actions
    # only run the initial state actions if the standard initial state hasn't
    # been changed
    if self.class.initial_state.to_sym == current_state
      original_run_initial_state_actions
    end
  end

  def self.feed_options(user)
    {
      :title => 'Tracks Actions',
      :description => "Actions for #{user.display_name}"
    }
  end
  
  def starred?
    tags.any? {|tag| tag.name == STARRED_TAG_NAME}
  end
  
  def toggle_star!
    if starred?
      delete_tags STARRED_TAG_NAME
      tags.reload
    else
      add_tag STARRED_TAG_NAME
      tags.reload
    end 
    starred?  
  end

  def from_recurring_todo?
    return self.recurring_todo_id != nil
  end
  
end
