using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
import Toybox.Lang;
using Toybox.Graphics;

module view {
    class ViewFactory extends Ui.View {

        function initialize() {
            View.initialize();
        }

        public static function createView(index as Number) as Ui.View {
            switch(index)
            {
                case Model.VIEW_TIME:
                    return new TimeView();
                case Model.VIEW_DISTANCE:
                    return new DistanceView();
                case Model.VIEW_TIME_OF_DAY:
                    return new TimeOfDayView();
                case Model.VIEW_BATTERY_PERCENTAGE:
                    return new BatteryPercentageView();
                case Model.VIEW_BATTERY_REMAINING:
                    return new BatteryRemainingView();
            }
            return new TimeOfDayView();
        }
    }
}
