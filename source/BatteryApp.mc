using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class BatteryApp extends App.AppBase {

    private var _model;
    private var _controller;

    function initialize() {
        AppBase.initialize();
    }

    // Model and Controller call Application.getApp(), so create them once the app is up
    // rather than in initialize().
    function onStart(state) {
        _model = new $.Model();
        _controller = new $.Controller();
    }

    function onStop(state) {
    }

    // Position events are switched off by the system while inactive; turn them back on.
    function onActive(state) {
        if (_model != null) {
            _model.enableGps();
        }
    }

    function getInitialView() {
        return [ new view.TimeOfDayView(), new delegate.MainDelegate() ];
    }

    function getController() {
        return _controller;
    }

    function getModel() {
        return _model;
    }
}