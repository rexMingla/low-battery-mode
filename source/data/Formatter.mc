using Toybox.Lang;

module data {
    class Formatter {
        static function getInt(n) {
            try {
                return n.format("%d");
            } catch (ex) {
            }
            return "--";
        }

        static function get1dpFloat(n) {
            try {
                return n.format("%0.1f");
            } catch (ex) {
            }
            return "--";
        }

        static function get2dpFloat(n) {
            try {
                return n.format("%0.2f");
            } catch (ex) {
            }
            return "--";
        }

        // 5.17 -> 5:10
        static function getPace(unitPerHour) {
            try {
                var mins = 60 * ((100 * unitPerHour).toNumber() % 100) / 100;
                return getTime(unitPerHour, mins);
            } catch (ex) {
            }
            return "-:--";
        }

        static function getTimeFromSecs(secs) {
            try {
                return getTime(secs / 60, secs % 60);
            } catch (ex) {
            }
            return "-:--";
        }

        static function getTime(hours, mins) {
            try {
                return Lang.format("$1$:$2$", [hours.format("%d"), mins.format("%02d")]);
            } catch (ex) {
            }
            return "-:--";
        }
    }
}