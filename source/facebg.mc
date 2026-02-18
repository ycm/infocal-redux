import Toybox.Background;
import Toybox.System;
import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;

var bgData = null;

(:background)
class infocalReduxServiceDelegate extends Toybox.System.ServiceDelegate {

	function initialize() {
        System.ServiceDelegate.initialize();
    }

    function onReceiveReverseGeocodeResponse(responseCode as Lang.Number, data as Dictionary or Null) as Void {
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

    function onReceiveLegacyWeatherResponse(responseCode as Lang.Number, data as Dictionary or Null) as Void
    {
        var package = {
            "name" => null,
            "sunrise" => null,
            "sunset" => null,
            "sunrise_tomorrow" => null,
            "sunset_tomorrow" => null,
            "temp" => null,
            "high" => null,
            "low" => null
        };

        if (responseCode == 200 && data != null)
        {
            package.put("name", data.get("name") as String or Null);
            var main = data.get("main") as Dictionary or Null;
            if (main != null)
            {
                package.put("temp", main.get("temp"));
                package.put("high", main.get("temp_max"));
                package.put("low", main.get("temp_min"));
            }
            var sys = data.get("sys") as Dictionary or Null;
            if (sys != null)
            {
                var sunrise = sys.get("sunrise") as String or Null;
                var sunset = sys.get("sunset") as String or Null;
                if (sunrise != null && sunset != null)
                {
                    var sunrise_unix = sunrise.toNumber();
                    var sunset_unix = sunset.toNumber();

                    package.put("sunrise", sunrise_unix);
                    package.put("sunset", sunset_unix);
                    package.put("sunrise_tomorrow", sunrise_unix + Time.Gregorian.SECONDS_PER_DAY);
                    package.put("sunset_tomorrow", sunset_unix + Time.Gregorian.SECONDS_PER_DAY);
                }
            }
        }

        Background.exit(package);
    }

    function onReceiveWeatherResponse(responseCode as Lang.Number, data as Dictionary or Null) as Void
    {
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
        Background.exit(package);
    }

    function makeWeatherRequest()
    {
        var coordinates = Storage.getValue("lastActivityLatLong");
        if (coordinates != null)
        {
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
    }

    function makeReverseGeocodeRequest()
    {
        var coordinates = Storage.getValue("lastActivityLatLong");
        if (coordinates != null)
        {
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
    }

    function makeLegacyWeatherRequest()
    {
        var coordinates = Storage.getValue("lastActivityLatLong");
        if (coordinates != null)
        {
            var url ="https://api.openweathermap.org/data/2.5/weather";
            var params = {
                "lat" => (coordinates as Array)[0],
                "lon" => (coordinates as Array)[1],
                "appid" => Properties.getValue("openweathermap_api_key"),
                "units" => Properties.getValue("weather_units") == 0 ? "imperial" : "metric"
            };
            var opts = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
            Communications.makeWebRequest(url, params, opts, method(:onReceiveLegacyWeatherResponse));
        }
    }


    function onTemporalEvent() as Void
    {
        if (Properties.getValue("api_version") == 0) // 3.0
        {
            makeReverseGeocodeRequest();
        }
        else // 2.5
        {
            makeLegacyWeatherRequest();
        }
    }
}