using Toybox.WatchUi as Ui;

module view {
    class BatteryRemainingView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() {
           return data.Formatter.getTimeFromMins(_model.getBatteryRemainingMins());
        }

        protected function getLabel() {
           return Ui.loadResource(Rez.Strings.view_battery_remaining);
        }
    }
}
