using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;
using data.Formatter as Formatter;

module view {
    class AbstractView extends Ui.View {

        hidden var _timer;
        hidden var _cachedValue;
        hidden var _posDetails;

        protected var _model;

        function initialize() {
            View.initialize();
            _model = Application.getApp().getModel();
            _timer = new Timer.Timer();
        }

        function onLayout(dc) {
            _posDetails = data.PositionDetails.createFromDataContext(dc);
        }

        protected function getValue() {
        }

        protected function getLabel() {
        }

        function onShow() {
            Ui.requestUpdate();
            _timer.start(method(:onTimer), 60 * 1000, true);
        }

        // Update the view
        function onUpdate(dc) {
            var value = getValue();
            if (value == _cachedValue) {
                return;
            }
            _cachedValue = value;
            View.onUpdate(dc);
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            drawTextAndData(dc, getLabel(), _cachedValue, _posDetails.CentreColumn, _posDetails.CentreRow);
        }

        private function drawTextAndData(dc, label, data, x, y) {
            dc.drawText(x, y - _posDetails.DataAndLabelOffset, _posDetails.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, _posDetails.DataFont, data, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Called when this View is removed from the screen. Save the
        // state of this View here. This includes freeing resources from
        // memory.
        function onHide() {
            _timer.stop();
        }

        // Handler for the _timer callback
        function onTimer() {
            Ui.requestUpdate();
        }
    }
}

