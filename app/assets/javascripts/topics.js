"use strict";

$(document).ready(function(){

  $(".edit-post").click(function(){
    if (EditorIsOpen()){
      alert("You have a pending edit unsaved. Please save or cancel it before proceeding.")
    }else {
      OpenPostEditor.call(this);
    }
  });

  $(".cancel-edit").click(function(){
    if (confirm("All changes made will be lost. Would you like to continue?")) {
      ClosePostEditor.call(this);
    }
  });

  $(".save-post").click(function(){
    var postId = $(this).data("id");

    $.ajax({
      method: "PUT",
      url: "/posts/" + postId,
      data: { body: $(this).parent().parent().find(".edit-body-textarea").val() }
    });

    console.log("Post save data sent.");
  });
});

function OpenPostEditor(){
  $(this).parent().siblings(".post-body").hide();
  $(this).parent().siblings(".post-editor").show();
}

function ClosePostEditor(){
  $(this).parent().parent().siblings(".post-body").show();
  $(this).parent().parent().hide();
}

function EditorIsOpen(){
  var opened = false;

  $(".post-editor").each(function(){
    if ($(this).is(":visible")){
      opened = true;
      return false;
    }
  });
  return opened;
}