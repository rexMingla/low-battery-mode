using Toybox.WatchUi as Ui;

module view {
    class DistanceView extends AbstractView {

        public function initialize() {
            AbstractView.initialize();
        }

        protected function getValue() {
           return data.Formatter.get1dpFloat(_model.getDistance());
        }

        protected function getLabel() {
           return Ui.loadResource(Rez.Strings.view_dist);
        }
    }
}
