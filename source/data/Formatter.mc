import Toybox.Lang;

module data {
    // Number formatting helpers. Anything that can't be formatted (e.g. null while there is no
    // data yet) gives a placeholder instead of throwing.
    class Formatter {
        static function getInt(n as Numeric or Null) as String {
            if (n == null) {
                return "--";
            }
            return n.format("%d");
        }

        static function get1dpFloat(n as Numeric or Null) as String {
            if (n == null) {
                return "--";
            }
            return n.format("%0.1f");
        }

        static function get2dpFloat(n as Numeric or Null) as String {
            if (n == null) {
                return "--";
            }
            return n.format("%0.2f");
        }

        // 5.17 -> 5:10
        static function getPace(unitPerHour as Numeric or Null) as String {
            if (unitPerHour == null) {
                return "-:--";
            }
            var mins = 60 * ((100 * unitPerHour).toNumber() % 100) / 100;
            return getTime(unitPerHour, mins);
        }

        // 125 -> 2:05 (splits any number into whole 60s and the remainder)
        static function getTimeFromSecs(secs as Number or Null) as String {
            if (secs == null) {
                return "-:--";
            }
            return getTime(secs / 60, secs % 60);
        }

        // The battery estimate is "--" until there is enough data to calculate it
        static function getTimeFromMins(mins as Number or String or Null) as String {
            if (!(mins instanceof Number)) {
                return "-:--";
            }
            return getTime(mins / 60, mins % 60);
        }

        static function getTime(units as Numeric, unitsMod60 as Numeric) as String {
            return Lang.format("$1$:$2$", [units.format("%d"), unitsMod60.format("%02d")]);
        }
    }
}