class AnnotationJob
  include Mongoid::Document
  include Mongoid::Timestamps

  field :ncbo_id, :type => Integer
  field :document_id, :type => String
  field :field_name, :type => String
  field :field_value, :type => String

  field :started_at, :type => DateTime
  field :finished_at, :type => DateTime

  index(
    [
      [ :ncbo_id, Mongo::ASCENDING ],
      [ :document_id, Mongo::ASCENDING ],
      [ :field_name, Mongo::ASCENDING ]
    ],
    unique: true)

  @queue = :processing

  class << self

    def perform(hash)
      case hash['action']
        when 'generate'
          self.generate_jobs(hash['ncbo_id'])
      end
    end

    def generate_jobs(ncbo_id)
      Document.all.each do |document|
        (document.attributes.keys-['_id']).each do |field_name|
          field_value = document.do_or_do_not(field_name)
          if !field_value.blank?
            Rails.logger.debug(field_value)
            job = AnnotationJob.new(ncbo_id: ncbo_id, document_id: document.id, field_name: field_name, field_value: field_value)
            if job.save
              Resque.enqueue(AnnotationProcessor, job.id)
            end
          end
        end
      end
    end
  end

end
