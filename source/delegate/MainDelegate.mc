import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    class MainDelegate extends Ui.BehaviorDelegate {

        private var _controller as Controller;

        function initialize() {
            BehaviorDelegate.initialize();
            _controller = (Application.getApp() as BatteryApp).getController();
        }

        // Input handling of start/stop is mapped to onSelect
        function onSelect() as Boolean {
            _controller.onStartStop();
            return true;
        }

        // start lap
        function onBack() as Boolean {
            if (!_controller.hasStarted()) {
                _controller.onExit();
                return true;
            }
            if (!_controller.isRunning()) {
                return true;
            }
            _controller.onLap();
            return true;
        }

        // Block access to the menu button
        function onMenu() as Boolean {
            return true;
        }

        function onNextPage() as Boolean {
            _controller.cycleView(1);
            return true;
        }

        function onPreviousPage() as Boolean {
            _controller.cycleView(-1);
            return true;
        }
    }
}