// Common JavaScript code across your application goes here.
var count = 0;

$.fn.allMatchTallestHeight = function() {
  var max_height = 0;
  var elements = $(this);
  elements.each( function() {
    if ($(this).height() > max_height) {
      max_height = $(this).height();
    }
  });

  elements.each( function() {
    $(this).height(max_height);
  });
};


function filter_submit() {
  var m = {};
  m._method = "get";

  if ($("#ddown").length > 0) {
    m.ddown = $("#ddown").val();
  }

  if ($("#status").length > 0) {
    m.status = $("#status").val();
  }

  if ($("#exclude").length > 0) {
    m.exclude = $("#exclude").val();
  }

  if ($("#query").length > 0) {
    m.query = $("#query").val();
  }

  if ($("#has_predicate").length > 0) {
    m.has_predicate = $("#has_predicate").val();
  }

  if ($("#has_tag").length > 0) {
    m.has_tag = $("#has_tag").val();
  }

  if ($("#has_annotations").length > 0) {
    m.has_annotations = $("#has_annotations").val();
  }

  $(".dataTable").load(window.location.pathname+'.js', m, function() {
    if(typeof set_bindings === 'function') {
      set_bindings();
    }
  });

  return false;
}

function update_filter_text() {
  var term_array = [];
  $("#term-parameters :hidden").each( function() {
    var term_name = $(this).attr("term_name");
    var term_id = $(this).attr("id");
    var link = "<a href='#' class='delete-result' term_id='"+term_id+"'><img src='/images/icons/error.png' border='0' class='delete-icon' /></a><span class='result-filter'>"+term_name+"</span>";
    term_array.push(link);
  });

  var term_string = term_array.join(" AND ");
  $("#filters").html(term_string);
}

function update_results() {
  $.get("/annotations/cloud", $("#term-parameters>:input").serialize(), function(data){}, "script");
}

function add_parameter_field(term_id, term_name) {
  var element = document.createElement("input");
  element.setAttribute("type", "hidden");
  element.setAttribute("value", term_id);
  element.setAttribute("id", term_id);
  element.setAttribute("name", "term_array[]");
  element.setAttribute("term_name", term_name);
  $(element).appendTo("#term-parameters");
}

function attach_term_hook() {
  $("a.result-term").live("click", function(){
    var term_id = $(this).attr("term_id");
    var term_name = $(this).html();
    try {
      pageTracker._trackPageview("/annotations/cloud/add/term/"+term_id);
    } catch(err) {}
    add_parameter_field(term_id, term_name);
    update_filter_text();
    update_results();
    return false;
  });
}

function remove_parameter_field(term_id) {
  $("#term-parameters :hidden").each( function() {
    if ($(this).attr("id") === term_id) {
      $(this).remove();
    }
  });
}

function attach_filter_hook () {
  $("a.delete-result").live("click", function(){
    var term_id = $(this).attr("term_id");
    remove_parameter_field(term_id);
    try {
      pageTracker._trackPageview("/annotations/cloud/remove/term/"+term_id);
    } catch(err) {}
    update_filter_text();
    update_results();
    return false;
  });
}

function delayKey() {
  count = count + 1;
  setTimeout("fireSubmit("+count+")", 750);
}

function fireSubmit(currCount) {
  if(currCount === count) {
    count = 0;
    filter_submit();
  }
}

// set for merb/rails to get that we're using JS
$(function() {

  // display the loading graphic during ajax requests
  $("#loading").ajaxStart(function(){
     $(this).show();
   }).ajaxStop(function(){
     $(this).hide();
   });

   // make sure we accept javascript for ajax requests
  jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}});


  $(".cloud_pagination a").live("click", function(){
    var href = $(this).attr('href');
    $.get(href, {}, function(data){}, "script");
    return false;
  });

  $(".data_pagination a").live('click', function(){
    var href = $(this).attr('href');
    var dtable = $(this).closest('.dataTable');
    var atype = dtable.attr('atype');
    var auth_param = $('meta[content=csrf-param]').val();
    $.get(href, {'annotation_type' : atype, authenticity_token: auth_param, format: 'js' }, function(data) {
      dtable.html(data);
    }, 'html');
    return false;
  });

  $(".cloud-box-content").allMatchTallestHeight();

  $(".view-graph").live("click", function(){
    $(".bar-graph").toggle();
  });

  $("div.tooltip").hover( function() {
      $(this).find('.popup').show();
    },
    function() {
      $(this).find('.popup').hide();
  });

  $("a.annotation-term").mouseover( function() {
    $(this).addClass("inset");
    if ($('#'+$(this).attr("field_name")).length > 0) {
      var from = $(this).attr('from')-1;
      var to = $(this).attr('to');
      var text = $.trim(Utf8.encode($('#'+$(this).attr("field_name")).html())).slice(from, to);
      $('#'+$(this).attr("field_name")).highlight(text);
    }
  }).mouseout( function() {
    $(this).removeClass("inset");
    if ($('#'+$(this).attr("field_name")).length > 0) {
      $('#'+$(this).attr("field_name")).removeHighlight();
    }
  });

  $("#loading").ajaxStart(function(){
     $(this).show();
   }).ajaxStop(function(){
     $(this).hide();
   });

// dynamically load the items based on query filter

  $("#ddown").bind("change", filter_submit);
  $("#status").bind("change", filter_submit);
  $("#exclude").bind("change", filter_submit);
  $("#has_predicate").bind("change", filter_submit);
  $("#has_tag").bind("change", filter_submit);
  $("#has_annotations").bind("change", filter_submit);
  $("#query").keypress(function(e) {
    if (e.which !== 0 && e.charCode !== 0) {
      delayKey();
    }
  });

  $("#query").keyup(function(e) {
    if (e.keyCode === 8 || e.keyCode === 46) {
      delayKey();
    }
  });

  $("#refresh").bind("click", filter_submit);

  attach_term_hook();
  attach_filter_hook();

  $(".annotation-table:has(a)").show();

});

