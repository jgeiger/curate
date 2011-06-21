class AnnotationProcessor

  @queue = :processing

  class << self
    def perform(job_id)
      self.process_annotation(job_id)
    end

    def process_annotation(job_id)
      if job = AnnotationJob.find(job_id)
        job.update_attributes(started_at: Time.now)
        ontology = Ontology.where(ncbo_id: job.ncbo_id).first
        AnnotationProcessor.create_for(job, ontology)
      end
    end

    def create_for(job, ontology)
      cleaned = job.field_value.gsub(/[\r\n]+/, " ")
      term_hash, ontology_hash = NcboAnnotatorService.result_hash(cleaned, ontology.stopwords, ontology.expand_ontologies, job.ncbo_id)
      AnnotationProcessor.process_ncbo_results(term_hash, ontology_hash, job)
    end

    def process_ncbo_results(hash, ontology_hash, job)
      process_direct(hash["MGREP"], ontology_hash, job)
      process_direct(hash["MAPPING"], ontology_hash, job, true)
      job.update_attributes(finished_at: Time.now)
    end

    def process_direct(hash, ontology_hash, job, mapping=false)
      hash.keys.each do |key|
        current_ncbo_id, term_id = key.split("|")
        Resque.enqueue(OntologyTerm, {action: 'save', term_id: term_id, ncbo_id: ontology_hash[hash[key][:local_ontology_id]].to_i, term_name: hash[key][:name]})
        Resque.enqueue(Annotation, {
                   action: 'save',
                   document_id: job.document_id,
                   ncbo_id: ontology_hash[hash[key][:local_ontology_id]].to_i,
                   ontology_term_id: term_id,
                   ontology_term_name: hash[key][:name],
                   field_name: job.field_name,
                   field_value: job.field_value,
                   starts_at: hash[key][:from].to_i,
                   ends_at: hash[key][:to].to_i,
                   synonym: hash[key][:synonym],
                   mapping: mapping
                   })
      end
    end
  end #of self

end
