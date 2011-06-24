function markValid(object) {
  object.removeClass("unaudited unverified predicate-text predicate-tissue predicate-cell_used predicate-strain_used predicate-chemical_used predicate-").addClass("verified");
}

function markInvalid(object) {
  object.removeClass("unaudited verified predicate-text predicate-tissue predicate-cell_used predicate-strain_used predicate-chemical_used predicate-").addClass("unverified");
}

function updateCSS(data, object) {
  if (data.result) {
    markValid(object);
    set_annotation_css(object, data.css_class);
  } else {
    markInvalid(object);
  }
  set_bindings();
}

function set_annotation_css(element, css_class) {
  element.removeClass('predicate-text predicate-tissue predicate-cell_used predicate-strain_used predicate-chemical_used predicate-').addClass(css_class);
}

function bindCurate() {
  // updates the clicked link's curation status
  $("a.curate").unbind('click.curate').bind('click.curate', function() {
    var link = $(this);
    var href = link.attr("href");
    if (link.hasClass('automatic-annotation')) {
      $.post(href, {}, function(data) {
        updateCSS(data, link);
        }, "json");
    }
    return false;
  });
}

function bindRightClicks() {
  $(".annotate").contextMenu({
      menu: 'annotation-menu'
    },
    function(ontology, el, pos) {
      var txt = getSelectedText();
      if (txt != '') {
        hash = getSelectedInformation(txt, el);
        $('#new-annotation').css({top: (pos.docY-125), left: (pos.docX-250)});
        ontology_class = "bp_form_complete-"+ontology+"-shortid";
        $("input#annotation_ontology_term_id").removeClass();
        $("input#annotation_ontology_term_id").addClass(ontology_class);
        unbindEvents();
        setup_functions();
        $("input#annotation_ontology_term_id").val(hash.text);
        $("input#annotation_ncbo_id").val(ontology);
        $("input#annotation_starts_at").val(hash.starts_at);
        $("input#annotation_ends_at").val(hash.ends_at);
        $("input#annotation_field_name").val(hash.field_name);
        $("input#annotation_field_value").val(hash.field_value);
        $("#new-annotation").show();
        $("input#annotation_ontology_term_id").focus();
        $("input#annotation_ontology_term_id").keydown();
    }
    return false;
  });

  $("a.curate.manual-annotation").contextMenu({
    menu: 'delete-menu'
  },
  function(action, el, pos) {
    var id = $(el).attr("id").split('-')[1];
    if (action === 'delete') {
      var row;
      var href = "/annotations/"+id;
      $(el).next().remove();
      $(el).remove();
      $.post(href, "_method=delete", function(data){
        displayResult(data);
        }, "json");
    } else {
      set_bindings();
    }
    return false;
  });
  
  $("a.curate.automatic-annotation.verified").contextMenu({
    menu: 'annotation-type-menu'
  },
  function(action, el, pos) {
    if ($(el).hasClass('verified')) {
      var id = $(el).attr("id").split('-')[1];
      $.post("/annotations/"+id+'/predicate', {predicate: action, format: 'js'}, function(data){
        updateCSS(data, $(el));
        }, "json");
    }
    return false;
  });
}

function set_bindings() {
  bindCurate();
  bindRightClicks();
}

function setBoxes(status) {
  var boxes = $(":checkbox[name='selected_annotations[]']");
  boxes.each(function() {
    $(this).attr('checked', status);
  });
}

function processChecked(isValid) {
  var boxes = $(":checkbox[name='selected_annotations[]']:checked");
  boxes.each(function() {
    var link = $("#link-"+$(this).val());
    if (isValid) {
      markValid(link);
    } else {
      markInvalid(link);
    }
    $(this).remove();
  });
  return boxes;
}

function getSelectedInformation(t, element) {
  var txt = t.toString();
  var text = jQuery.trim(txt);
  var len = text.length;
  var full = jQuery.trim($(element).text());
  var field_name = $(element).attr("field_name");
  var field_value = $(element).attr("field_value");
  var starts_at = full.indexOf(text)+1;
  var ends_at = starts_at+len-1;
  var hash = {'starts_at':starts_at, 'ends_at':ends_at, 'text':text, 'field_name':field_name, 'field_value':field_value};
  return hash;
}

function displayResult(data) {
  $("#annotation-result").removeClass();
  $("#annotation-result").addClass(data.status);
  $("#annotation-result").text(data.message);
  $("#annotation-result").fadeIn("fast", function() {
    $("#new-annotation").hide();
  }).fadeTo(2000, 1).fadeOut("fast");
  bindCurate();
  bindRightClicks();
}

function getSelectedText() {
  var txt = '';
  if (window.getSelection) {
    txt = window.getSelection();
  // FireFox
  } else if (document.getSelection) {
    txt = document.getSelection();
  // IE 6/7
  } else if (document.selection) {
    txt = document.selection.createRange().text;
  }
  return txt;
}

function unbindEvents() {
  $("input[class*='bp_form_complete']").each(function(){
    $(this).unbind();
  });
}

function submit_annotation() {
  $.post("/annotations", $("#new_annotation input").serialize(), function() {}, "script");
  return false;
}

$(function() {

  $("#show").live("click", function(){
    $(this).hide();
    $(this).next().show();
    return false;
  });

  $("#hide").live("click", function(){
    $(this).parent().hide();
    $(this).parent().prev().show();
    return false;
  });

  $("input.cancel").live("click", function(){
    $("#new-annotation").hide();
    return false;
  });

// marks all the checked boxes as valid, and removes the checkboxes from the form
  $("span.validate-all").live("click", function(){
    var boxes = processChecked(true);
    $.post('/annotations/mass_curate', boxes.serialize()+"&verified=1", function(data){
      filter_submit();
    }, "json");
    return false;
  });

  $("span.invalidate-all").live("click", function(){
    var boxes = processChecked(false);
    $.post('/annotations/mass_curate', boxes.serialize()+"&verified=0", function(data){
      filter_submit();
    }, "json");
    return false;
  });

  $("a.check-all").live("click", function(){
    setBoxes(true);
    return false;
  });

  $("a.uncheck-all").live("click", function(){
    setBoxes(false);
    return false;
  });

  $(".context").live("click", function(){
    $(this).children("div").toggle();
    return false;
  });

  $("a.dataset-child-link").live("click", function(e){
    var sort_by = $(this).attr("sort_by");
    $('.dataTable').load($(this).attr('href'), function() {});
    return false;
  });

  $("#new_annotation").bind("submit", submit_annotation);

  $("input#annotation_cancel").bind("click", function(){
    $("#new-annotation").hide();
    return false;
  });

  $(".ontology-status").live("click", function(){
    var link = $(this);
    var id = link.attr('id');
    $.post('/ontologies/'+id+'/toggle_hidden', {}, function(data) {
      link.html(data.result);
      link.removeClass("ontology-shown ontology-hidden").addClass(data.css_class);
    }, "json");
    return false;
  });

  bindCurate();
  bindRightClicks();

});

