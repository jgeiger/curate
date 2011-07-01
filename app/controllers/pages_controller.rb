class PagesController < ApplicationController

  def home
    @document_count = Document.count
    @ontology_count = Ontology.count
    @ontology_term_count = OntologyTerm.count
  end

end
