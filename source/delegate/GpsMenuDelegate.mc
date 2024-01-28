using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Position;

module delegate {
    class GpsMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller;
        private var _parentMenuItem as Ui.MenuItem;

        function initialize(parentMenuItem as Ui.MenuItem) {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
            _parentMenuItem = parentMenuItem;
        }

        // Handle the menu input
        function onSelect(item) {
            var value = item.getId();
            _controller.setGpsSettings(value);
            _parentMenuItem.setSubLabel(_controller.getGpsSettingsName());
            return false;
        }
    }
}