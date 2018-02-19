module data {
    class ViewDataset {
        public var Distance;
        public var ElapsedSeconds;
        public var BatteryPercentage;
        public var BatteryRemainingSeconds;
        public var GpsAccuracy;
        public var IsRunning;
        public var HasStarted;

        function initialize() {
            Distance = 0;
            ElapsedSeconds = 0;
            BatteryPercentage = 0;
            BatteryRemainingSeconds = 0;
            GpsAccuracy = null;
            IsRunning = false;
            HasStarted = false;
        }
    }
}
