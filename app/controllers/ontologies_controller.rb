class OntologiesController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required, :only => [:new, :edit, :create, :update]

  def index
    @query = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    @ontologies = Ontology.where(:name => /^#{@query}/i).page(page)

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "ontologies_list.html.haml")
        }
    end
  end

  def new
    @ontology = Ontology.new
  end

  def create
    @ontology = Ontology.new(params[:ontology])
    if @ontology.save
      flash[:notice] = "Ontology has been created."
      redirect_to(ontologies_url)
    else
      render(:action => :new)
    end
  end

  def edit
    @ontology = Ontology.find(params[:id])

    rescue Mongoid::Errors::DocumentNotFound
      flash[:warning] = "That ontology does not exist."
      redirect_to(ontologies_url)
  end

  def update
    @ontology = Ontology.find(params[:id])

    if @ontology.update_attributes(params[:ontology])
      flash[:notice] = 'Ontology was successfully updated.'
      redirect_to(ontologies_url)
    else
      render(:action => :edit)
    end
  end

  def show
    @ontology = Ontology.find(params[:id])
    page = (params[:page].to_i > 0) ? params[:page].to_i : 1
    @q = params[:query]
    @ontologies = OntologyTerm.where(:ontology_id => @ontology.id).where(:name => /^#{@q}/i).page(page)

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "ontology_term_list.html.haml")
        }
    end

    rescue Mongoid::Errors::DocumentNotFound
      flash[:warning] = "That ontology does not exist."
      redirect_to(ontologies_url)
  end

  protected

    def check_cancel
      redirect_to(ontologies_url) and return if (params[:commit] == t('label.cancel'))
    end

end
