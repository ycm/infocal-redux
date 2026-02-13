import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;

var bgData = null;

(:background)
class faceServiceDelegate extends Toybox.System.ServiceDelegate {

	function initialize() {
        System.ServiceDelegate.initialize();
    }

    function onReceiveReverseGeocodeResponse(responseCode as Lang.Number, data as Dictionary or Null) as Void {
        // System.println("facebg.mc -> onReceiveReverseGeocodeResponse() with responseCode " + responseCode.format("%d"));
        var name = null;
        if (responseCode == 200 && data != null)
        {
            if (data.size() < 1)
            {
                name = "unknown location";
            }  
            else
            {
                name = data[0].get("name");
            }
        }
        bgData = {"name" => name};
        makeWeatherRequest();
        // System.println("end faceServiceDelegate onReceiveRev...");
    }

    function onReceiveWeatherResponse(responseCode as Lang.Number, data as Dictionary or Null) as Void
    {
        // System.println("facebg.mc -> onReceiveWeatherResponse() with responseCode " + responseCode.format("%d"));
        var sunrise = null;
        var sunset = null;
        var temp = null;
        var high = null;
        var low = null;

        if (responseCode == 200 && data != null)
        {
            var current = data.get("current") as Dictionary or Null;
            if (current != null)
            {
                sunrise = current.get("sunrise");
                sunset = current.get("sunset");
                temp = current.get("temp");
            }

            var daily = data.get("daily") as Array or Null;
            if (daily != null && daily.size() > 0)
            {
                var today = daily[0] as Dictionary or Null;
                if (today != null)
                {
                    var today_temp_data = today.get("temp") as Dictionary or Null;
                    if (today_temp_data != null)
                    {
                        high = today_temp_data.get("max");
                        low = today_temp_data.get("min");
                    }
                }
            }
        }

        var package = {
            "name" => bgData.get("name"),
            "sunrise" => sunrise,
            "sunset" => sunset,
            "temp" => temp,
            "high" => high,
            "low" => low
        };
        // System.println("package:");
        // System.println(package);
        Background.exit(package);
    }

    function makeWeatherRequest()
    {
        // System.println("start make weather request");
        var psn = Position.getInfo().position;
        if (psn != null)
        {
            var coordinates = psn.toDegrees();
            var url ="https://api.openweathermap.org/data/3.0/onecall";
            var params = {
                "lat" => coordinates[0],
                "lon" => coordinates[1],
                "appid" => Properties.getValue("openweathermap_api_key"),
                "exclude" => "minutely,hourly",
                "units" => Properties.getValue("weather_units") == 0 ? "imperial" : "metric"
            };
            var opts = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
            Communications.makeWebRequest(url, params, opts, method(:onReceiveWeatherResponse));
        }
        // System.println("end make weather request");
    }

    function makeReverseGeocodeRequest()
    {
        // System.println("start make reverse geocode request");
        var psn = Position.getInfo().position;
        if (psn != null)
        {
            var coordinates = psn.toDegrees();
            var url ="https://api.openweathermap.org/geo/1.0/reverse";
            var params = {
                "lat" => coordinates[0],
                "lon" => coordinates[1],
                "appid" => Properties.getValue("openweathermap_api_key")
            };
            var opts = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
            Communications.makeWebRequest(url, params, opts, method(:onReceiveReverseGeocodeResponse));
        }
        // System.println("end make reverse geocode request");
    }

    function onTemporalEvent() as Void {
        // System.println("start ontemporalevent");
        makeReverseGeocodeRequest();
        // System.println("end on tempoeral event");
    }
}