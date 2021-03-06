class AnnotationJobsController < ApplicationController

  before_filter :check_cancel, :only => [:create]
  before_filter :admin_required, :except => [:status]

  def index
    page = (params[:page].to_i > 0) ? params[:page] : 1
    @annotation_jobs = AnnotationJob.order_by([:created_at, :desc]).page(page)
  end

  def new
    @annotation_job = AnnotationJob.new
    @ontologies = Ontology.where(hidden: false).order_by([ :name, :asc ])
  end

  def create
    job = AnnotationJob.new(params[:annotation_job])
    Resque.enqueue(AnnotationJob, {action: 'generate', ncbo_id: job.ncbo_id})
    redirect_to(annotation_jobs_url, notice: "Jobs have been created.")
  end

  protected

  def check_cancel
    redirect_to(annotation_jobs_url) and return if (params[:commit] == t('label.cancel'))
  end

end
