class OntologyTerm
  include Mongoid::Document

  belongs_to :ontology
#  has_many :annotations, :dependent => :delete_all, :order => :geo_accession#, :dependent => :destroy
#  has_many :annotation_closures, :dependent => :delete_all, :include => :annotation, :order => "annotations.geo_accession"#, :dependent => :destroy

#  has_many :valid_annotations, :class_name => "Annotation", :conditions => {:verified => true}, :order => :geo_accession#, :dependent => :destroy
#  has_many :valid_annotation_closures, :class_name => "AnnotationClosure", :conditions => ['annotations.verified = ?', true], :include => :annotation, :order => "annotations.geo_accession"#, :dependent => :destroy

#  has n, :results, :foreign_key => :ontology_term_id#, :order => :sample_geo_accession, :dependent => :destroy # they exist, but don't associate in case of lazy load

  class << self
  end # of self

  def to_param
    self.term_id
  end

  def specific_term_id
    self.term_id.split("|").last
  end

  def valid_annotation_percentage
    if annotations_count > 0
      (valid_annotation_count.to_f/annotations_count.to_f)*100
    else
      0
    end
  end

  def audited_annotation_percentage
    if annotations_count > 0
      (audited_annotation_count.to_f/annotations_count.to_f)*100
    else
      0
    end
  end

  # def valid_annotation_count
  #   Annotation.count(:conditions => {:ontology_term_id => self.id, :verified => true})
  # end
  #
  # def audited_annotation_count
  #   Annotation.count(:conditions => {:ontology_term_id => self.id, :status => 'audited'})
  # end

end
