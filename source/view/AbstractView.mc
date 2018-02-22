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
        }

        // Update the view
        function onUpdate(dc) {
            if (!_model.isRunning()) {
                View.onUpdate(dc);
                var gpsQuality = _model.getGpsQuality();
                var messageFormat = !_model.hasStarted() ? Ui.loadResource(Rez.Strings.welcome_format) : Ui.loadResource(Rez.Strings.resume_format);
                var welcomeString = Lang.format(messageFormat, [getGpsQualityText(gpsQuality)]);
                dc.setColor(gpsQuality == Position.QUALITY_GOOD ? Graphics.COLOR_GREEN : Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, welcomeString, "", _posDetails.CentreColumn, _posDetails.CentreRow);
                _timer.start(method(:onTimer), 1000, false);
                return;
            }

            var value = getValue();
            if (value != _cachedValue) {
                _cachedValue = value;
                View.onUpdate(dc);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, getLabel(), _cachedValue, _posDetails.CentreColumn, _posDetails.CentreRow);
            }
            _timer.start(method(:onTimer), 60 * 1000, false);
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

        private function getGpsQualityText(quality) {
            if (quality == Position.QUALITY_GOOD) {
                return Ui.loadResource(Rez.Strings.gps_good);
            } else if (quality == Position.QUALITY_USABLE) {
                return Ui.loadResource(Rez.Strings.gps_ok);
            }
            return Ui.loadResource(Rez.Strings.gps_poor);
        }
    }
}

