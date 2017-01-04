//= require form-validator/jquery.form-validator.min
//= require form-validator/sanitize

$.formUtils.loadModules('sanitize, html5, security', null, function () {
   console.log('modules loaded...');
   console.log($.formUtils.validators);
}); 