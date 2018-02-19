using Toybox.Activity;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Attention;
using Toybox.FitContributor;
using Toybox.ActivityRecording;

class Model
{
    hidden var _session;
    hidden var _activity;
    hidden var _isRunning;
    hidden var _speedConversion;

    // leave off remaining time for now..
    hidden var _views = [VIEW_TIME, VIEW_DISTANCE, VIEW_TIME_OF_DAY, VIEW_BATTERY_PERCENTAGE];
    hidden var _currentViewIndex;

    hidden var _gpsRefreshInfo;
    hidden var _sensorRefreshInfo;

    hidden var _customGpsTimer;
    hidden var _customSensorTimer;

    hidden const KmsToMiles = 0.621371;

    enum {
       VIEW_TIME,
       VIEW_DISTANCE,
       VIEW_TIME_OF_DAY,
       VIEW_BATTERY_REMAINING,
       VIEW_BATTERY_PERCENTAGE
    }

    hidden static var mAllSensorsByActivityType = {
        ActivityRecording.SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    };

    function initialize() {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:noOp));

        _speedConversion = System.getDeviceSettings().paceUnits == System.UNIT_METRIC ? 1 : KmsToMiles;
        _isRunning = false;
        _currentViewIndex = 0;

        _customGpsTimer = new Timer.Timer();
        _customSensorTimer = new Timer.Timer();

        setActivity(ActivityRecording.SPORT_RUNNING);
        setGpsRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_ALWAYS, null));
        setSensorRefreshInfo(new data.RefreshInfo(data.RefreshInfo.REFRESH_RATE_ALWAYS, null));
    }

    // config.. activity, gps, sensor setup
    function setActivity(activity) {
        _activity = activity;
        if (_gpsRefreshInfo != null) {
            setSensorRefreshInfo(_gpsRefreshInfo);
        }
    }

    function setGpsRefreshInfo(info) {
        _gpsRefreshInfo = info;
        if (info.RefreshRate == data.RefreshInfo.REFRESH_RATE_ALWAYS) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:noOp));
            _customGpsTimer.stop();
        } else if (info.RefreshRate == data.RefreshInfo.REFRESH_RATE_NEVER) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:noOp));
            _customGpsTimer.stop();
        } else {
            onStartGetOneShotGpsData();
        }
    }

    function setSensorRefreshInfo(info) {
        _sensorRefreshInfo = info;
        if (info.RefreshRate == data.RefreshInfo.REFRESH_RATE_ALWAYS) {
            Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity]);
        } else if (info.RefreshRate == data.RefreshInfo.REFRESH_RATE_NEVER) {
            Sensor.setEnabledSensors([]);
        } else {
            onStartGetOneShotSensorData();
        }
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

    function resume() {
        _session.start();
        _isRunning = true;
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

    function getBatteryRemainingMinutes() {
        return 42 * 60; // TODO
    }

    function getGpsQuality() {
        var info = Activity.getActivityInfo();
        return info.currentLocationAccuracy;
    }

    private function safeGetNumber(n) {
        return n == null ? 0 : n;
    }

    // sensor and gps callbacks
    private function noOp(info) {
    }

    private function onStartGetOneShotGpsData() {
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:onEndGetOneShotGpsData));
    }

    private function onEndGetOneShotGpsData(info) {
        Position.enableLocationEvents(Position.DISABLE, method(:noOp));
        _customGpsTimer.start(method(:onStartGetOneShotGpsData), _gpsRefreshInfo.RefreshRateSeconds * 1000, true);
    }

    private function onStartGetOneShotSensorData() {
        Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity]);
        Sensor.enableSensorEvents(method(:onEndGetOneShotSensorData));
    }

    private function onEndGetOneShotSensorData(info) {
        Sensor.setEnabledSensors([]);
        _customGpsTimer.start(method(:onStartGetOneShotSensorData), _sensorRefreshInfo.RefreshRateSeconds * 1000, false);
    }
}