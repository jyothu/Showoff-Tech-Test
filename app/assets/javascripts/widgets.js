$( document).on('turbolinks:load', function() {
  $('.modal-trigger-button').click(function(e) {
    $('.modal').removeClass('is-active');
    $("#" + e.currentTarget.dataset.target).addClass('is-active');
  });

  $('.modal-close').click(function(e) {
    $('.modal').removeClass('is-active');
  });
});