import Toybox.Lang;
using Toybox.WatchUi as Ui;

module view {
    class BatteryRemainingView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() as String {
           return data.Formatter.getTimeFromMins(_model.getBatteryRemainingMins());
        }

        protected function getLabel() as String {
           return Ui.loadResource(Rez.Strings.view_battery_remaining) as String;
        }
    }
}