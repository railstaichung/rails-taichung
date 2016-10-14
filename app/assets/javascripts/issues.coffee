# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
    $('.datatable').DataTable({
      "autoWidth":false;
      "columnDefs": [
          { "width": "70%", "targets": 0 },
          { "width": "20%", "targets": 1 },
          { "width": "10%", "targets": 2 }]
        });
