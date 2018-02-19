using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;
using data.Formatter as Formatter;

module view {
    class ViewFactory extends Ui.View {

        public static function createView(index) {
            switch(index)
            {
                case Model.VIEW_TIME:
                    return new TimeView();
                    break;
                case Model.VIEW_DISTANCE:
                    return new DistanceView();
                    break;
                case Model.VIEW_BATTERY_REMAINING:
                    return new BatteryRemainingView();
                    break;
                case Model.VIEW_BATTERY_PERCENTAGE:
                    return new BatteryPercentageView();
                    break;
                case Model.VIEW_TIME_OF_DAY:
                    return new TimeOfDayView();
                    break;
            }
        }
    }
}