using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Application;

module delegate {
    class MainDelegate extends Ui.BehaviorDelegate {

        private var _controller;

        function initialize() {
            BehaviorDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Input handling of start/stop is mapped to onSelect
        function onSelect() {
            _controller.onStartStop();
            return true;
        }

        // start lap
        function onBack() {
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
        function onMenu() {
            return true;
        }

        function onNextPage() {
            _controller.cycleView(1);
        }

        function onPreviousPage() {
            _controller.cycleView(-1);
        }
    }
}