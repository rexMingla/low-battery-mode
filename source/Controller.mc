using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;

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
            WatchUi.pushView(new Rez.Menus.PausedMenu(), new delegate.PausedMenuDelegate(), WatchUi.SLIDE_UP);
        }
        WatchUi.requestUpdate();
    }

    function onStartActivity() {
        WatchUi.pushView(new Rez.Menus.StartMenu(), new delegate.StartMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onResumeActivity() {
        cycleView(0);
    }

    function onSelectActivity() {
        var activity = _model.getActivity();
        var menu = new WatchUi.CheckboxMenu({:title=>"Select Activity"});
        menu.addItem(new WatchUi.CheckboxMenuItem("Run", null, :run, activity == ActivityRecording.SPORT_RUNNING, {}));
        menu.addItem(new WatchUi.CheckboxMenuItem("Bike", null, :bike, activity == ActivityRecording.SPORT_CYCLING, {}));
        menu.addItem(new WatchUi.CheckboxMenuItem("Swim", null, :swim, activity == ActivityRecording.SPORT_SWIMMING, {}));
        menu.addItem(new WatchUi.CheckboxMenuItem("Other", null, :other, activity == ActivityRecording.SPORT_GENERIC, {}));
        WatchUi.pushView(menu, new delegate.ActivityInputDelegate(), WatchUi.SLIDE_UP);
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