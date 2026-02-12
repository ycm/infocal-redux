import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;

var apiResponsePackage = null;

class faceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {}
    function onStop(state as Dictionary?) as Void {}

    function getInitialView() as [Views] or [Views, InputDelegates] {
        Background.registerForTemporalEvent(new Time.Duration(60 * 60));
        return [ new faceView() ];
    }

    function onBackgroundData(data) {
        apiResponsePackage = data;
        WatchUi.requestUpdate();
    }    

    function getServiceDelegate(){
        return [new faceServiceDelegate()];
    }
}

function getApp() as faceApp {
    return Application.getApp() as faceApp;
}