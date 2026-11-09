import Toybox.Lang;
import Toybox.Position;
using Toybox.Activity;
using Toybox.Application;
using Toybox.Sensor;
using Toybox.System;
using Toybox.ActivityRecording;
using Toybox.Time;
using Toybox.WatchUi;

// Options accepted by Position.enableLocationEvents
typedef GpsOptions as {
    :acquisitionType as Position.LocationAcquisitionType,
    :constellations as Array<Position.Constellation>,
    :configuration as Position.Configuration
};

class Model
{
    hidden var _session as ActivityRecording.Session or Null;
    hidden var _activity as Number = SPORT_RUNNING;
    hidden var _gpsConfigOrConstellation as Number or Null;
    hidden var _gpsOptions as GpsOptions or Null;
    hidden var _hasPositionSupport as Boolean = false;
    hidden var _isRunning as Boolean = false;
    hidden var _speedConversion as Numeric = 1;

    // leave off remaining time for now..
    hidden var _views as Array<Number> = [VIEW_TIME_OF_DAY, VIEW_TIME, VIEW_DISTANCE, VIEW_BATTERY_PERCENTAGE];
    hidden var _currentViewIndex as Number = 0;

    hidden var _startBatteryTime as Time.Moment = Time.now();
    hidden var _startBatteryPercentage as Float = 0.0;

    hidden const KmsToMiles = 0.621371;
    hidden const PrintDebugMessages = false;

    enum {
       VIEW_TIME_OF_DAY,
       VIEW_TIME,
       VIEW_DISTANCE,
       VIEW_BATTERY_PERCENTAGE,
       VIEW_BATTERY_REMAINING
    }

    // Sport values from the FIT sport enum. Activity.SPORT_* does not exist on API 3.0/3.1 devices and
    // ActivityRecording.SPORT_* is deprecated, so the values are defined here.
    enum {
        SPORT_GENERIC = 0,
        SPORT_RUNNING = 1,
        SPORT_CYCLING = 2,
        SPORT_SWIMMING = 5
    }

    // work around as Configuration and Constellation enums collide https://developer.garmin.com/connect-iq/api-docs/Toybox/Position.html#Constellation-module
    enum {
        WORKAROUND_CONFIGURATION_GPS,
        WORKAROUND_CONFIGURATION_GPS_BEIDOU,
        WORKAROUND_CONFIGURATION_GPS_GLONASS,
        WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1,
        WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5,
        WORKAROUND_CONFIGURATION_GPS_GALILEO,

        WORKAROUND_CONSTELLATION_GPS,
        WORKAROUND_CONSTELLATION_GLONASS,
        WORKAROUND_CONSTELLATION_GALILEO
    }

    hidden static var mAllSensorsByActivityType as Dictionary<Number, Array<Sensor.OnboardSensorType or Sensor.RemoteSensorType>> = {
        SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    };

    function initialize() {
        _speedConversion = System.getDeviceSettings().paceUnits == System.UNIT_METRIC ? 1 : KmsToMiles;

        var activity = Application.Storage.getValue("activity") as Number or Null;
        setActivity(activity != null ? activity : SPORT_RUNNING);

        _hasPositionSupport = Position has :hasConfigurationSupport;
        var gpsConfigOrConstellation = Application.Storage.getValue("gpsConfigOrConstellation") as Number or Null;
        var defaultGpsConfig = _hasPositionSupport ? WORKAROUND_CONFIGURATION_GPS : WORKAROUND_CONSTELLATION_GPS;
        setGpsConfigOrConstellation(gpsConfigOrConstellation != null ? gpsConfigOrConstellation : defaultGpsConfig);
    }

