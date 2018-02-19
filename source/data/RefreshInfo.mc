using Toybox.Lang;

module data {
    class RefreshInfo {
        // sensor and gps refresh rates
        enum {
            REFRESH_RATE_ALWAYS,
            REFRESH_RATE_NEVER,
            REFRESH_RATE_CUSTOM
        }

        enum {
            REFRESH_TYPE_SENSOR,
            REFRESH_TYPE_GPS
        }

        public var RefreshRate;
        public var RefreshRateSeconds;

        function initialize(refreshRate, refreshRateSeconds) {
            RefreshRate = refreshRate;
            RefreshRateSeconds = refreshRateSeconds;
        }
    }
}