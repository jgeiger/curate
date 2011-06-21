module AnnotationsHelper

  def ontology_search_dropdown(current)
    select_tag(:ncbo_id, options_from_collection_for_select(Ontology.which_have_annotations, :ncbo_id, :name, current.to_i))
  end

  def annotation_status_dropdown(current)
    select_tag(:status, options_for_select(["Unaudited", "Valid", "Invalid", "All"], current))
  end

  def exclude_dropdown(current)
    select_tag(:exclude, options_for_select([["Exclude", false], ["Include only", true]], current))
  end

  def has_predicate_dropdown(current)
    select_tag(:has_predicate, options_for_select([["Yes", 'Yes'], ["No", 'No']], current))
  end

end