    // config.. activity, gps, sensor setup
    function setActivity(activity as Number) as Void {
        _activity = activity;
        Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity] as Array<Sensor.OnboardSensorType or Sensor.RemoteSensorType>);
        Application.Storage.setValue("activity", _activity);
        onBatteryProfileChanged();
    }

    function getActivity() as Number {
        return _activity;
    }

    function getActivityName() as String {
        if (_activity == SPORT_RUNNING) {
            return WatchUi.loadResource(Rez.Strings.menu_activity_run) as String;
        }
        if (_activity == SPORT_CYCLING) {
            return WatchUi.loadResource(Rez.Strings.menu_activity_bike) as String;
        }
        if (_activity == SPORT_SWIMMING) {
            return WatchUi.loadResource(Rez.Strings.menu_activity_swim) as String;
        }
        return WatchUi.loadResource(Rez.Strings.menu_activity_other) as String;
    }

    // session management
    function start() as Void {
        enableGps();
        var session = _session;
        if (session == null) {
            session = ActivityRecording.createSession({:sport=>_activity as Activity.Sport, :name=>"Low Battery Mode"});
            _session = session;
        }
        session.start();
        _isRunning = true;
    }

    function stop() as Void {
        var session = _session;
        if (session != null) {
            session.stop();
        }
        _isRunning = false;
    }

    function startLap() as Void {
        var session = _session;
        if (session != null) {
            session.addLap();
        }
    }

    function hasStarted() as Boolean {
        return _session != null;
    }

    function isRunning() as Boolean {
        return _isRunning;
    }

    function save() as Void {
        var session = _session;
        if (session != null) {
            session.save();
        }
    }

    function discard() as Void {
        var session = _session;
        if (session != null) {
            session.discard();
        }
    }

     // data lookups used by view
    function cycleView(offset as Number) as Void {
        _currentViewIndex = (_views.size() + _currentViewIndex + offset) % _views.size();
    }

    function getCurrentViewIndex() as Number {
        return _currentViewIndex;
    }

    function getTimeMinutes() as Number {
        return (safeGetNumber(Activity.getActivityInfo().elapsedTime) / 1000 / 60).toNumber();
    }

    function getDistance() as Numeric {
        return _speedConversion * safeGetNumber(Activity.getActivityInfo().elapsedDistance) / 1000;
    }

    function getBatteryPercentage() as Float {
        return System.getSystemStats().battery;
    }

    function onBatteryProfileChanged() as Void {
        _startBatteryTime = Time.now();
        _startBatteryPercentage = getBatteryPercentage();
    }

    function getTimeOfDay() as System.ClockTime {
        return System.getClockTime();
    }

    // Estimated minutes of battery left, extrapolating the drain since the battery profile last changed
    function getBatteryRemainingMins() as Number or String {
        var elapsedSeconds = Time.now().value() - _startBatteryTime.value();
        var percentage = getBatteryPercentage();
        if (elapsedSeconds < 60 || percentage >= _startBatteryPercentage) {
            return "--";
        }
        return (elapsedSeconds * percentage / (_startBatteryPercentage - percentage) / 60).toNumber();
    }

    function getGpsQuality() as Position.Quality or Null {
        var info = Activity.getActivityInfo();
        return info.currentLocationAccuracy;
    }

    private function safeGetNumber(n as Numeric or Null) as Numeric {
        return n == null ? 0 : n;
    }

    // sensor and gps callbacks
    function noOp(info as Position.Info) as Void {
    }

    private function printDebug(message as String) as Void {
        if (PrintDebugMessages) {
            System.println(message);
        }
    }

    // gps management
    private function setupGpsOptions(configOrConstellation as Number) as GpsOptions {
        var options = {
            :acquisitionType => Position.LOCATION_CONTINUOUS
        } as GpsOptions;
        if (_hasPositionSupport) {
            if (Position has :CONFIGURATION_GPS && configOrConstellation == WORKAROUND_CONFIGURATION_GPS) {
                options[:configuration] = Position.CONFIGURATION_GPS;
                _gpsConfigOrConstellation = configOrConstellation;
                return options;
            }
            if (Position has :CONFIGURATION_GPS_BEIDOU && configOrConstellation == WORKAROUND_CONFIGURATION_GPS_BEIDOU) {
                options[:configuration] = Position.CONFIGURATION_GPS_BEIDOU;
                _gpsConfigOrConstellation = configOrConstellation;
                return options;
            }
            if (Position has :CONFIGURATION_GPS_GLONASS && configOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS) {
                options[:configuration] = Position.CONFIGURATION_GPS_GLONASS;
                _gpsConfigOrConstellation = configOrConstellation;
                return options;
            }
            if (Position has :CONFIGURATION_GPS_GALILEO && configOrConstellation == WORKAROUND_CONFIGURATION_GPS_GALILEO) {
                options[:configuration] = Position.CONFIGURATION_GPS_GALILEO;
                _gpsConfigOrConstellation = configOrConstellation;
                return options;
            }
            if (Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1 && configOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) {
                options[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1;
                _gpsConfigOrConstellation = configOrConstellation;
                return options;
            }
            if (Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5 && configOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) {
                options[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
                _gpsConfigOrConstellation = configOrConstellation;
                return options;
            }
            return options;
        }

        var constellations = getLegacyConstellations(configOrConstellation);
        if (constellations != null) {
            options[:constellations] = constellations;
            _gpsConfigOrConstellation = configOrConstellation;
        }
        return options;
    }

    // Devices without Position configuration support (API below 3.3.6) can only select
    // constellations. The CONSTELLATION_* constants are deprecated but there is no alternative on
    // those devices, so type checking (and its deprecation warnings) is switched off for just this
    // function.
    (:typecheck(false))
    private function getLegacyConstellations(configOrConstellation as Number) as Array<Position.Constellation> or Null {
        if (Position has :CONSTELLATION_GPS && configOrConstellation == WORKAROUND_CONSTELLATION_GPS) {
            return [ Position.CONSTELLATION_GPS ];
        }
        if (Position has :CONSTELLATION_GLONASS && configOrConstellation == WORKAROUND_CONSTELLATION_GLONASS) {
            return [ Position.CONSTELLATION_GPS, Position.CONSTELLATION_GLONASS ];
        }
        if (Position has :CONSTELLATION_GALILEO && configOrConstellation == WORKAROUND_CONSTELLATION_GALILEO) {
            return [ Position.CONSTELLATION_GPS, Position.CONSTELLATION_GALILEO ];
        }
        return null;
    }

    function hasGpsSettings() as Boolean {
        if (_hasPositionSupport) {
            return Position has :CONFIGURATION_GPS
                || Position has :CONFIGURATION_GPS_BEIDOU
                || Position has :CONFIGURATION_GPS_GLONASS
                || Position has :CONFIGURATION_GPS_GALILEO
                || Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1
                || Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
        }
        return Position has :CONSTELLATION_GPS
                || Position has :CONSTELLATION_GLONASS
                || Position has :CONSTELLATION_GALILEO;
    }

    function setGpsConfigOrConstellation(configOrConstellation as Number) as Void {
        _gpsOptions = setupGpsOptions(configOrConstellation);
        Application.Storage.setValue("gpsConfigOrConstellation", _gpsConfigOrConstellation);
        enableGps();
        onBatteryProfileChanged();
    }

    // Location events are disabled by the system whenever the app goes inactive
    // (e.g. screen off), which stops the session recording a track/map.
    // Re-assert them when the app becomes active and when a session (re)starts.
    function enableGps() as Void {
        var options = _gpsOptions;
        if (options != null) {
            Position.enableLocationEvents(options, method(:noOp));
        }
    }

    function getGpsConfigOrConstellation() as Number or Null {
        return _gpsConfigOrConstellation;
    }

    function getGpsSettingsName() as String {
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_BEIDOU) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_beidou_L1) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass_beidou_L1) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass_beidou_L1_L5) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GALILEO) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_galileo) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONSTELLATION_GPS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONSTELLATION_GLONASS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass) as String;
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONSTELLATION_GALILEO) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_galileo) as String;
        }
        return WatchUi.loadResource(Rez.Strings.gps_config_gps) as String;
    }
}
