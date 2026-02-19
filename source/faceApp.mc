import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Background;

var apiResponsePackage = null;
var lastApiRequestFailed = true;
var needToRefreshLayout = false;

(:background)
class infocalReduxApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onSettingsChanged() as Void {
        needToRefreshLayout = true;
        Background.registerForTemporalEvent(new Time.Duration(Properties.getValue("api_request_interval") * 60));
    }

    function onStart(state as Dictionary?) as Void
    {
        apiResponsePackage = Application.Storage.getValue("apiResponsePackage");
        Storage.setValue("lastActivityLatLong", [
            34.153717698223126,
            -118.69615083329013
        ]);
        apiResponsePackage = {
            "sunrise"=>1771253900,
            "sunrise_tomorrow"=>1771340228,
            "low"=>45.66,
            "sunset"=>1771292980,
            "high"=>50.16,
            "name"=>"San Francisco",
            "sunset_tomorrow"=>1771379396,
            "temp"=>48.54
        };
    }

    function onStop(state as Dictionary?) as Void
    {
        Application.Storage.setValue("apiResponsePackage", apiResponsePackage);
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (Properties.getValue("use_openweathermap_api"))
        {
            Background.registerForTemporalEvent(new Time.Duration(Properties.getValue("api_request_interval") * 60));
        }
        return [ new infocalReduxView() ];
    }

    function onBackgroundData(data) {
        if (data != null && ((data as Dictionary).get("temp") != null || (data as Dictionary).get("name") != null))
        {
            // var currTime = System.getClockTime();
            // var timeStr = Lang.format("[$1$:$2$:$3$]", [
            //     currTime.hour.format("%02d"),
            //     currTime.min.format("%02d"),
            //     currTime.sec.format("%02d")
            // ]);
            // System.println(timeStr + " App.onBackgroundData()");
            // System.println(data);
            apiResponsePackage = data;
            Storage.setValue("apiResponsePackage", data);
            lastApiRequestFailed = false;
        }
        else
        {
            lastApiRequestFailed = true;
        }
        WatchUi.requestUpdate();
    }

    function getServiceDelegate(){
        return [new infocalReduxServiceDelegate()];
    }
}


function getApp() as infocalReduxApp {
    return Application.getApp() as infocalReduxApp;
}
