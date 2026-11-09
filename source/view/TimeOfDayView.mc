import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System;

module view {
    class TimeOfDayView extends AbstractView {
        hidden var _timeDisplayModulus as Number;

        public function initialize() {
            AbstractView.initialize();
            _timeDisplayModulus = System.getDeviceSettings().is24Hour ? 24 : 12;
        }

        protected function getValue() as String {
            var now = _model.getTimeOfDay();
            return data.Formatter.getTime(now.hour % _timeDisplayModulus, now.min);
        }

        protected function getLabel() as String {
            return Ui.loadResource(Rez.Strings.view_time_of_day) as String;
        }
    }
}