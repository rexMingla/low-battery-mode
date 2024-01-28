using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;
using Toybox.Position;

class Controller {
    hidden var _model;
    hidden var _timer;
    hidden var _isShowingLapSummaryView;
    hidden var _isTonesOn;
    hidden var _isVibrateOn;

    function initialize() {
        _timer = new Timer.Timer();
        _model = Application.getApp().getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
    }

    function setActivity(activity) {
        _model.setActivity(activity);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function start() {
        performAttention(Attention has :TONE_START ? Attention.TONE_START : null);
        _model.start();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function stop() {
        performAttention(Attention has :TONE_STOP ? Attention.TONE_STOP : null);
        _model.stop();
    }

    function save() {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.save();
        // Give the system some time to finish the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    function discard() {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.discard();
        // Give the system some time to discard the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    // Handle the start/stop button
    function onStartStop() {
        if (!hasStarted()) {
            onStartActivity();
        } else if (!isRunning()) {
            start();
        } else {
            stop();
            onShowPauseMenu();
        }
        WatchUi.requestUpdate();
    }

    function onShowPauseMenu() {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_pause_title)});
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_resume), null, :resume, {}));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_save), null, :save, {}));
        var gpsSettingsMenuItem = null;
        if (_model.hasGpsSettings()) {
            gpsSettingsMenuItem = new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_select_gps_settings), getGpsSettingsName(), :select_gps_settings, {});
            menu.addItem(gpsSettingsMenuItem);
        }
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_discard), null, :discard, {}));
        WatchUi.pushView(menu, new delegate.PausedMenuDelegate(gpsSettingsMenuItem), WatchUi.SLIDE_UP);
    }

    function onShowGpsSettings(parentMenuItem as WatchUi.MenuItem) {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_select_gps_settings)});

        var setting = _model.getGpsConfigOrConstellation();

        if (Position has :hasConfigurationSupport) {
            if ((Position has :CONFIGURATION_GPS) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS)) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps), null,
                    Model.WORKAROUND_CONFIGURATION_GPS, setting == Model.WORKAROUND_CONFIGURATION_GPS, {}));
            }
            if ((Position has :CONFIGURATION_GPS_BEIDOU) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_BEIDOU)) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_beidou_L1), null,
                    Model.WORKAROUND_CONFIGURATION_GPS_BEIDOU, setting == Model.WORKAROUND_CONFIGURATION_GPS_BEIDOU, {}));
            }
            if ((Position has :CONFIGURATION_GPS_GLONASS) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS)) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass), null,
                    Model.WORKAROUND_CONFIGURATION_GPS_GLONASS, setting == Model.WORKAROUND_CONFIGURATION_GPS_GLONASS, {}));
            }
            if ((Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1)) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass_beidou_L1), null,
                    Model.WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1, setting == Model.WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1, {}));
            }
            if ((Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5)) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass_beidou_L1_L5), null,
                    Model.WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5, setting == Model.WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5, {}));
            }
            if ((Position has :CONFIGURATION_GPS_GALILEO) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GALILEO)) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_galileo), null,
                    Model.WORKAROUND_CONFIGURATION_GPS_GALILEO, setting == Model.WORKAROUND_CONFIGURATION_GPS_GALILEO, {}));
            }
        } else {
            if (Position has :CONSTELLATION_GPS) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps), null,
                    Model.WORKAROUND_CONSTELLATION_GPS, setting == Model.WORKAROUND_CONSTELLATION_GPS, {}));
            }
            if (Position has :CONSTELLATION_GLONASS) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_glonass), null,
                    Model.WORKAROUND_CONSTELLATION_GLONASS, setting == Model.WORKAROUND_CONSTELLATION_GLONASS, {}));
            }
            if (Position has :CONSTELLATION_GALILEO) {
                menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.gps_config_gps_galileo), null,
                    Model.WORKAROUND_CONSTELLATION_GALILEO, setting == Model.WORKAROUND_CONSTELLATION_GALILEO, {}));
            }
        }

        WatchUi.pushView(menu, new delegate.GpsMenuDelegate(parentMenuItem), WatchUi.SLIDE_UP);
    }

    function setGpsSettings(mode) {
        _model.setGpsConfigOrConstellation(mode);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function getGpsSettingsName() {
        return _model.getGpsSettingsName();
    }

    function onStartActivity() {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_start_title)});
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_start), null, :start, {}));
        var activityMenuItem = new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_select_activity), getActivityName(), :select_activity, {});
        menu.addItem(activityMenuItem);
        
        var gpsSettingsMenuItem = null;
        if (_model.hasGpsSettings()) {
            gpsSettingsMenuItem = new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_select_gps_settings), getGpsSettingsName(), :select_gps_settings, {});
            menu.addItem(gpsSettingsMenuItem);
        }
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_quit), null, :quit, {}));
        WatchUi.pushView(menu, new delegate.StartMenuDelegate(activityMenuItem, gpsSettingsMenuItem), WatchUi.SLIDE_UP);
    }

    function getActivityName() {
        return _model.getActivityName();
    }

    function onResumeActivity() {
        cycleView(0);
    }

    function onSelectActivity(parentMenuItem as WatchUi.MenuItem) {
        var activity = _model.getActivity();
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_activity_title)});
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_run), null, ActivityRecording.SPORT_RUNNING, activity == ActivityRecording.SPORT_RUNNING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_bike), null, ActivityRecording.SPORT_CYCLING, activity == ActivityRecording.SPORT_CYCLING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_swim), null, ActivityRecording.SPORT_SWIMMING, activity == ActivityRecording.SPORT_SWIMMING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_other), null, ActivityRecording.SPORT_GENERIC, activity == ActivityRecording.SPORT_GENERIC, {}));
        WatchUi.pushView(menu, new delegate.ActivityInputDelegate(parentMenuItem), WatchUi.SLIDE_UP);
    }

    function isRunning() {
        return _model.isRunning();
    }

    function hasStarted() {
        return _model.hasStarted();
    }

    function onLap() {
        performAttention(Attention has :TONE_LAP ? Attention.TONE_LAP : null);
        _model.startLap();
    }

    function onExit() {
        System.exit();
    }

    function cycleView(offset) {
        if (!_model.hasStarted()) {
            return ;
        }
        _model.cycleView(offset);
        WatchUi.switchToView(view.ViewFactory.createView(_model.getCurrentViewIndex()), new delegate.MainDelegate(), WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function performAttention(tone) {
        if (Attention has :playTone && _isTonesOn && tone != null) {
            Attention.playTone(tone);
        }
        if (Attention has :vibrate && _isVibrateOn) {
            Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        }
    }
 }