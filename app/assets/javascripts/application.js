// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require turbolinks
//= require es6-promise.auto
//= require sweetalert2
//= require form-validator
//= require_tree .

function validateFiles(inputFile) {
  var maxExceededMessage = "This file exceeds the maximum allowed file size (300 KB)";
  var extErrorMessage = "Only image file with extension: .jpg, .jpeg, .gif or .png is allowed";
  var maxExtErrorMessage = "This file exceeds the maximum allowed file size (300 KB) \nand is not allowed file extension (only .jpg, .jpeg, .gif or .png)";
  var allowedExtension = ["jpg", "jpeg", "gif", "png"];

  var extName;
  var maxFileSize = $(inputFile).data('max-file-size');
  var sizeExceeded = false;
  var extError = false;

  $.each(inputFile.files, function() {
    if (this.size && maxFileSize && this.size > parseInt(maxFileSize)) {sizeExceeded=true;};
    extName = this.name.split('.').pop();
    if ($.inArray(extName, allowedExtension) == -1) {extError=true;};
  });
  if (sizeExceeded && extError) {
    window.alert(maxExtErrorMessage);
    $(inputFile).val('');
  };

  if (sizeExceeded && extError == false) {
    window.alert(maxExceededMessage);
    $(inputFile).val('');
  };

  if (extError && sizeExceeded == false) {
    window.alert(extErrorMessage);
    $(inputFile).val('');
  };

}