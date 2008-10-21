class SmtpSettingsController < ApplicationController
  before_filter :admin_login_required
  # GET /smtp_settings
  # GET /smtp_settings.xml
  def index
    @smtp_settings = SmtpSetting.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @smtp_settings }
    end
  end

  # GET /smtp_settings/1
  # GET /smtp_settings/1.xml
  def show
    @smtp_setting = SmtpSetting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @smtp_setting }
    end
  end

  # GET /smtp_settings/new
  # GET /smtp_settings/new.xml
  def new
    @smtp_setting = SmtpSetting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @smtp_setting }
    end
  end

  # GET /smtp_settings/1/edit
  def edit
    @smtp_setting = SmtpSetting.find(params[:id])
  end

  # POST /smtp_settings
  # POST /smtp_settings.xml
  def create
    @smtp_setting = SmtpSetting.new(params[:smtp_setting])

    respond_to do |format|
      if @smtp_setting.save
        flash[:notice] = 'SmtpSetting was successfully created.'
        format.html { redirect_to(@smtp_setting) }
        format.xml  { render :xml => @smtp_setting, :status => :created, :location => @smtp_setting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @smtp_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /smtp_settings/1
  # PUT /smtp_settings/1.xml
  def update
    @smtp_setting = SmtpSetting.find(params[:id])

    respond_to do |format|
      if @smtp_setting.update_attributes(params[:smtp_setting])
        flash[:notice] = 'SmtpSetting was successfully updated.'
        format.html { redirect_to(@smtp_setting) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @smtp_setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /smtp_settings/1
  # DELETE /smtp_settings/1.xml
  def destroy
    @smtp_setting = SmtpSetting.find(params[:id])
    @smtp_setting.destroy

    respond_to do |format|
      format.html { redirect_to(smtp_settings_url) }
      format.xml  { head :ok }
    end
  end
end
