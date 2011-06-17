class Document
  include Mongoid::Document

  field :title, :type => String

  index :title, unique: true

  validates_presence_of :title
  validates_uniqueness_of :title

end
