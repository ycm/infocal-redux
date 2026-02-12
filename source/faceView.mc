import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Math;

import Toybox.Application;

class faceView extends WatchUi.WatchFace {

    var fontComp;
    var fontHour;
    var fontMinute;
    var currentTime;
    var width;
    var height;
    var alternatePosition = null;
    var military;

    var maxLocationTextLength = null; // TODO
    var apiResponseFormattedStrings = null; // TODO

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        width = dc.getWidth();
        height = dc.getHeight();

        setLayout(Rez.Layouts.WatchFace(dc));
        fontComp = Graphics.getVectorFont({:face=>"BionicBold", :size=>40}) as Graphics.VectorFont;
        fontHour = Graphics.getVectorFont({:face=>"BionicBold", :size=>96}) as Graphics.VectorFont;  
        fontMinute = Graphics.getVectorFont({:face=>"BionicBold", :size=>172}) as Graphics.VectorFont;  
        military = Properties.getValue("use_military_time");

        var altLat = Properties.getValue("alt_timezone_lat").toDouble();
        var altLon = Properties.getValue("alt_timezone_lon").toDouble();
        if (altLat != null && altLat != null)
        {
            alternatePosition = new Position.Location({
                :latitude => altLat,
                :longitude => altLon,
                :format => :degrees
            });
        }
        maxLocationTextLength = dc.getTextWidthInPixels("LOREM IPSUM DOLOR SIT", fontComp);

    }

    function onShow() as Void {}

    function getHeartRateText() as Lang.String
    {
        var activity = Activity.getActivityInfo();
        var heartRateText = "HR --";
        if (activity != null && activity.currentHeartRate != null)
        {
            heartRateText = Lang.format("HR $1$", [activity.currentHeartRate.format("%d")]);
        }
        return heartRateText;
    }

    function getStepsText() as Lang.String
    {
        var steps = ActivityMonitor.getInfo().steps;
        return steps == null ? "STP --" : Lang.format("STP $1$", [steps.format("%d")]);
    }

    function getBatteryText() as Lang.String
    {
        var battery = Math.ceil(System.getSystemStats().battery);
        return Lang.format("BTY $1$", [battery.format("%d")]);
    }

    function drawSmallRadialComplicationAtPosition(dc as Dc, text, clock_position)
    {
        var angle = 90, radius = 170, direction = Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE;
        if (clock_position == 2)
        {
            angle = 30;
        }
        if (clock_position == 4)
        {
            angle = -30;
            radius = 190;
            direction = Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE;
        }
        dc.drawRadialText(width / 2, height / 2, fontComp, text, Graphics.TEXT_JUSTIFY_CENTER, angle, radius, direction);
    }

    function getTemperatureText() as Lang.String
    {
        if (apiResponsePackage == null)
        {
            return "TEMP N/A";
        }

        var temp = apiResponsePackage.get("temp");
        var low = apiResponsePackage.get("low");
        var high = apiResponsePackage.get("high");

        if (temp != null && low != null && high != null)
        {
            return Lang.format(
                "$1$ H$2$ L$3$",
                [temp.format("%d"), high.format("%d"), low.format("%d")]
            );
        }
        return "TEMP N/A";
    }

    function formatGregorianInfoAsTimeString(info as Time.Gregorian.Info)
    {
        var timeStr = "";
        if (military)
        {
            timeStr = info.hour.format("%02d") + info.min.format("%02d");
        }
        else if (System.getDeviceSettings().is24Hour)
        {
            timeStr = info.hour.format("%02d") + ":" + info.min.format("%02d");
        }
        else
        {
            timeStr = Lang.format(
                "$1$:$2$$3$",
                [
                    (((info.hour + 11) % 12) + 1),
                    info.min.format("%02d"),
                    info.hour > 11 ? "P" : "A"
                ]
            );
        }
        return timeStr;
    }

    function getSunriseSunsetText() as Lang.String
    {
        if (apiResponsePackage == null)
        {
            return "SUN N/A";
        }

        var sunrise = apiResponsePackage.get("sunrise");
        var sunset = apiResponsePackage.get("sunset");
        
        if (sunrise == null || sunset == null)
        {
            return "SUN N/A";
        }

        var sunrise_moment = new Time.Moment(sunrise);
        var sunset_moment = new Time.Moment(sunset);
        
        var sunrise_moment_info = Time.Gregorian.info(sunrise_moment, Time.FORMAT_MEDIUM);
        var sunset_moment_info = Time.Gregorian.info(sunset_moment, Time.FORMAT_MEDIUM);

        var sunrise_str = formatGregorianInfoAsTimeString(sunrise_moment_info);
        var sunset_str = formatGregorianInfoAsTimeString(sunset_moment_info);

        return sunrise_str + " TO " + sunset_str;
    }

    function getNumNotifsText() as Lang.String
    {
        return "NOTIF " + System.getDeviceSettings().notificationCount.format("%d");
    }

    function drawSmallRadialComplications(dc as Dc)
    {
        var text = "";
        switch (Properties.getValue("comp_12"))
        {
            case 1:
                text = getHeartRateText();
                break;
            case 2:
                text = getStepsText();
                break;
            case 3:
                text = getBatteryText();
                break;
            case 4:
                text = getTemperatureText();
                break;
            case 5:
                text = getNumNotifsText();
                break;
            default:
                break;
        }
        drawSmallRadialComplicationAtPosition(dc, text, 12);
        text = "";
        switch (Properties.getValue("comp_2"))
        {
            case 1:
                text = getHeartRateText();
                break;
            case 2:
                text = getStepsText();
                break;
            case 3:
                text = getBatteryText();
                break;
            case 4:
                text = getTemperatureText();
                break;
            case 5:
                text = getNumNotifsText();
                break;
            default:
                break;
        }
        drawSmallRadialComplicationAtPosition(dc, text, 2);
        text = "";
        switch (Properties.getValue("comp_4"))
        {
            case 1:
                text = getHeartRateText();
                break;
            case 2:
                text = getStepsText();
                break;
            case 3:
                text = getBatteryText();
                break;
            case 4:
                text = getTemperatureText();
                break;
            case 5:
                text = getNumNotifsText();
                break;
            default:
                break;
        }
        drawSmallRadialComplicationAtPosition(dc, text, 4);
    }

    function drawBigMinutes(dc as Dc)
    {
        var minutesText = currentTime.min.format("%02d");
        var dim = dc.getTextDimensions(minutesText, fontMinute);
        dc.drawText(width / 2, (height - dim[1]) / 2, fontMinute, minutesText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawAlternateTimezone(dc as Dc)
    {
        if (alternatePosition != null)
        {
            var info = Gregorian.info(Gregorian.localMoment(alternatePosition, Time.now()),Time.FORMAT_SHORT);
            var timeStr = formatGregorianInfoAsTimeString(info);
            dc.drawText(width / 2 + 96, height / 2 + 45, fontComp, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawGuidelines(dc)
    {
        dc.drawLine(0, height / 2, width, height / 2);
        dc.drawLine(-200 + 195, 200 * Math.tan(60 * 2 * Math.PI / 360) + 195, 200 + 195, -200 * Math.tan(60 * 2 * Math.PI / 360) + 195);
        dc.drawLine(-200 + 195, 200 * Math.tan(-60 * 2 * Math.PI / 360) + 195, 200 + 195, -200 * Math.tan(-60 * 2 * Math.PI / 360) + 195);
    }

    function drawDateHour(dc)
    {
        var hourStr = (((currentTime.hour + 11) % 12) + 1).format("%d");
        if (military || System.getDeviceSettings().is24Hour)
        {
            hourStr = currentTime.hour.format("%02d");
        }
        var dateStr = Lang.format("$1$ $2$", [
            currentTime.day_of_week.toUpper(),
            currentTime.day.format("%d")
        ]);

        var offset = dc.getTextWidthInPixels(hourStr, fontHour);
        dc.drawText(width / 2 - 70, height / 2 - 80, fontHour, hourStr, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(width / 2 - 70 - offset / 2, height / 2 - 100, fontComp, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawLocationName(dc)
    {
        var location = "";
        if (apiResponsePackage == null)
        {
            location = "NULL LOCATION";
        }
        else
        {
            location = apiResponsePackage.get("name").toUpper();
        }

        dc.drawRadialText(
            width / 2,
            height / 2,
            fontComp,
            location,
            Graphics.TEXT_JUSTIFY_CENTER,
            240,
            190,
            Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
        );
    }

    function drawSunriseSunset(dc)
    {
        var sun_text = getSunriseSunsetText();
        dc.drawRadialText(
            width / 2,
            height / 2,
            fontComp,
            sun_text,
            Graphics.TEXT_JUSTIFY_CENTER,
            240,
            150,
            Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
        );
    }

    function onUpdate(dc as Dc) as Void
    {
        currentTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        View.onUpdate(dc);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        drawSmallRadialComplications(dc);
        drawBigMinutes(dc);
        drawDateHour(dc);
        drawAlternateTimezone(dc);

        // drawGuidelines(dc);
        drawSunriseSunset(dc);
        drawLocationName(dc);
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
