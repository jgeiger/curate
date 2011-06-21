class OntologyTermsController < ApplicationController

  def index
    @query = params[:query] ? Regexp.escape(params[:query]) : ""
    page = (params[:page].to_i > 0) ? params[:page] : 1

    @ontology_terms = OntologyTerm.where(:term_name => /^#{@query}/i).order_by([:term_name, :asc]).page(page)

    respond_to do |format|
      format.html { }
      format.js  {
        render(:partial => "ontology_terms_list.html.haml")
      }
    end
  end

  def show
    ncbo_id, term_id = CGI::unescape(params[:id]).split('|')
    @ontology_term = OntologyTerm.where(ncbo_id: ncbo_id, term_id: term_id).first

    raise Mongoid::Errors::DocumentNotFound if !@ontology_term
    respond_to do |format|
      format.html { }
      format.js {}
    end

    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(ontology_terms_url, error: "That ontology term does not exist.")
  end

end
