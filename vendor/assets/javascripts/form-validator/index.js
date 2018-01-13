//= require form-validator/jquery.form-validator.min
//= require form-validator/sanitize
//= require form-validator/html5
//= require form-validator/security
//= require form-validator/toggleDisabled

$.formUtils.loadModules('sanitize, html5, security', null, function () {
   // console.log('modules loaded...');
   // console.log($.formUtils.validators);
});
