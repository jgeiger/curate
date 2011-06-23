class AnnotationsController < ApplicationController

  before_filter :admin_required, :only => [:audit, :valid, :invalid, :curate]
  before_filter :load_annotation, :only => [:curate, :predicate, :destroy]

  def index
    set_ontology_dropdown
    @query = params[:query] ? Regexp.escape(params[:query]) : ""
    page = (params[:page].to_i > 0) ? params[:page] : 1
    @annotations = Annotation.where(ontology_term_name: /^#{@query}/i, ncbo_id: @ncbo_id).order_by([[:ontology_term_name, :asc], [:document_id, :asc], [:field_name, :asc]]).page(page)

    respond_to do |format|
      format.html {}
      format.js  {
        render(:partial => "annotations_list.html.haml")
      }
    end
  end

  def audit
    set_status_dropdown
    set_has_predicate_dropdown
    set_ontology_dropdown

    @query = params[:query] ? Regexp.escape(params[:query]) : ""
    page = (params[:page].to_i > 0) ? params[:page] : 1

    annotations = Annotation.where(:ontology_term_name => /^#{@query}/i, ncbo_id: @ncbo_id)

    case @status
      when "All"
        annotations = annotations.where(:status.ne => 'skip')
      when "Valid"
        annotations = annotations.where(verified: true, status: 'audited')
      when "Invalid"
        annotations = annotations.where(verified: false, status: 'audited')
      when "Unaudited"
        annotations = annotations.where(status: 'unaudited')
    end

    case @has_predicate
      when "No"
        annotations = annotations.where(predicate: '')
      when "Yes"
        annotations = annotations.excludes(predicate: '')
    end

    @annotations = annotations.order_by([[:ontology_term_name, :asc], [:field_name, :asc]]).page(page)

    respond_to do |format|
      format.html { }
      format.js  {
          render(:partial => "annotations/audit_list.html.haml")
        }
    end
  end

  def create
    term_name, term_id =  params[:annotation].delete('ontology_term_id').split('||')
    @annotation = Annotation.new(params[:annotation].merge!(:ontology_term_name => term_name, :ontology_term_id => term_id))
    OntologyTerm.create(term_id: @annotation.ontology_term_id, ncbo_id: @annotation.ncbo_id, term_name: @annotation.ontology_term_name)
    @annotation.predicate = case @annotation.ncbo_id
      when 1150
        'strain_used'
      when 1006
        'cell_used'
      when 1007
        'chemical_used'
      when 1423
        'drug_used'
      when 1000
        'tissue'
      else
        ''
      end

    respond_to do |format|
      format.js {
        if @annotation.save
          @document = Document.find(@annotation.document_id)
          @result = {'status' => "success", 'message' => "Annotation successfully saved!"}
        else
          errors = @annotation.errors.full_messages.join("\n")
          @result = {'status' => "failure", 'message' => "ERROR: #{errors}"}
        end
      }
    end
    rescue Exception => e
     @result = {'status' => "failure", 'message' => "ERROR: #{e.inspect}"}
  end

  def mass_curate
    ids = params[:selected_annotations]
    verified = params[:verified] == "1" ? true : false
    if ids
      Annotation.any_in(_id: ids).update_all(verified: verified, status: 'audited', curated_by_id: current_user.id, updated_at: Time.now)
    end
    render(:json => ids.to_json)
  end

  def curate
    @annotation.set_status(current_user.id)
    hash = {:result => @annotation.verified?, :css_class => "predicate-#{@annotation.predicate}"}
    render(:json => hash.to_json)
  end

  def predicate
    @annotation.predicate = params[:predicate]
    @annotation.save
    hash = {:result => @annotation.verified?, :css_class => "predicate-#{@annotation.predicate}"}
    render(:json => hash.to_json)
  end

  def destroy
    if @annotation.destroy
      render(:json => {'status' => "success", 'message' => "Annotation successfully deleted."})
    else
      render(:json => {'status' => "failure", 'message' => "ERROR: #{e.inspect}"})
    end
  end

  protected

  def load_annotation
    @annotation = Annotation.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      redirect_to(annotations_url, warning: "That annotation does not exist.")
  end

  def set_ontology_dropdown
    @ncbo_id = params[:ncbo_id] ? params[:ncbo_id] : Annotation.first ? Annotation.first.ncbo_id : ""
  end

  def set_exclude_dropdown
    @exclude = params[:exclude] ? params[:exclude] : false
  end

  def set_status_dropdown
    @status = params[:status] ? params[:status] : "Unaudited"
  end

  def set_has_predicate_dropdown
    @has_predicate = params[:has_predicate] ? params[:has_predicate] : 'No'
  end

end
