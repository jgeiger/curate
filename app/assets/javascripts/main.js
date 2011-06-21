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
  m.format = 'js';
  m._method = "get";

  if ($("#ncbo_id").length > 0) {
    m.ncbo_id = $("#ncbo_id").val();
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

  $(".dataTable").load(window.location.pathname, m, function() {
    if(typeof set_bindings === 'function') {
      set_bindings();
    }
  });

  return false;
}

function delayKey() {
  count = count + 1;
  setTimeout("fireSubmit("+count+")", 1000);
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
  $("#loading").ajaxStart(function() {
     $(this).show();
   }).ajaxStop(function() {
     $(this).hide();
   });

   // make sure we accept javascript for ajax requests
  jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}});

  $(".pagination a").live('click', function(){
    var href = $(this).attr('href');
    var dtable = $(this).closest('.dataTable');
    var atype = dtable.attr('atype');
    var auth_param = $('meta[content=csrf-param]').val();
    $.get(href, {'annotation_type' : atype, authenticity_token: auth_param, format: 'js' }, function(data) {
      dtable.html(data);
    }, 'html');
    return false;
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

// dynamically load the items based on query filter

  $("#refresh").bind("click", filter_submit);
  $("#ncbo_id").bind("change", filter_submit);
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


  $(".annotation-table:has(a)").show();

});

