# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$('.datetimepicker').datetimepicker()

$(document).ready ->
  $('.form_datetime').datetimepicker({
    autoclose: true,
    todayBtn: true,
    pickerPosition: "bottom-left",
    format: 'yyyy-mm-dd hh:ii:ss'
  });

jQuery ->
  new PhotoCropper()

class PhotoCropper
  constructor: ->
    $('#cropbox').Jcrop
      aspectRatio: 2/1
      setSelect: [0, 0, 1080, 540]
      onSelect: @update
      onChange: @update

  update: (coords) =>
    $('#event_crop_x').val(coords.x)
    $('#event_crop_y').val(coords.y)
    $('#event_crop_w').val(coords.w)
    $('#event_crop_h').val(coords.h)
    @updatePreview(coords)

  updatePreview: (coords) =>
    $('#preview').css
        width: Math.round(100/coords.w * $('#cropbox').width()) + 'px'
        height: Math.round(100/coords.h * $('#cropbox').height()) + 'px'
        marginLeft: '-' + Math.round(100/coords.w * coords.x) + 'px'
        marginTop: '-' + Math.round(100/coords.h * coords.y) + 'px'
