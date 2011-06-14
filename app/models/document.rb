class Document
  include Mongoid::Document
  field :title, :type => String

  validates_presence_of :title
  validates_uniqueness_of :title

end
