import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application as App;

class BatteryApp extends App.AppBase {

    private var _model as Model or Null;
    private var _controller as Controller or Null;

    function initialize() {
        AppBase.initialize();
    }

    // Model and Controller call Application.getApp(), so create them once the app is up
    // rather than in initialize().
    function onStart(state as Dictionary?) as Void {
        _model = new $.Model();
        _controller = new $.Controller();
    }

    function onStop(state as Dictionary?) as Void {
    }

    // Position events are switched off by the system while inactive; turn them back on.
    function onActive(state as Dictionary?) as Void {
        var model = _model;
        if (model != null) {
            model.enableGps();
        }
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new view.TimeOfDayView(), new delegate.MainDelegate() ];
    }

    function getController() as Controller {
        return _controller as Controller;
    }

    function getModel() as Model {
        return _model as Model;
    }
}
