using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    class PausedMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :resume) {
                _controller.resume();
                return true;
            } else if (item == :save) {
                _controller.save();
                return true;
            } else if (item == :discard) {
                _controller.discard();
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