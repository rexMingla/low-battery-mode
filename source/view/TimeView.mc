import Toybox.Lang;
using Toybox.WatchUi as Ui;

module view {
    class TimeView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() as String {
           return data.Formatter.getTimeFromSecs(_model.getTimeMinutes());
        }

        protected function getLabel() as String {
           return Ui.loadResource(Rez.Strings.view_time) as String;
        }
    }
}