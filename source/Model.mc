using Toybox.Activity;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Attention;
using Toybox.FitContributor;
using Toybox.ActivityRecording;
using Toybox.Time;
using Toybox.Position;
using Toybox.WatchUi;

class Model
{
    hidden var _session;
    hidden var _activity;
    hidden var _gpsConfigOrConstellation;
    hidden var _hasPositionSupport;
    hidden var _isRunning;
    hidden var _speedConversion;

    // leave off remaining time for now..
    hidden var _views = [VIEW_TIME_OF_DAY, VIEW_TIME, VIEW_DISTANCE, VIEW_BATTERY_PERCENTAGE];
    hidden var _currentViewIndex;

    hidden var _gpsRefreshInfo;
    hidden var _sensorRefreshInfo;

    hidden var _startBatteryTime;
    hidden var _startBatteryPercentage;

    hidden const KmsToMiles = 0.621371;
    hidden const PrintDebugMessages = false;

    enum {
       VIEW_TIME_OF_DAY,
       VIEW_TIME,
       VIEW_DISTANCE,
       VIEW_BATTERY_PERCENTAGE,
       VIEW_BATTERY_REMAINING
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

    hidden static var mAllSensorsByActivityType = {
        ActivityRecording.SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    };

    function initialize() {
        _speedConversion = System.getDeviceSettings().paceUnits == System.UNIT_METRIC ? 1 : KmsToMiles;
        _isRunning = false;
        _currentViewIndex = 0;

        var activity = Application.getApp().getProperty("activity");
        setActivity(activity != null ? activity : ActivityRecording.SPORT_RUNNING);

        _hasPositionSupport = Position has :hasConfigurationSupport;       
        var gpsConfigOrConstellation = Application.getApp().getProperty("gpsConfigOrConstellation");
        var defaultGpsConfig = _hasPositionSupport ? WORKAROUND_CONFIGURATION_GPS : WORKAROUND_CONSTELLATION_GPS;
        setGpsConfigOrConstellation(gpsConfigOrConstellation != null ? gpsConfigOrConstellation : defaultGpsConfig);
    }

    // config.. activity, gps, sensor setup
    function setActivity(activity) {
        _activity = activity;
        Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity]);
        Application.getApp().setProperty("activity", _activity);
        onBatteryProfileChanged();
    }

    function getActivity() {
        return _activity;
    }

    function getActivityName() {
        if (_activity == ActivityRecording.SPORT_RUNNING) {
            return WatchUi.loadResource(Rez.Strings.menu_activity_run);
        }
        if (_activity == ActivityRecording.SPORT_CYCLING) {
            return WatchUi.loadResource(Rez.Strings.menu_activity_bike);
        }
        if (_activity == ActivityRecording.SPORT_SWIMMING) {
            return WatchUi.loadResource(Rez.Strings.menu_activity_swim);
        }
        return WatchUi.loadResource(Rez.Strings.menu_activity_other);
    }

    // session management
    function start() {
        if (_session == null) {
            _session = ActivityRecording.createSession({:sport=>_activity, :name=>"Low Battery Mode"});
        }
        _session.start();
        _isRunning = true;
    }

    function stop() {
        _session.stop();
        _isRunning = false;
    }

    function startLap() {
        _session.addLap();
    }

    function hasStarted() {
        return _session != null;
    }

    function isRunning() {
        return _isRunning;
    }

    function save() {
        _session.save();
    }

    function discard() {
        _session.discard();
    }

     // data lookups used by view
    function cycleView(offset) {
        _currentViewIndex = (_views.size() + _currentViewIndex + offset) % _views.size();
    }

    function getCurrentViewIndex() {
        return _currentViewIndex;
    }

    function getTimeMinutes() {
        return safeGetNumber(Activity.getActivityInfo().elapsedTime) / 1000 / 60;
    }

    function getDistance() {
        return _speedConversion * safeGetNumber(Activity.getActivityInfo().elapsedDistance) / 1000;
    }

    function getBatteryPercentage() {
        return System.getSystemStats().battery;
    }

    function onBatteryProfileChanged() {
        _startBatteryTime = Time.now();
        _startBatteryPercentage = getBatteryPercentage();
    }

    function getTimeOfDay() {
        return System.getClockTime();
    }

    function getBatteryRemainingMins() {
        var timeDelta = _startBatteryTime.subtract(Time.now());
        var percentage = getBatteryPercentage();
        if (timeDelta.lessThan(new Time.Duration(60)) || percentage == _startBatteryPercentage) {
            return "--";
        }
        return (timeDelta.value() * percentage * (_startBatteryPercentage - percentage) / 60).toNumber();
    }

    function getGpsQuality() {
        var info = Activity.getActivityInfo();
        return info.currentLocationAccuracy;
    }

    private function safeGetNumber(n) {
        return n == null ? 0 : n;
    }

    // sensor and gps callbacks
    function noOp(info) {
    }

    private function printDebug(message) {
        if (PrintDebugMessages) {
            System.println(message);
        }
    }

    // gps management
    private function setupGpsOptions(configOrConstellation) {
        var options = {
            :acquisitionType => Position.LOCATION_CONTINUOUS
        };
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

        if (Position has :CONSTELLATION_GPS && configOrConstellation == WORKAROUND_CONSTELLATION_GPS) {
            options[:constellations] = [ Position.CONSTELLATION_GPS ];
            _gpsConfigOrConstellation = configOrConstellation;
            return options; 
        }
        if (Position has :CONSTELLATION_GLONASS && configOrConstellation == WORKAROUND_CONSTELLATION_GLONASS) {
            options[:constellations] = [ Position.CONSTELLATION_GPS, Position.CONSTELLATION_GLONASS ];
            _gpsConfigOrConstellation = configOrConstellation;
            return options; 
        }
        if (Position has :CONSTELLATION_GALILEO && configOrConstellation == WORKAROUND_CONSTELLATION_GALILEO) {
            options[:constellations] = [ Position.CONSTELLATION_GPS, Position.CONSTELLATION_GALILEO ];
            _gpsConfigOrConstellation = configOrConstellation;
            return options; 
        }
        return Position.LOCATION_CONTINUOUS;
    }

    function hasGpsSettings() {
        if (_hasPositionSupport) {
            return Position has :CONFIGURATION_GPS 
                || Position has :CONFIGURATION_GPS_BEIDOU 
                || Position has :CONFIGURATION_GPS_GALILEO 
                || Position has :CONFIGURATION_GPS_GALILEO 
                || Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1 
                || Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
        }
        return Position has :CONSTELLATION_GPS 
                || Position has :CONSTELLATION_GLONASS
                || Position has :CONSTELLATION_GALILEO;
    }

    function setGpsConfigOrConstellation(configOrConstellation) {
        var options = setupGpsOptions(configOrConstellation);
        Application.getApp().setProperty("gpsConfigOrConstellation", _gpsConfigOrConstellation);
        Position.enableLocationEvents(options, method(:noOp));
        onBatteryProfileChanged();
    }

    function getGpsConfigOrConstellation() {
        return _gpsConfigOrConstellation;
    }

    function getGpsSettingsName() {
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_BEIDOU) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_beidou_L1);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass_beidou_L1);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass_beidou_L1_L5);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONFIGURATION_GPS_GALILEO) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_galileo);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONSTELLATION_GPS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONSTELLATION_GLONASS) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass);
        }
        if (_gpsConfigOrConstellation == WORKAROUND_CONSTELLATION_GALILEO) {
            return WatchUi.loadResource(Rez.Strings.gps_config_gps_galileo);
        }
    }
}