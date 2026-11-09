import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

// This delegate handles input for the Menu pushed when the user
// selects the sport
module delegate {
    class ActivityInputDelegate extends Ui.Menu2InputDelegate {

        private var _controller as Controller;
        private var _parentMenuItem as Ui.MenuItem;

        function initialize(parentMenuItem as Ui.MenuItem) {
            Menu2InputDelegate.initialize();
            _controller = (Application.getApp() as BatteryApp).getController();
            _parentMenuItem = parentMenuItem;
        }

        // Handle the menu input
        function onSelect(item as Ui.MenuItem) as Void {
            var id = item.getId() as Number;
            _controller.setActivity(id);
            _parentMenuItem.setSubLabel(_controller.getActivityName());
        }
    }
}