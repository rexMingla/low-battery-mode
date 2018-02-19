using Toybox.WatchUi as Ui;

module view {
    class TimeView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() {
           return data.Formatter.getTimeFromSecs(_model.getTimeMinutes());
        }

        protected function getLabel() {
           return Ui.loadResource(Rez.Strings.view_time);
        }
    }
}
