using Toybox.WatchUi as Ui;

module view {
    class TimeOfDayView extends AbstractView {
        hidden var _timeDisplayModulus;

        public function initialize() {
            AbstractView.initialize();
            _timeDisplayModulus = System.getDeviceSettings().is24Hour ? 24 : 12;
        }

        protected function getValue() {
            var now = _model.getTimeOfDay();
            return data.Formatter.getTime(now.hour % _timeDisplayModulus, now.min);
        }

        protected function getLabel() {
            return Ui.loadResource(Rez.Strings.view_time_of_day);
        }
    }
}
