const toastr = require('toastr');

toastr.options.progressBar = true;
toastr.options.closeDuration = 250;
toastr.options.timeOut = 3000;

$.extend({
  flash(options) {
    if ('alert' in options) {
      toastr.error(options.alert);
    } if ('info' in options) {
      toastr.info(options.info);
    }
    toastr.success(options.notice);
  },

  alert(text) {
    if (text) {
      toastr.error(text);
    }
  },

  info(text) {
    if (text) {
      toastr.info(text);
    }
  },

  notice(text) {
    if (text) {
      toastr.success(text);
    }
  }
});
