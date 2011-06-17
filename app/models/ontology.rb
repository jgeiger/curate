class Ontology
  include Mongoid::Document

  field :ncbo_id, type: Integer
  field :current_ncbo_id, type: Integer
  field :name, type: String
  field :version, type: String
  field :stopwords, type: String
  field :expand_ontologies, type: String

  index :ncbo_id, unique: true
  index :name, unique: true

  validates_presence_of :name
  validates_uniqueness_of :name

  class << self

    def which_have_annotations
      Ontology.all(:order => :name).select { |ontology| ontology if ontology.annotations.size > 0 }
    end

    def load_from_ncbo
      NCBOAnnotatorService.ontologies.each do |ontology|
        o = Ontology.find_or_initialize_by(ncbo_id: ontology["virtualOntologyId"])
        if o.new_record?
          o.name = ontology['name']
          o.stopwords = ""
          o.expand_ontologies = ""
        end
        o.version = ontology['version']
        o.current_ncbo_id = ontology['localOntologyId']
        o.save
      end
    end

    def insert_terms(file, ncbo_id)
      ontology = Ontology.first(:conditions => {:ncbo_id => ncbo_id})

      term_regex = /^\[Term\]/
      id_regex = /^id: (.+)$/
      name_regex = /^name: (.+)$/
      obsolete_regex = /^is_obsolete: (.+)$/
      in_term_flag = false
      obsolete_flag = false

      File.open(file, "rb", :encoding => 'ISO-8859-1').each do |line|

        # check if we've got a term header, and set true if we do
        if result = term_regex.match(line)
          in_term_flag = true
          @ontology_term = OntologyTerm.new(:ncbo_id => ncbo_id, :ontology_id => ontology.id)
          next
        end

        # if we're not in a term, get the next line
        if !in_term_flag
          next
        end

        # we need to save the ontology
        if in_term_flag && line.blank?
          if !obsolete_flag
            @ontology_term.save
            puts "TERM: #{@ontology_term.term_id}  #{@ontology_term.name}"
          end
          in_term_flag = false
          obsolete_flag = false
        end

        # we need to match the id
        if result = id_regex.match(line)
          term_match = result[1]
          term_id = "#{ncbo_id}|#{term_match}"
          # if we've already got that id, skip it, and move out of being in the term
          if !OntologyTerm.first(:conditions => {:term_id => term_id })
            @ontology_term.term_id = term_id
          else
            in_term_flag = false
            next
          end
        end

        # get the name of the term, save it, and move out of being in the term
        if result = name_regex.match(line)
          name_match = result[1]
          @ontology_term.name = name_match
        end

        # check if there is an obsolete line, which means we don't save it
        if result = obsolete_regex.match(line)
          if result[1] == "true"
            obsolete_flag = true
          end
        end

      end
    end
  end # of self

  def update_data
    self.current_ncbo_id, self.name, self.version = NCBOAnnotatorService.current_ncbo_id(self.ncbo_id)
    save!
  end

end
