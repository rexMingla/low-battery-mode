import Toybox.Lang;
using Toybox.WatchUi as Ui;

module view {
    class DistanceView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() as String {
           return data.Formatter.get1dpFloat(_model.getDistance());
        }

        protected function getLabel() as String {
           return Ui.loadResource(Rez.Strings.view_dist) as String;
        }
    }
}