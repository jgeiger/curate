class OntologyTerm
  include Mongoid::Document

#  belongs_to :ontology
#  has_many :annotations, :dependent => :delete_all, :order => :geo_accession#, :dependent => :destroy
#  has_many :annotation_closures, :dependent => :delete_all, :include => :annotation, :order => "annotations.geo_accession"#, :dependent => :destroy

#  has_many :valid_annotations, :class_name => "Annotation", :conditions => {:verified => true}, :order => :geo_accession#, :dependent => :destroy
#  has_many :valid_annotation_closures, :class_name => "AnnotationClosure", :conditions => ['annotations.verified = ?', true], :include => :annotation, :order => "annotations.geo_accession"#, :dependent => :destroy

#  has n, :results, :foreign_key => :ontology_term_id#, :order => :sample_geo_accession, :dependent => :destroy # they exist, but don't associate in case of lazy load

  field :ncbo_id, :type => Integer
  field :term_id, :type => String
  field :term_name, :type => String

  index(
    [
      [ :ncbo_id, Mongo::ASCENDING ],
      [ :term_id, Mongo::ASCENDING ]
    ],
    unique: true)

  @queue = :database

  class << self
    def perform(hash)
      case hash['action']
        when 'save'
          self.save_ontology_term(hash)
      end
    end

    def save_ontology_term(hash)
      ontology_term = OntologyTerm.new(ncbo_id: hash['ncbo_id'], term_id: hash['term_id'], term_name: hash['term_name'])
      ontology_term.save
    end
  end # of self

  def to_param
    [ncbo_id, term_id].join('|')
  end

  def specific_term_id
    self.term_id
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
