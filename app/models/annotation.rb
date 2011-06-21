class Annotation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ncbo_id, :type => Integer
  field :document_id, :type => String

  field :ontology_term_id, :type => String
  field :ontology_term_name, :type => String

  field :field_name, :type => String
  field :field_value, :type => String

  field :predicate, :type => String, :default => ''
  field :verified, :type => Boolean, :default => false

  field :status, :type => String, :default => 'unaudited'

  field :curated_by_id, :type => String, :default => ''
  field :created_by_id, :type => String, :default => ''

  field :starts_at, :type => Integer
  field :ends_at, :type => Integer

  field :synonym, :type => Boolean, :default => false
  field :mapping, :type => Boolean, :default => false

  index :created_by_id
  index :curated_by_id

  index(
    [
      [ :document_id, Mongo::ASCENDING ],
      [ :field_name, Mongo::ASCENDING ],
      [ :ncbo_id, Mongo::ASCENDING ],
      [ :ontology_term_id, Mongo::ASCENDING ]
    ],
    unique: true)

  @queue = :database

  scope :verified, where(:verified => true)
  scope :unverified, where(:verified => false)
  scope :audited, where(:status => 'audited')
  scope :unaudited, where(:status => 'unaudited')

  class << self
    def perform(hash)
      case hash['action']
        when 'save'
          self.save_annotation(hash)
      end
    end

    def save_annotation(hash)
      annotation = Annotation.new(
        document_id: hash['document_id'], ncbo_id: hash['ncbo_id'], ontology_term_id: hash['ontology_term_id'],
        ontology_term_name: hash['ontology_term_name'], field_name: hash['field_name'], field_value: hash['field_value'],
        starts_at: hash['starts_at'], ends_at: hash['ends_at'], synonym: hash['synonym'], mapping: hash['mapping']
      )
      annotation.save
    end
  end #of self

  def resource_id
    [ncbo_id, ontology_term_id].join('/')
  end

  def audited?
    self.status == 'audited'
  end

  def term_text
    field_value[(self.starts_at-1)..(self.ends_at-1)]
  end

  def full_text_highlighted
    text = field_value
    term = "<strong class='highlight'>#{text[(self.starts_at-1)..(self.ends_at-1)]}</strong>"
    if self.starts_at != 1
      term = text[0..(self.starts_at-2)] << term
    end

    if self.ends_at != text.size
      term = term << text[self.ends_at..text.size]
    end
    term.html_safe
  end

  def in_context
    extended = 50
    start = 0
    finish = 0
    text = field_value
    prefix = ""
    suffix = ""
    term = "<strong class='highlight'>#{text[(self.starts_at-1)..(self.ends_at-1)]}</strong>".html_safe
    start = (self.starts_at-extended > 0) ? self.starts_at-extended : 0

    if self.starts_at-1 > 0
      if self.starts_at-extended > 0
        prefix = "..."+text[start..(self.starts_at-2)]
      else
        prefix = text[start..(self.starts_at-2)]
      end
    end

    if self.ends_at+extended > text.size
      if self.ends_at+1 <= text.size
        suffix = text[(self.ends_at)..text.size]
      end
    else
      finish = self.ends_at+extended
      suffix = text[(self.ends_at)..finish]+"..."
    end
    (prefix+term+suffix).html_safe
  end

  def set_status(user_id)
    if self.status == 'unaudited'
      self.status = 'audited'
      self.curated_by_id = user_id
    end

    if self.verified?
      self.verified = false
    else
      self.verified = true
    end
    self.save
  end

end