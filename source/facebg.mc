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
        // System.println("reverse geocode responseCode " + responseCode);
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
    }

    function onReceiveWeatherResponse(responseCode as Lang.Number, data as Dictionary or Null) as Void
    {
        // System.println("weather responseCode " + responseCode);
        var sunrise = null;
        var sunset = null;
        var sunrise_tomorrow = null;
        var sunset_tomorrow = null;
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
                if (daily.size() > 1)
                {
                    var tomorrow = daily[1] as Dictionary or Null;
                    if (tomorrow != null)
                    {
                        sunrise_tomorrow = tomorrow.get("sunrise");
                        sunset_tomorrow = tomorrow.get("sunset");
                    }
                }
            }
        }

        var package = {
            "name" => bgData.get("name"),
            "sunrise" => sunrise,
            "sunset" => sunset,
            "sunrise_tomorrow" => sunrise_tomorrow,
            "sunset_tomorrow" => sunset_tomorrow,
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
        // var currTime = System.getClockTime();
        // var timeStr = Lang.format("[$1$:$2$:$3$]", [
        //     currTime.hour.format("%02d"),
        //     currTime.min.format("%02d"),
        //     currTime.sec.format("%02d")
        // ]);
        // System.println(timeStr + " weather request");

        var coordinates = Storage.getValue("lastActivityLatLong");
        if (coordinates != null)
        {
            // System.println(timeStr + " request lat/lon = " + coordinates[0].format("%.02f") + "," + coordinates[1].format("%.02f"));
            var url ="https://api.openweathermap.org/data/3.0/onecall";
            var params = {
                "lat" => (coordinates as Array)[0],
                "lon" => (coordinates as Array)[1],
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
        // else
        // {
        //     System.println(timeStr + " last recorded lat/long is null");
        // }
    }

    function makeReverseGeocodeRequest()
    {
        // var currTime = System.getClockTime();
        // var timeStr = Lang.format("[$1$:$2$:$3$]", [
        //     currTime.hour.format("%02d"),
        //     currTime.min.format("%02d"),
        //     currTime.sec.format("%02d")
        // ]);
        // System.println(timeStr + " reverse geocode request");

        var coordinates = Storage.getValue("lastActivityLatLong");
        if (coordinates != null)
        {
            // System.println(timeStr + " request lat/lon = " + coordinates[0].format("%.02f") + "," + coordinates[1].format("%.02f"));
            var url ="https://api.openweathermap.org/geo/1.0/reverse";
            var params = {
                "lat" => (coordinates as Array)[0],
                "lon" => (coordinates as Array)[1],
                "appid" => Properties.getValue("openweathermap_api_key")
            };
            var opts = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
            Communications.makeWebRequest(url, params, opts, method(:onReceiveReverseGeocodeResponse));
        }
        // else
        // {
        //     System.println(timeStr + " last recorded lat/long is null");
        // }
    }

    function onTemporalEvent() as Void {
        makeReverseGeocodeRequest();
    }
}