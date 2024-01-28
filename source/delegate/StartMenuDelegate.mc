using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    // This delegate handles input for the Menu pushed when the user
    // selects the sport
    class StartMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller;
        private var _activityMenuItem as Ui.MenuItem;
        private var _gpsSettingsMenuItem as Ui.MenuItem;

        function initialize(activityMenuItem as Ui.MenuItem, gpsSettingsMenuItem as Ui.MenuItem) {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
            _activityMenuItem = activityMenuItem;
            _gpsSettingsMenuItem = gpsSettingsMenuItem;
        }

        // Handle the menu input
        function onSelect(item) {
            var id = item.getId();
            if (id == :start) {
                _controller.start();
            } else if (id == :select_activity) {
                _controller.onSelectActivity(_activityMenuItem);
            } else if (id == :select_gps_settings) {
                _controller.onShowGpsSettings(_gpsSettingsMenuItem);
            }
        }
    }
}