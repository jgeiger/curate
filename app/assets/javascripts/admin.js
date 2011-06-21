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
        load_curators();
      }, "json");
    }
    return false;
  });
}

function bindRightClicks() {
  $("a.curate.manual-annotation").contextMenu({
    menu: 'delete-menu'
  },
  function(action, el, pos) {
    var id = $(el).attr("id").split('-')[1];
    if (action === 'delete') {
      var row;
      var href = "/annotations/"+id;
      $(el).next().remove();
      if ($(el).siblings().size() === 0) {
        row = $(el).parent().parent().parent();
      }
      $(el).remove();
      if (row) {
        $(row).remove();
      }
      $.post(href, "_method=delete", function(data){
        displayResult(data);
        load_curators();
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
        load_curators();
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
      load_curators();
    }, "json");
    return false;
  });

  $("span.invalidate-all").live("click", function(){
    var boxes = processChecked(false);
    $.post('/annotations/mass_curate', boxes.serialize()+"&verified=0", function(data){
      filter_submit();
      load_curators();
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

  bindCurate();
  bindRightClicks();

  $("a.dataset-child-link").live("click", function(e){
    var sort_by = $(this).attr("sort_by");
    $('.dataTable').load($(this).attr('href'), function() {});
    return false;
  });

});

