$(function(){
  $("input[type=checkbox]").click(function(){
    if($(this).prop("checked") == true){
      console.log($(this).val());
    }
    else if($(this).prop("checked") == false){
      console.log("unchecked");
    }
  });

});
