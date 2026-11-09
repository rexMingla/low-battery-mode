import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Position;
using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;

module view {
    class AbstractView extends Ui.View {

        hidden var _timer as Timer.Timer;
        hidden var _cachedValue as String or Null;
        hidden var _posDetails as data.PositionDetails = new data.PositionDetails();

        protected var _model as Model;

        function initialize() {
            View.initialize();
            _model = (Application.getApp() as BatteryApp).getModel();
            _timer = new Timer.Timer();
        }

        function onLayout(dc as Graphics.Dc) as Void {
            _posDetails = data.PositionDetails.createFromDataContext(dc);
        }

        // Overridden by each view with the value to display and its label
        protected function getValue() as String {
            return "";
        }

        protected function getLabel() as String {
            return "";
        }

        function onShow() as Void {
            Ui.requestUpdate();
        }

        // Update the view
        function onUpdate(dc as Graphics.Dc) as Void {
            if (!_model.isRunning()) {
                View.onUpdate(dc);
                var gpsQuality = _model.getGpsQuality();
                var messageFormat = (!_model.hasStarted() ? Ui.loadResource(Rez.Strings.welcome_format) : Ui.loadResource(Rez.Strings.resume_format)) as String;
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
                drawTextAndData(dc, getLabel(), value, _posDetails.CentreColumn, _posDetails.CentreRow);
            }
            _timer.start(method(:onTimer), 60 * 1000, false);
        }

        private function drawTextAndData(dc as Graphics.Dc, label as String, value as String, x as Number, y as Number) as Void {
            dc.drawText(x, y - _posDetails.DataAndLabelOffset, _posDetails.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, _posDetails.DataFont, value, Graphics.TEXT_JUSTIFY_CENTER);
        }

        // Called when this View is removed from the screen. Save the
        // state of this View here. This includes freeing resources from
        // memory.
        function onHide() as Void {
            _timer.stop();
        }

        // Handler for the _timer callback
        function onTimer() as Void {
            Ui.requestUpdate();
        }

        private function getGpsQualityText(quality as Position.Quality or Null) as String {
            if (quality == Position.QUALITY_GOOD) {
                return Ui.loadResource(Rez.Strings.gps_good) as String;
            } else if (quality == Position.QUALITY_USABLE) {
                return Ui.loadResource(Rez.Strings.gps_ok) as String;
            }
            return Ui.loadResource(Rez.Strings.gps_poor) as String;
        }
    }
}