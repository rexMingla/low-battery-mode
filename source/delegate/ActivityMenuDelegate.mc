using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the sport
module delegate {
    class ActivityMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :run) {
                _controller.setActivity(ActivityRecording.SPORT_RUNNING);
                return true;
            } else if (item == :bike) {
                _controller.setActivity(ActivityRecording.SPORT_CYCLING);
                return true;
            } else if (item == :swim) {
                _controller.setActivity(ActivityRecording.SPORT_SWIMMING);
                return true;
            } else {
                _controller.setActivity(ActivityRecording.SPORT_GENERIC);
                return true;
            }
            return false;
        }
    }
}