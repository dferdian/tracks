class NotesController < ApplicationController

  def index
    @all_notes = current_user.notes
    @count = @all_notes.size
    @page_title = "TRACKS::All notes"
    respond_to do |format|
      format.html
      format.xml { render :xml => @all_notes.to_xml( :except => :user_id )  }
    end
  end

  def show
    @note = current_user.notes.find(params['id'])
    @page_title = "TRACKS::Note " + @note.id.to_s
    respond_to do |format|
      format.html
      format.m &render_note_mobile
    end
  end

  def render_note_mobile
    lambda do
      render :action => 'note_mobile'
    end
  end

  def create
    note = current_user.notes.build
    note.attributes = params["new_note"]
    note = save_attachment(note)

    responds_to_parent do
      render :update do |page|
        if note.save
          page.insert_html :bottom, "notes",  :partial => 'notes_summary', :object => note
          page.form.reset 'form-new-note'
          page.visual_effect :highlight, "notes", :duration => 3
        else
          page.insert_html "notes", :text => ''
        end
      end
    end
  end

  def destroy
    @note = current_user.notes.find(params['id'])

    @note.destroy
    
    respond_to do |format|
      format.html
      format.js do
        @count = current_user.notes.size
        render
      end
    end
      
    #    if note.destroy
    #      render :text => ''
    #    else
    #      notify :warning, "Couldn't delete note \"#{note.id}\""
    #      render :text => ''
    #    end
  end

  def update
    unless params[:count_asset] == "0"
      for i in 0..params[:count_asset].to_i-1
        if params[:asset][:status]["#{i}"] == "0"
          asset = Asset.find(params[:asset][:id]["#{i}"])
          asset.destroy
        else
          asset = Asset.find(params[:asset][:id]["#{i}"])
          params[:edit_asset][:uploaded_data]= params[:asset][:file]["#{i}"]
          asset.update_attributes(params[:edit_asset]) unless params[:asset][:file]["#{i}"]==""
        end
      end 
    end
        note = current_user.notes.find(params['id'])
        note.attributes = params["note"]
        note = save_attachment(note)
#        if note.save
#          render :partial => 'notes', :object => note
#        else
#          notify :warning, "Couldn't update note \"#{note.id}\""
#          render :text => ''
#        end
   responds_to_parent do
      render :update do |page|
        if note.save
          page.replace_html params[:target], :partial => 'notes', :object => note
        else
		  notify :warning, "Couldn't update note \"#{note.id}\""
          page.insert_html "#{params[:target]}", :text => ''
        end
      end
    end
  end
  
  def download
    note = Note.find(params[:note_id] || nil)  
    if note
      asset = note.assets.find(params[:id])
      send_file("#{RAILS_ROOT}/public#{asset.public_filename}", :type => asset.content_type, :filename => asset.filename) 
    else
      redirect_to :action => 'index'
    end
  end
  
  def save_attachment(note)
    params[:upload_file].each do |file|
      files = Hash["attachment" => {"uploaded_data"=>""}]
      files["attachment"]["uploaded_data"] = file[1]
      if files["attachment"]["uploaded_data"] != ""
        asset = Asset.new(files["attachment"])
        note.assets << asset
      end
    end
    note
  end
end
