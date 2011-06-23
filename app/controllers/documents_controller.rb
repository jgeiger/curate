class DocumentsController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :load_document, :only => [:show, :edit, :update, :destroy]

  def index
    @query = params[:query] ? Regexp.escape(params[:query]) : ""
    page = (params[:page].to_i > 0) ? params[:page] : 1

    @documents = Document.where(:title => /^#{@query}/i).order_by([:title, :asc]).page(page)

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "documents_list.html.haml")
        }
    end
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
    if admin?
      @new_annotation = Annotation.for_item(@document, current_user.id)
      @ontologies = Ontology.all.order_by([:name, :asc])
    end
    respond_to do |format|
      format.html
      format.json { render json: @document }
    end
  end

  # GET /documents/new
  # GET /documents/new.json
  def new
    @document = Document.new

    respond_to do |format|
      format.html
      format.json { render json: @document }
    end
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = Document.new(params[:document])

    respond_to do |format|
      if @document.save
        format.html { redirect_to documents_url, notice: 'Document was successfully created.' }
        format.json { render json: @document, status: :created, location: @document }
      else
        format.html { render action: "new" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    respond_to do |format|
      if @document.update_attributes(params[:document])
        format.html { redirect_to documents_url, notice: 'Document was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to documents_url }
      format.json { head :ok }
    end
  end


  protected

  def load_document
    @document = Document.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(documents_url, warning: 'Document does not exist.')
  end

  def check_cancel
    redirect_to(documents_url) and return if (params[:commit] == t('label.cancel'))
  end

end
