import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Math;
import Toybox.UserProfile;

import Toybox.Application;

class faceView extends WatchUi.WatchFace {

    var fontComp;
    var fontHour;
    var fontMinute;
    var fontIcon;

    var currentTime;

    var X;
    var Y;

    var maxLocationTextLength;

    var colorAccent;
    var colorAccentDark;
    var colorText;
    var colorBackground;

    var alternatePosition = null;

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
        X = dc.getWidth() / 2;
        Y = dc.getHeight() / 2;

        setLayout(Rez.Layouts.WatchFace(dc));
        fontComp = Graphics.getVectorFont({:face=>"BionicBold", :size=>40}) as Graphics.VectorFont;
        fontHour = Graphics.getVectorFont({:face=>"BionicBold", :size=>96}) as Graphics.VectorFont;  
        fontMinute = Graphics.getVectorFont({:face=>"BionicBold", :size=>172}) as Graphics.VectorFont;  
        fontIcon = WatchUi.loadResource(Rez.Fonts.iconFont);

        if (Properties.getValue("use_alternate_timezone"))
        {
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
        }
        maxLocationTextLength = dc.getTextWidthInPixels("LOREM IPSUM DOLOR SIT", fontComp);

        colorAccent = parseColor("color_ui_accent", Graphics.COLOR_RED);
        colorAccentDark = parseColor("color_ui_accent_dark", Graphics.COLOR_DK_RED);
        colorText = parseColor("color_text", Graphics.COLOR_WHITE);
        colorBackground = parseColor("color_bg", Graphics.COLOR_BLACK);
    }

    function parseColor(key, defaultColor)
    {
        var inputArr = Properties.getValue(key).toUpper().toCharArray();
        if (inputArr.size() == 6)
        {
            for (var i = 0; i < 6; i++)
            {
                var c = inputArr[i];
                if (!(('0' <= c && c <= '9') || ('A' <= c && c <= 'F')))
                {
                    return defaultColor;
                }
            }
            return Properties.getValue(key).toNumberWithBase(16) as Graphics.ColorType;
        }
        return defaultColor;
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


    function getTemperatureTextAndMakeGauge(dc as Dc, degrees as Lang.Number) as Lang.String
    {
        if (!Properties.getValue("use_openweathermap_api") || apiResponsePackage == null)
        {
            return "TEMP N/A";
        }

        var temp = apiResponsePackage.get("temp");
        var low = apiResponsePackage.get("low");
        var high = apiResponsePackage.get("high");

        if (temp != null && low != null && high != null)
        {
            dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
            if (high > low)
            {
                var progress = ((temp.toDouble() - low)/(high - low));
                var tickDegree = degrees + 10 - 20 * progress;
                var dir = Graphics.ARC_CLOCKWISE;
                var phi = degrees + 10;
                var psi = degrees - 10;
                if (degrees > 180)
                {
                    tickDegree = degrees - 10 + 20 * progress;
                    dir = Graphics.ARC_COUNTER_CLOCKWISE;
                    phi = degrees - 10;
                    psi = degrees + 10;
                }
                drawProgressArc(
                    dc,
                    X,
                    Y,
                    180,
                    dir,
                    phi,
                    psi,
                    progress,
                    5,
                    5,
                    colorAccent,
                    colorAccentDark,
                    false
                );
                dc.drawRadialText(
                    X,
                    Y,
                    fontComp,
                    temp.format("%d"),
                    Graphics.TEXT_JUSTIFY_CENTER,
                    tickDegree,
                    degrees > 180 ? 160 : 140,
                    degrees > 180 ? Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE : Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE
                );
            }
            dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);
            var whitespace = degrees > 180 ? "            " : "          ";
            return Lang.format(
                "$1$" + whitespace + "$2$",
                [low.format("%d"), high.format("%d")]
            );
        }
        return "TEMP N/A";
    }

    function formatGregorianInfoAsTimeString(info as Time.Gregorian.Info)
    {
        var timeStr = "";
        if (Properties.getValue("use_military_time"))
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


    function getNumNotifsText() as Lang.String
    {
        return "NOTIF " + System.getDeviceSettings().notificationCount.format("%d");
    }

    function drawSmallRadialComplicationAtPosition(dc as Dc, text, angle)
    {
        var radius = angle > 180 ? 190 : 170;
        var direction = angle > 180
            ? Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
            : Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE;
        dc.drawRadialText(X, Y, fontComp, text, Graphics.TEXT_JUSTIFY_CENTER, angle, radius, direction);
    }

    function drawIndividualComplication(dc as Dc, angle, comp_id)
    {
        var text = "";
        switch (Properties.getValue(comp_id))
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
                text = getTemperatureTextAndMakeGauge(dc, angle);
                break;
            case 5:
                text = getNumNotifsText();
                break;
            case 6:
                text = Lang.format("$1$ $2$", [currentTime.day_of_week.toUpper(), currentTime.day]);
                break;
            case 7:
                text = Lang.format("$1$ $2$ $3$",
                    [currentTime.day_of_week.toUpper(), currentTime.day, currentTime.month.toUpper()]);
                break;
            case 8:
                text = Lang.format("$1$ $3$ $2$",
                    [currentTime.day_of_week.toUpper(), currentTime.day, currentTime.month.toUpper()]);
                break;
            default:
                break;
        }
        drawSmallRadialComplicationAtPosition(dc, text, angle);
    }


    function drawSmallRadialComplications(dc as Dc)
    {
        drawIndividualComplication(dc, 90, "comp_12");
        drawIndividualComplication(dc, 30, "comp_2");
        drawIndividualComplication(dc, 330, "comp_4");
        if (!Properties.getValue("override_6_and_8_comps"))
        {
            drawIndividualComplication(dc, 270, "comp_6");
            drawIndividualComplication(dc, 210, "comp_8");
        }
    }


    function drawBigMinutes(dc as Dc)
    {
        var minutesText = currentTime.min.format("%02d");
        var dim = dc.getTextDimensions(minutesText, fontMinute);
        dc.drawText(X, Y - dim[1] / 2, fontMinute, minutesText, Graphics.TEXT_JUSTIFY_CENTER);
    }


    function drawAlternateTimezone(dc as Dc)
    {
        if (Properties.getValue("use_alternate_timezone") && alternatePosition != null)
        {
            var info = Gregorian.info(Gregorian.localMoment(alternatePosition, Time.now()),Time.FORMAT_SHORT);
            var timeStr = formatGregorianInfoAsTimeString(info);
            dc.drawText(X, Y - 90, fontComp, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }


    function drawDateHour(dc)
    {
        dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);
        var hourStr = (((currentTime.hour + 11) % 12) + 1).format("%d");
        if (Properties.getValue("use_military_time") || System.getDeviceSettings().is24Hour)
        {
            hourStr = currentTime.hour.format("%02d");
        }
        var dateStr = Lang.format("$1$ $2$", [
            currentTime.day_of_week.toUpper(),
            currentTime.day.format("%d")
        ]);

        var hourStrWidth = dc.getTextWidthInPixels(hourStr, fontHour);
        var yAxis = X - 70;
        var hourStrHeight = Y - 80;
        var dateStrHeight = hourStrHeight - 40;
        dc.drawText(yAxis, hourStrHeight, fontHour, hourStr, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(yAxis - hourStrWidth / 2, dateStrHeight, fontComp, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(5);
        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        var lineLen = 60;
        dc.drawLine(
            yAxis - (hourStrWidth + lineLen) / 2,
            Y - 76,
            yAxis - (hourStrWidth - lineLen) / 2,
            Y - 76
        );
    }


    function drawLocationName(dc)
    {
        var location = "WAITING FOR LOCATION" ;
        switch (Properties.getValue("location_name_type"))
        {
            case 0:
                if (Properties.getValue("use_openweathermap_api") && apiResponsePackage != null)
                {
                    var name = apiResponsePackage.get("name");
                    if (name != null)
                    {
                        location = name.toUpper();
                        var locationNameWidth = dc.getTextWidthInPixels(location, fontComp);
                        if (locationNameWidth > maxLocationTextLength)
                        {
                            location = location.substring(0, 21) + "...";
                        }
                    }
                }
                break;
            case 1:
                var latlon = Storage.getValue("lastActivityLatLong") as Array;
                if (latlon != null)
                {
                    var lat = latlon[0];
                    var lon = latlon[1];
                    location = Lang.format("$1$, $2$", [lat.format("%.04f"), lon.format("%.04f")]);
                }
                break;
            case 2:
                var grid = Storage.getValue("lastActivityGrid");
                if (grid != null)
                {
                    location = grid;
                }
                break;
        }
        dc.drawRadialText(
            X,
            Y,
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
        if (Properties.getValue("use_openweathermap_api") && apiResponsePackage != null)
        {
            var sunrise = apiResponsePackage.get("sunrise");
            var sunset = apiResponsePackage.get("sunset");
            if (sunrise != null && sunset != null)
            {
                var sunrise_moment = new Time.Moment(sunrise);
                var sunset_moment = new Time.Moment(sunset);

                var diff = sunset_moment.value() - sunrise_moment.value();
                if (diff == 0)
                {
                    return;
                }
                var now = Time.now();
                var progress = (now.value().toDouble() - sunrise_moment.value()) / diff;

                if (progress > 1)
                {
                    sunrise = apiResponsePackage.get("sunrise_tomorrow");
                    sunset = apiResponsePackage.get("sunset_tomorrow");
                    if (sunrise == null || sunset == null)
                    {
                        return;
                    }
                    sunrise_moment = new Time.Moment(sunrise);
                    sunset_moment = new Time.Moment(sunset);
                    diff = sunset_moment.value() - sunrise_moment.value();
                    if (diff == 0)
                    {
                        return;
                    }
                    progress = (now.value().toDouble() - sunrise_moment.value()) / diff;
                }

                var sunrise_str = formatGregorianInfoAsTimeString(
                    Time.Gregorian.info(sunrise_moment, Time.FORMAT_SHORT));
                var sunset_str = formatGregorianInfoAsTimeString(
                    Time.Gregorian.info(sunset_moment, Time.FORMAT_SHORT));

                dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
                dc.drawRadialText(
                    X,
                    Y,
                    fontComp,
                    sunrise_str + "                  " + sunset_str,
                    Graphics.TEXT_JUSTIFY_CENTER,
                    240,
                    160,
                    Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
                );

                dc.setColor(colorAccentDark, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    X + 125 * Math.cos(Math.toRadians(240)),
                    Y - 125 * Math.sin(Math.toRadians(240)) - 16,
                    fontIcon,
                    "I",
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                drawProgressArc(
                    dc,
                    X,
                    Y,
                    150,
                    Graphics.ARC_COUNTER_CLOCKWISE,
                    240 - 20,
                    240 + 20,
                    progress,
                    5,
                    5,
                    colorAccent,
                    colorAccentDark,
                    false
                );
            }
        }
    }

    function drawDial(dc as Dc)
    {
        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        var R = 200;
        var r = 175;

        dc.drawLine(X + r, Y, X + R, Y);
        dc.drawLine(X - r, Y, X - R, Y);
        dc.drawLine(
            X + r * Math.cos(Math.toRadians(60)),
            Y - r * Math.sin(Math.toRadians(60)),
            X + R * Math.cos(Math.toRadians(60)),
            Y - R * Math.sin(Math.toRadians(60))
        );
        dc.drawLine(
            X + r * Math.cos(Math.toRadians(120)),
            Y - r * Math.sin(Math.toRadians(120)),
            X + R * Math.cos(Math.toRadians(120)),
            Y - R * Math.sin(Math.toRadians(120))
        );
        dc.drawLine(
            X + r * Math.cos(Math.toRadians(-60)),
            Y - r * Math.sin(Math.toRadians(-60)),
            X + R * Math.cos(Math.toRadians(-60)),
            Y - R * Math.sin(Math.toRadians(-60))
        );
        if (!Properties.getValue("override_6_and_8_comps"))
        {
            dc.drawLine(
                X + r * Math.cos(Math.toRadians(-120)),
                Y - r * Math.sin(Math.toRadians(-120)),
                X + R * Math.cos(Math.toRadians(-120)),
                Y - R * Math.sin(Math.toRadians(-120))
            );
        }
    }

    function drawProgressArc(dc, x, y, radius, arcDirection, angleStart, angleEnd, completedAmount, barWidth, progressWidth, colorFg, colorBg, rounded)
    {
        // outer arc
        dc.setPenWidth(barWidth);
        dc.setColor(colorBg, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(x, y, radius, arcDirection, angleStart, angleEnd);

        if (rounded)
        {
            dc.setPenWidth(1);
            dc.fillCircle(
                x + radius * Math.cos(Math.toRadians(angleStart)),
                y - radius * Math.sin(Math.toRadians(angleStart)),
                barWidth / 2 - 1
            );
            dc.fillCircle(
                x + radius * Math.cos(Math.toRadians(angleEnd)),
                y - radius * Math.sin(Math.toRadians(angleEnd)),
                barWidth / 2 - 1
            );
        }

        if (completedAmount <= 0) { return; }

        // inner arc
        dc.setPenWidth(progressWidth);
        dc.setColor(colorFg, Graphics.COLOR_TRANSPARENT);
        var progress = completedAmount > 1 ? 1 : completedAmount;

        var phi = (angleStart % 360 + 360) % 360;
        var psi = (angleEnd % 360 + 360) % 360;
        var psi_hat;

        if (arcDirection == Graphics.ARC_COUNTER_CLOCKWISE && phi >= psi)
        { psi_hat = phi + progress * (360 - phi + psi); }
        else if (arcDirection == Graphics.ARC_COUNTER_CLOCKWISE)
        { psi_hat = phi + progress * (psi - phi); }
        else if (arcDirection == Graphics.ARC_CLOCKWISE && phi >= psi)
        { psi_hat = phi - progress * (phi - psi); }
        else { psi_hat = phi - progress * (360 + phi - psi); }
        dc.drawArc(x, y, radius, arcDirection, phi, psi_hat);

        if (rounded)
        {
            dc.setPenWidth(1);
            dc.fillCircle(
                x + radius * Math.cos(Math.toRadians(phi)),
                y - radius * Math.sin(Math.toRadians(phi)),
                progressWidth / 2 - 1
            );
            dc.fillCircle(
                x + radius * Math.cos(Math.toRadians(psi_hat)),
                y - radius * Math.sin(Math.toRadians(psi_hat)),
                progressWidth / 2 - 1
            );
        }
    }

    function drawStepGoalGauge(dc as Dc, angle)
    {
        var info = ActivityMonitor.getInfo();
        var steps = info.steps;
        var stepGoal = info.stepGoal;

        if (steps != null && stepGoal != null)
        {
            dc.drawText(
                X + 130 * Math.cos(Math.toRadians(angle)),
                Y - 130 * Math.sin(Math.toRadians(angle)) - 10,
                fontIcon,
                steps < stepGoal ? "H" : "C",
                Graphics.TEXT_JUSTIFY_CENTER
            );
            var phi = angle + 20;
            var psi = angle - 20;
            var dir = Graphics.ARC_CLOCKWISE;
            if (angle > 180)
            {
                phi = angle - 20;
                psi = angle + 20;
                dir = Graphics.ARC_COUNTER_CLOCKWISE;
            }
            drawProgressArc(
                dc,
                X,
                Y,
                150,
                dir,
                phi,
                psi,
                steps.toDouble() / stepGoal,
                5,
                5,
                colorAccent,
                colorAccentDark,
                false
            );
        }
    }
    
    function drawBatteryGauge(dc as Dc, angle)
    {
        dc.setColor(colorAccentDark, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            X + 125 * Math.cos(Math.toRadians(angle)),
            Y - 125 * Math.sin(Math.toRadians(angle)) - 16,
            fontIcon,
            "B",
            Graphics.TEXT_JUSTIFY_CENTER
        );
        var phi = angle + 20;
        var psi = angle - 20;
        var dir = Graphics.ARC_CLOCKWISE;
        if (angle > 180)
        {
            phi = angle - 20;
            psi = angle + 20;
            dir = Graphics.ARC_COUNTER_CLOCKWISE;
        }
        drawProgressArc(
            dc,
            X,
            Y,
            150,
            dir,
            phi,
            psi,
            Math.ceil(System.getSystemStats().battery) / 100,
            5,
            5,
            colorAccent,
            colorAccentDark,
            false
        );
    }

    function drawHeartRateZoneGauge(dc as Dc, angle)
    {
        var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
        var activity = Activity.getActivityInfo();
        var hr = 0;
        if (activity != null && activity.currentHeartRate != null)
        {
            hr = activity.currentHeartRate;
        }
        var currZone = 0;
        // draw dark bars
        for (var i = 1; i <= 5; i++)
        {
            if (hr >= zones[i])
            {
                currZone = i;
            }
            dc.setColor(colorAccentDark, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(5);
            dc.drawArc(X, Y, 150, Graphics.ARC_CLOCKWISE,
                angle + 30 - 12 * (i - 1) - 1,
                angle + 30 - 12 * i + 1
            );
        }
        // draw highlighted bar
        if (currZone != 0)
        {
            dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(8);
            var currZoneIdx = angle <= 180 ? currZone : 6 - currZone;
            dc.drawArc(X, Y, 150, Graphics.ARC_CLOCKWISE,
                angle + 30 - 12 * (currZoneIdx - 1) - 1,
                angle + 30 - 12 * currZoneIdx + 1
            );
        }
    }

    function drawIndividualSmallComplicationGauge(dc as Dc, angle, comp_id)
    {
        switch (Properties.getValue(comp_id))
        {
            case 1: // heart
                drawHeartRateZoneGauge(dc, angle);
                break;
            case 2: // step
                drawStepGoalGauge(dc, angle);
                break;
            case 3: // battery
                drawBatteryGauge(dc, angle);
                break;
            default:
                break;
        }
    }

    function drawSmallComplicationGauges(dc as Dc)
    {
        drawIndividualSmallComplicationGauge(dc, 90, "comp_12_gauge");
        drawIndividualSmallComplicationGauge(dc, 30, "comp_2_gauge");
        drawIndividualSmallComplicationGauge(dc, 330, "comp_4_gauge");
        if (!Properties.getValue("override_6_and_8_comps"))
        {
            drawIndividualSmallComplicationGauge(dc, 270, "comp_6_gauge");
            drawIndividualSmallComplicationGauge(dc, 210, "comp_8_gauge");
        }
    }

    function drawStatusIcons(dc as Dc)
    {
        dc.setColor(colorAccentDark, Graphics.COLOR_TRANSPARENT);
        var statusIconStr = "";
        var deviceSettings = System.getDeviceSettings();
        if (Properties.getValue("show_if_phone_connected"))
        {
            statusIconStr += deviceSettings.phoneConnected ? "D" : "E";
        }
        if (Properties.getValue("show_if_alarms_set") && deviceSettings.alarmCount > 0)
        {
            statusIconStr += "A";
        }
        if (Properties.getValue("show_if_do_not_disturb") && deviceSettings.doNotDisturb)
        {
            statusIconStr += "G";
        }
        if (Properties.getValue("show_if_api_failed") && lastApiRequestFailed)
        {
            statusIconStr += "F";
        }

        if (statusIconStr.length() > 0)
        {
            var statusIconStrSpaces = "";
            for (var i = 0; i < statusIconStr.length(); i++)
            {
                statusIconStrSpaces += statusIconStr.substring(i, i + 1);
                if (i < statusIconStr.length() - 1)
                {
                    statusIconStrSpaces += " ";
                }
            }
            dc.drawText(X, 245, fontIcon, statusIconStrSpaces, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function onUpdate(dc as Dc) as Void
    {
        currentTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var lastActivityLocation = Activity.getActivityInfo().currentLocation;
        if (lastActivityLocation != null)
        {
            Application.Storage.setValue("lastActivityLatLong", lastActivityLocation.toDegrees());
            Application.Storage.setValue("lastActivityMGRS", lastActivityLocation.toGeoString(Position.GEO_MGRS));
        }

        View.onUpdate(dc);
        
        dc.setColor(Graphics.COLOR_TRANSPARENT, colorBackground);
        dc.clear();

        dc.setAntiAlias(true);

        dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);

        drawSmallRadialComplications(dc);
        
        drawBigMinutes(dc);
        drawAlternateTimezone(dc);

        if (Properties.getValue("override_6_and_8_comps"))
        {
            drawLocationName(dc);
            drawSunriseSunset(dc);
        }

        drawDateHour(dc);
        drawDial(dc);

        drawSmallComplicationGauges(dc);

        drawStatusIcons(dc);
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
