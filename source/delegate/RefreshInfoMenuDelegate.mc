using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    class RefreshInfoMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;
        private var _type;

        function initialize(type) {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
            _type = type;
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :always) {
                setRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_ALWAYS, null));
                return true;
            } else if (item == :never) {
                setRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_NEVER, null));
                return true;
            } else if (item == :customFiveSec) {
                setRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_CUSTOM, 5));
                return true;
            } else if (item == :customTenSec) {
                setRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_CUSTOM, 10));
                return true;
            } else if (item == :customThirtySec) {
                setRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_CUSTOM, 30));
                return true;
            } else if (item == :customSixtySec) {
                setRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_CUSTOM, 60));
                return true;
            }
            return false;
        }

        private function setRefreshInfo(info) {
            if (_type == data.RefreshInfo.REFRESH_TYPE_GPS) {
                _controller.setGpsRefreshInfo(info);
            } else {
                _controller.setSensorRefreshInfo(info);
            }
        }
    }
}