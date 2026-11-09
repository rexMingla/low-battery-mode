import Toybox.Lang;
using Toybox.WatchUi as Ui;

module view {
    class BatteryPercentageView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() as String {
           return data.Formatter.getInt(_model.getBatteryPercentage());
        }

        protected function getLabel() as String {
           return Ui.loadResource(Rez.Strings.view_battery_percentage) as String;
        }
    }
}