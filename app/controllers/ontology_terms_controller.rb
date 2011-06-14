class OntologyTermsController < ApplicationController

  def index
    @q = params[:query]
    page = (params[:page].to_i > 0) ? params[:page] : 1

    @ontology_terms = OntologyTerm.where(:name => /^#{@q}/i).page(page)

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "ontology_terms_list.html.haml")
        }
    end
  end

  def show
    @ontology_term = OntologyTerm.first(:conditions => {:term_id => CGI::unescape(params[:id])})
    annotation_type = params['annotation_type']
    page = (params[:page].to_i > 0) ? params[:page].to_i : 1
    raise Mongoid::Errors::DocumentNotFound if !@ontology_term

    respond_to do |format|
      format.html { }
      format.js {}
    end

    rescue Mongoid::Errors::DocumentNotFound
      flash[:warning] = "That ontology term does not exist."
      redirect_to(ontology_terms_url)
  end

end
