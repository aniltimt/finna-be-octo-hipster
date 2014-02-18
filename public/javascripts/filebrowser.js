var FileBrowserDialogue = {
  init : function () {
  },
  mySubmit : function (URLselected) {
    var win = tinyMCEPopup.getWindowArg("window");
    win.document.getElementById(tinyMCEPopup.getWindowArg("input")).value = URLselected;
    if (win.ImageDialog.showPreviewImage)  win.ImageDialog.showPreviewImage(URLselected);
    tinyMCEPopup.close();

  }
}

tinyMCEPopup.onInit.add(FileBrowserDialogue.init, FileBrowserDialogue);