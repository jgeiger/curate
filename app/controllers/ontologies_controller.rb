class OntologiesController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required, :only => [:new, :edit, :create, :update]
  before_filter :load_ontology, :only => [:show, :edit, :update]

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
      redirect_to(ontologies_url, notice: "Ontology has been created.")
    else
      render(:action => :new)
    end
  end

  def edit
  end

  def update
    if @ontology.update_attributes(params[:ontology])
      redirect_to(ontologies_url, notice: 'Ontology was successfully updated.')
    else
      render(:action => :edit)
    end
  end

  def show
    page = (params[:page].to_i > 0) ? params[:page].to_i : 1
    @q = params[:query]
    @ontologies = OntologyTerm.where(:ontology_id => @ontology.id).where(:name => /^#{@q}/i).page(page)

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "ontology_term_list.html.haml")
        }
    end

  end

  protected

  def load_ontology
    @ontology = Ontology.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(ontologies_url, warning: "That ontology does not exist.")
  end

  def check_cancel
    redirect_to(ontologies_url) and return if (params[:commit] == t('label.cancel'))
  end

end
