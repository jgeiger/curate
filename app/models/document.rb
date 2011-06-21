class Document
  include Mongoid::Document

  field :title, :type => String

  index :title, unique: true

  validates_presence_of :title
  validates_uniqueness_of :title

  def annotations_for(field_name)
    Annotation.where(field_name: field_name).where(document_id: self._id).order_by([:ontology_term_name, :desc])
  end

end
