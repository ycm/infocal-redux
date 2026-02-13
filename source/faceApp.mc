import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;

var apiResponsePackage = null;
// var apiResponsePackage = {
//     "sunrise" => 1770902046,
//     "sunset" => 1770940376,
//     "temp" => 50,
//     "high" => 100,
//     "low" => -40,
//     "name" => "city name"
// };

class faceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void
    {
        // Comment out = DEBUG
        // No comment = RELEASE
        apiResponsePackage = Application.Storage.getValue("faceApiResponsePackage");
    }

    function onStop(state as Dictionary?) as Void
    {
        Application.Storage.setValue("faceApiResponsePackage", apiResponsePackage);
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        Background.registerForTemporalEvent(new Time.Duration(Properties.getValue("api_request_interval") * 60));
        return [ new faceView() ];
    }

    function onBackgroundData(data) {
        if (data != null && ((data as Dictionary).get("temp") != null || (data as Dictionary).get("name") != null))
        {
            apiResponsePackage = data;
        }
        WatchUi.requestUpdate();
    }

    function getServiceDelegate(){
        return [new faceServiceDelegate()];
    }
}

function getApp() as faceApp {
    return Application.getApp() as faceApp;
}