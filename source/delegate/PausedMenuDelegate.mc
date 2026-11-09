import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    class PausedMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller as Controller;
        private var _gpsSettingsMenuItem as Ui.MenuItem or Null;

        function initialize(gpsSettingsMenuItem as Ui.MenuItem or Null) {
            Menu2InputDelegate.initialize();
            _controller = (Application.getApp() as BatteryApp).getController();
            _gpsSettingsMenuItem = gpsSettingsMenuItem;
        }

        // Backing out of the menu resumes the activity
        function onBack() as Void {
            _controller.start();
        }

        // Handle the menu input
        function onSelect(item as Ui.MenuItem) as Void {
            var id = item.getId();
            if (id == :resume) {
                _controller.start();
            } else if (id == :save) {
                _controller.save();
            } else if (id == :discard) {
                _controller.discard();
            } else if (id == :select_gps_settings) {
                _controller.onShowGpsSettings(_gpsSettingsMenuItem);
            }
        }
    }
}