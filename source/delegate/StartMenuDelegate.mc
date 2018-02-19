using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    // This delegate handles input for the Menu pushed when the user
    // selects the sport
    class StartMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :start) {
                _controller.start();
                return true;
            } else if (item == :select_activity) {
                _controller.onSelectActivity();
                return true;
            } else if (item == :select_gps) {
                _controller.onSelectGpsMode();
                return true;
            } else if (item == :select_sensor) {
                _controller.onSelectSensorMode();
                return true;
            }
            return false;
        }
    }
}