import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;

var apiResponsePackage = null;
var lastApiRequestFailed = true;


class faceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void
    {
        apiResponsePackage = Application.Storage.getValue("faceApiResponsePackage");
    }

    function onStop(state as Dictionary?) as Void
    {
        Application.Storage.setValue("faceApiResponsePackage", apiResponsePackage);
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (Properties.getValue("use_openweathermap_api"))
        {
            Background.registerForTemporalEvent(new Time.Duration(Properties.getValue("api_request_interval") * 60));
        }
        return [ new faceView() ];
    }

    function onBackgroundData(data) {
        if (data != null && ((data as Dictionary).get("temp") != null || (data as Dictionary).get("name") != null))
        {
            // System.println("onBackgroundData: saving data to apiResponsePackage");
            apiResponsePackage = data;
            lastApiRequestFailed = false;
        }
        else
        {
            lastApiRequestFailed = true;
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