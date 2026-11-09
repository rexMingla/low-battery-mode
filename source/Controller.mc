import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Application;
using Toybox.System;
using Toybox.Attention;
using Toybox.Position;

class Controller {
    hidden var _model as Model;
    hidden var _timer as Timer.Timer;
    hidden var _isTonesOn as Boolean;
    hidden var _isVibrateOn as Boolean;

    function initialize() {
        _timer = new Timer.Timer();
        _model = (Application.getApp() as BatteryApp).getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
    }

    function setActivity(activity as Number) as Void {
        _model.setActivity(activity);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function start() as Void {
        performAttention(Attention has :TONE_START ? Attention.TONE_START : null);
        _model.start();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function stop() as Void {
        performAttention(Attention has :TONE_STOP ? Attention.TONE_STOP : null);
        _model.stop();
    }

    function save() as Void {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.save();
        // Give the system some time to finish the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    function discard() as Void {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.discard();
        // Give the system some time to discard the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    // Handle the start/stop button
    function onStartStop() as Void {
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

    function onShowPauseMenu() as Void {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_pause_title) as String});
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_resume) as String, null, :resume, {}));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_save) as String, null, :save, {}));
        var gpsSettingsMenuItem = null;
        if (_model.hasGpsSettings()) {
            gpsSettingsMenuItem = new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_select_gps_settings) as String, getGpsSettingsName(), :select_gps_settings, {});
            menu.addItem(gpsSettingsMenuItem);
        }
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_discard) as String, null, :discard, {}));
        WatchUi.pushView(menu, new delegate.PausedMenuDelegate(gpsSettingsMenuItem), WatchUi.SLIDE_UP);
    }

    function onShowGpsSettings(parentMenuItem as WatchUi.MenuItem or Null) as Void {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_select_gps_settings) as String});

        var setting = _model.getGpsConfigOrConstellation();

        if (Position has :hasConfigurationSupport) {
            if ((Position has :CONFIGURATION_GPS) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS)) {
                addGpsItem(menu, Rez.Strings.gps_config_gps, Model.WORKAROUND_CONFIGURATION_GPS, setting);
            }
            if ((Position has :CONFIGURATION_GPS_BEIDOU) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_BEIDOU)) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_beidou_L1, Model.WORKAROUND_CONFIGURATION_GPS_BEIDOU, setting);
            }
            if ((Position has :CONFIGURATION_GPS_GLONASS) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS)) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_glonass, Model.WORKAROUND_CONFIGURATION_GPS_GLONASS, setting);
            }
            if ((Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1)) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_glonass_beidou_L1, Model.WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1, setting);
            }
            if ((Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5)) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_glonass_beidou_L1_L5, Model.WORKAROUND_CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5, setting);
            }
            if ((Position has :CONFIGURATION_GPS_GALILEO) && Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GALILEO)) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_galileo, Model.WORKAROUND_CONFIGURATION_GPS_GALILEO, setting);
            }
        } else {
            if (Position has :CONSTELLATION_GPS) {
                addGpsItem(menu, Rez.Strings.gps_config_gps, Model.WORKAROUND_CONSTELLATION_GPS, setting);
            }
            if (Position has :CONSTELLATION_GLONASS) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_glonass, Model.WORKAROUND_CONSTELLATION_GLONASS, setting);
            }
            if (Position has :CONSTELLATION_GALILEO) {
                addGpsItem(menu, Rez.Strings.gps_config_gps_galileo, Model.WORKAROUND_CONSTELLATION_GALILEO, setting);
            }
        }

        WatchUi.pushView(menu, new delegate.GpsMenuDelegate(parentMenuItem), WatchUi.SLIDE_UP);
    }

    // Adds a GPS option to the menu, ticked if it is the current setting
    private function addGpsItem(menu as WatchUi.Menu2, label as ResourceId, option as Number, current as Number or Null) as Void {
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(label) as String, null, option, current == option, {}));
    }

    function setGpsSettings(mode as Number) as Void {
        _model.setGpsConfigOrConstellation(mode);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function getGpsSettingsName() as String {
        return _model.getGpsSettingsName();
    }

    function onStartActivity() as Void {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_start_title) as String});
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_start) as String, null, :start, {}));
        var activityMenuItem = new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_select_activity) as String, getActivityName(), :select_activity, {});
        menu.addItem(activityMenuItem);

        var gpsSettingsMenuItem = null;
        if (_model.hasGpsSettings()) {
            gpsSettingsMenuItem = new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_select_gps_settings) as String, getGpsSettingsName(), :select_gps_settings, {});
            menu.addItem(gpsSettingsMenuItem);
        }
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_quit) as String, null, :quit, {}));
        WatchUi.pushView(menu, new delegate.StartMenuDelegate(activityMenuItem, gpsSettingsMenuItem), WatchUi.SLIDE_UP);
    }

    function getActivityName() as String {
        return _model.getActivityName();
    }

    function onResumeActivity() as Void {
        cycleView(0);
    }

    function onSelectActivity(parentMenuItem as WatchUi.MenuItem) as Void {
        var activity = _model.getActivity();
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_activity_title) as String});
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_run) as String, null, Model.SPORT_RUNNING, activity == Model.SPORT_RUNNING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_bike) as String, null, Model.SPORT_CYCLING, activity == Model.SPORT_CYCLING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_swim) as String, null, Model.SPORT_SWIMMING, activity == Model.SPORT_SWIMMING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_other) as String, null, Model.SPORT_GENERIC, activity == Model.SPORT_GENERIC, {}));
        WatchUi.pushView(menu, new delegate.ActivityInputDelegate(parentMenuItem), WatchUi.SLIDE_UP);
    }

    function isRunning() as Boolean {
        return _model.isRunning();
    }

    function hasStarted() as Boolean {
        return _model.hasStarted();
    }

    function onLap() as Void {
        performAttention(Attention has :TONE_LAP ? Attention.TONE_LAP : null);
        _model.startLap();
    }

    function onExit() as Void {
        System.exit();
    }

    function cycleView(offset as Number) as Void {
        if (!_model.hasStarted()) {
            return;
        }
        _model.cycleView(offset);
        WatchUi.switchToView(view.ViewFactory.createView(_model.getCurrentViewIndex()), new delegate.MainDelegate(), WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function performAttention(tone as Attention.Tone or Null) as Void {
        if (Attention has :playTone && _isTonesOn && tone != null) {
            Attention.playTone(tone);
        }
        if (Attention has :vibrate && _isVibrateOn) {
            Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        }
    }
 }
