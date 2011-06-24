class OntologiesController < ApplicationController

  before_filter :check_cancel, :only => [:create, :update]
  before_filter :admin_required, :only => [:new, :edit, :create, :update]
  before_filter :load_ontology, :only => [:show, :edit, :update, :toggle_hidden]

  def index
    @query = params[:query] ? Regexp.escape(params[:query]) : ""
    page = (params[:page].to_i > 0) ? params[:page] : 1

    @ontologies = Ontology.where(:name => /^#{@query}/i).order_by([:name, :asc]).page(page)

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
    @query = params[:query]
    @ontology_terms = OntologyTerm.where(ncbo_id: @ontology.ncbo_id, term_name: /^#{@query}/i).order_by([:term_name, :asc]).page(page)

    respond_to do |format|
      format.html {}
      format.js  {
          render(:partial => "ontologies/ontology_term_list.html.haml")
        }
    end

  end

  def refresh
    Ontology.load_from_ncbo
    redirect_to(ontologies_url, notice: 'Ontology list was successfully updated.')
  end

  def toggle_hidden
    hash = @ontology.toggle_hidden
    render(:json => hash.to_json)
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
