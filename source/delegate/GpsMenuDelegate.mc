import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    class GpsMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller as Controller;
        private var _parentMenuItem as Ui.MenuItem or Null;

        function initialize(parentMenuItem as Ui.MenuItem or Null) {
            Menu2InputDelegate.initialize();
            _controller = (Application.getApp() as BatteryApp).getController();
            _parentMenuItem = parentMenuItem;
        }

        // Handle the menu input
        function onSelect(item as Ui.MenuItem) as Void {
            var value = item.getId() as Number;
            _controller.setGpsSettings(value);
            var parentMenuItem = _parentMenuItem;
            if (parentMenuItem != null) {
                parentMenuItem.setSubLabel(_controller.getGpsSettingsName());
            }
        }
    }
}