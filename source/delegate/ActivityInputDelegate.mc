using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the sport
module delegate {
    class ActivityInputDelegate extends Ui.Menu2InputDelegate {

        private var _controller;
        private var _parentMenuItem as Ui.MenuItem;

        function initialize(parentMenuItem as Ui.MenuItem) {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
            _parentMenuItem = parentMenuItem;
        }

        // Handle the menu input
        function onSelect(item) {
            var id = item.getId();
            _controller.setActivity(id);
            _parentMenuItem.setSubLabel(_controller.getActivityName());
            return false;
        }
    }
}