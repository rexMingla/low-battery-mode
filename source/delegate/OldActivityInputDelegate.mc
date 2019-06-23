using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the sport
// needed because the new one is only supported in >=3.0 sdk
module delegate {
    class OldActivityInputDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(id) {
            _controller.setActivity(id);
            return false;
        }
    }
}