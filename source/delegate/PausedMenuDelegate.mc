using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    class PausedMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller;
        private var _gpsSettingsMenuItem as Ui.MenuItem;

        function initialize(gpsSettingsMenuItem as Ui.MenuItem) {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
            _gpsSettingsMenuItem = gpsSettingsMenuItem;
        }

        function onBack() {
            _controller.start();
        }

        // Handle the menu input
        function onSelect(item) {
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