class PreferencesController < ApplicationController
    
  def index
    @page_title = "TRACKS::Preferences"
    @prefs = prefs
  end

  def edit
    @page_title = "TRACKS::Edit Preferences"
    @smtp_setting = current_user.smtp_setting
    render :object => prefs
  end
  
  def update
    user_updated = current_user.update_attributes(params['user'])
    prefs_updated = current_user.preference.update_attributes(params['prefs'])
    if current_user.smtp_setting 
      smtp_updated =  current_user.smtp_setting.update_attributes(params['smtp_setting']) 
    else
      smtp = SmtpSetting.new(params['smtp_setting'])
      smtp.user = current_user
      smtp.save
      smtp_updated =  current_user.smtp_setting
    end 
    if user_updated && prefs_updated
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end
  
  def read_log
    @contents = []    
    File.open("log/backgroundrb_debug_22222.log") do |file|
      file.each_line { |line|
        @contents <<  line
      }
    end    
  end
end