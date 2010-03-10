class FormsController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :index, :destroy]
  before_filter :set_form, :only => [:edit, :update]
  before_filter :verify_edit_key, :only => [:edit, :update]
  
  # GET /forms
  # GET /forms.xml
  def index
    @forms = Form.find_all_by_user_id(current_user.id.to_s)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forms }
    end
  end

  # GET /forms/1
  # GET /forms/1.xml
  def show
    @form = Form.find(params[:id])
    @row = @form.klass.new
    
    respond_to do |format|
      format.html { render :layout => params[:embed].blank? ? 'simple' : "embed"}# show.html.erb
      @form.mongo_id = @form.id.to_s
      format.json  { render :json => @form.to_json }
    end
  end

  # GET /forms/new
  # GET /forms/new.xml
  def new
    @form = current_user.forms.create(:title => "未命名表单", :description => '描述一下你的表单吧')
    @field = Field.new
    
    respond_to do |format|
      format.html { redirect_to edit_form_path(@form, :edit_key => @form.edit_key)}
      format.xml  { render :xml => @form }
    end
  end
  
  def create
    @form = current_user.forms.build(params[:form])
    
    respond_to do |format|
      if @form.save
        format.html { redirect_to edit_form_path(@form, :edit_key => @form.edit_key) }
        format.json  do
          @form.mongo_id = @form.id.to_s
          render :json => @form.to_json
        end
      else
        format.html { render :action => "new" }
        format.json  { render :json => @form.errors.to_json }
      end
    end
  end

  # GET /forms/1/edit
  def edit
    @field = Field.new(:input => 'string')
    @fields = @form.fields#.sort {|f1, f2| f1.position <=> f2.position}
    respond_to do |want|
      want.html { render :layout => params[:embed].blank? ? 'application' : "simple"}
    end
  end

  # PUT /forms/1
  # PUT /forms/1.xml
  def update
    respond_to do |format|
      if @form.update_attributes(params[:form])
        @form.sort_fields(params[:uuids])
        
        format.html { 
          flash[:notice] = 'Form was successfully updated.'
          redirect_to(@form) 
        }
        format.js {
          render :update do |page|
            page.visual_effect('highlight', '.edit_form')
          end
        }
        format.json  do
          @form.mongo_id = @form.id.to_s
          render :json => @form.to_json
        end      
      else
        format.html { render :action => "edit" }
        format.js {
          render :update do |page|
            page << "alert('#{@form.errors.full_messages}')"
          end
        }
        format.json  { render :json => @form.errors.to_json }
      end
    end
  end

  # DELETE /forms/1
  # DELETE /forms/1.xml
  def destroy
    @form = Form.find(params[:id])
    @form.destroy

    respond_to do |format|
      format.html { redirect_to(forms_url) }
      format.json  { render :json => {:result => 'ok'}.to_json }
    end
  end
  
  private 
  def set_form
    @form = Form.find(params[:id])
  end
end
