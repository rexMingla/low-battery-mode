import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    // Handles input for the menu shown before the activity starts
    class StartMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller as Controller;
        private var _activityMenuItem as Ui.MenuItem;
        private var _gpsSettingsMenuItem as Ui.MenuItem or Null;

        function initialize(activityMenuItem as Ui.MenuItem, gpsSettingsMenuItem as Ui.MenuItem or Null) {
            Menu2InputDelegate.initialize();
            _controller = (Application.getApp() as BatteryApp).getController();
            _activityMenuItem = activityMenuItem;
            _gpsSettingsMenuItem = gpsSettingsMenuItem;
        }

        // Handle the menu input
        function onSelect(item as Ui.MenuItem) as Void {
            var id = item.getId();
            if (id == :start) {
                _controller.start();
            } else if (id == :select_activity) {
                _controller.onSelectActivity(_activityMenuItem);
            } else if (id == :select_gps_settings) {
                _controller.onShowGpsSettings(_gpsSettingsMenuItem);
            } else if (id == :quit) {
                _controller.onExit();
            }
        }
    }
}