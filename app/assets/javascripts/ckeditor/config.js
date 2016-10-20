CKEDITOR.editorConfig = function (config) {
    config.extraPlugins = 'imgur';
    // Get your client-id from https://api.imgur.com/oauth2/addclient
    config.imgurClientID = '4005c71208be9df';
    config.toolbar_mini = [
      ['Styles', 'Format', 'Font', 'FontSize'],
      ["Bold",  "Italic",  "Underline",  "Strike",  "-",  "Subscript",  "Superscript"],
      ['Image', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar'],
      ['CreateDiv'],['pbckcode']
    ];
    config.toolbar_Full = [['Undo', 'Redo', '-', 'SelectAll', 'RemoveFormat'],
                           ['Styles', 'Format', 'Font', 'FontSize'],
                           ['TextColor', 'BGColor'],
                           ['Maximize', 'ShowBlocks', '-', 'About'], '/',
                           ['Bold', 'Italic', 'Underline', 'Strike', '-', 'Subscript', 'Superscript'],
                           ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', 'Blockquote', 'CreateDiv'],
                           ['JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock'],
                           ['Link', 'Unlink', 'Anchor'],
                           ['Image', 'Table', 'HorizontalRule', 'Smiley', 'SpecialChar', 'PageBreak']];
    config.toolbar = "simple";
    config.extraPlugins = 'pbckcode';

}
