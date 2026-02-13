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

    var alternatePosition = null;
    var military;

    var maxLocationTextLength = null; // TODO
    var apiResponseFormattedStrings = null; // TODO

    var accentColor;
    var accentColorDark;
    var textColor;

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

        var accentColorInput = Properties.getValue("ui_accent_color").toNumberWithBase(16) as Graphics.ColorType;
        accentColor = accentColorInput == null ? Graphics.COLOR_RED : accentColorInput;
        var accentColorDarkInput = Properties.getValue("ui_accent_color_dark").toNumberWithBase(16) as Graphics.ColorType;
        accentColorDark = accentColorDarkInput == null ? Graphics.COLOR_DK_RED : accentColorDarkInput;
        var textColorInput = Properties.getValue("text_color").toNumberWithBase(16) as Graphics.ColorType;
        textColor = textColorInput == null ? Graphics.COLOR_WHITE : textColorInput;
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
        dc.drawRadialText(X, Y, fontComp, text, Graphics.TEXT_JUSTIFY_CENTER, angle, radius, direction);
    }

    function getTemperatureTextAndMakeGauge(dc as Dc, degrees as Lang.Number) as Lang.String
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
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            // dc.setPenWidth(3);
            // var degreeStart = degrees - 10;
            // var degreeEnd = degrees + 10;
            // dc.drawArc(X, Y, 190, Graphics.ARC_COUNTER_CLOCKWISE, degrees - 10, degrees + 10);
            // dc.drawLine(
            //     X + 180 * Math.cos(Math.toRadians(degreeStart)),
            //     Y - 180 * Math.sin(Math.toRadians(degreeStart)),
            //     X + 190 * Math.cos(Math.toRadians(degreeStart)),
            //     Y - 190 * Math.sin(Math.toRadians(degreeStart))
            // );
            // dc.drawLine(
            //     X + 180 * Math.cos(Math.toRadians(degreeEnd)),
            //     Y - 180 * Math.sin(Math.toRadians(degreeEnd)),
            //     X + 190 * Math.cos(Math.toRadians(degreeEnd)),
            //     Y - 190 * Math.sin(Math.toRadians(degreeEnd))
            // );
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
                    accentColor,
                    accentColorDark,
                    false
                );
                // dc.drawLine(
                //     X + 170 * Math.cos(Math.toRadians(tickDegree)),
                //     Y - 170 * Math.sin(Math.toRadians(tickDegree)),
                //     X + 190 * Math.cos(Math.toRadians(tickDegree)),
                //     Y - 190 * Math.sin(Math.toRadians(tickDegree))
                // );
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
            dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
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
                text = getTemperatureTextAndMakeGauge(dc, 90);
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
                text = getTemperatureTextAndMakeGauge(dc, 30);
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
                text = getTemperatureTextAndMakeGauge(dc, 330);
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
        dc.drawText(X, Y - dim[1] / 2, fontMinute, minutesText, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawAlternateTimezone(dc as Dc)
    {
        if (alternatePosition != null)
        {
            var info = Gregorian.info(Gregorian.localMoment(alternatePosition, Time.now()),Time.FORMAT_SHORT);
            var timeStr = formatGregorianInfoAsTimeString(info);
            dc.drawText(X, Y - 90, fontComp, timeStr, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    function drawGuidelines(dc)
    {
        dc.drawLine(0, Y, X * 2, Y);
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

        var hourStrWidth = dc.getTextWidthInPixels(hourStr, fontHour);
        var yAxis = X - 70;
        var hourStrHeight = Y - 80;
        var dateStrHeight = hourStrHeight - 40;
        dc.drawText(yAxis, hourStrHeight, fontHour, hourStr, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(yAxis - hourStrWidth / 2, dateStrHeight, fontComp, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(5);
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
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
        var location = "";
        if (apiResponsePackage == null)
        {
            location = "NULL LOCATION";
        }
        else
        {
            var name = apiResponsePackage.get("name");
            if (name != null)
            {
                location = name.toUpper();
            }
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
        var sun_text = getSunriseSunsetText();
        dc.drawRadialText(
            X,
            Y,
            fontComp,
            sun_text,
            Graphics.TEXT_JUSTIFY_CENTER,
            240,
            150,
            Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
        );
    }

    function drawDial(dc as Dc)
    {
        dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
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
                steps < stepGoal ? "A" : "C",
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
                accentColor,
                accentColorDark,
                false
            );
        }
    }
    
    function drawBatteryGauge(dc as Dc, angle)
    {
        dc.drawText(
            X + 130 * Math.cos(Math.toRadians(angle)),
            Y - 130 * Math.sin(Math.toRadians(angle)) - 10,
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
            accentColor,
            accentColorDark,
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
            dc.setColor(accentColorDark, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(5);
            dc.drawArc(X, Y, 150, Graphics.ARC_CLOCKWISE,
                angle + 30 - 12 * (i - 1) - 1,
                angle + 30 - 12 * i + 1
            );
        }
        // draw highlighted bar
        if (currZone != 0)
        {
            dc.setColor(accentColor, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(8);
            var currZoneIdx = angle <= 180 ? currZone : 6 - currZone;
            dc.drawArc(X, Y, 150, Graphics.ARC_CLOCKWISE,
                angle + 30 - 12 * (currZoneIdx - 1) - 1,
                angle + 30 - 12 * currZoneIdx + 1
            );
        }
    }

    function drawSmallComplicationGauges(dc as Dc)
    {
        switch (Properties.getValue("comp_12_gauge"))
        {
            case 1: // heart
                drawHeartRateZoneGauge(dc, 90);
                break;
            case 2: // step
                drawStepGoalGauge(dc, 90);
                break;
            case 3: // battery
                drawBatteryGauge(dc, 90);
                break;
            default:
                break;
        }
        switch (Properties.getValue("comp_2_gauge"))
        {
            case 1: // heart
                drawHeartRateZoneGauge(dc, 30);
                break;
            case 2: // step
                drawStepGoalGauge(dc, 30);
                break;
            case 3: // battery
                drawBatteryGauge(dc, 30);
                break;
            default:
                break;
        }
        switch (Properties.getValue("comp_4_gauge"))
        {
            case 1: // heart
                drawHeartRateZoneGauge(dc, 330);
                break;
            case 2: // step
                drawStepGoalGauge(dc, 330);
                break;
            case 3: // battery
                drawBatteryGauge(dc, 330);
                break;
            default:
                break;
        }
    }

    function onUpdate(dc as Dc) as Void
    {
        currentTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        View.onUpdate(dc);

        dc.setAntiAlias(true);

        dc.setColor(textColor, Graphics.COLOR_TRANSPARENT);
        drawSmallRadialComplications(dc);
        
        drawBigMinutes(dc);
        drawAlternateTimezone(dc);

        drawSunriseSunset(dc);
        drawLocationName(dc);

        drawDateHour(dc);
        drawDial(dc);

        drawSmallComplicationGauges(dc);
    }

    function onHide() as Void {}
    function onExitSleep() as Void {}
    function onEnterSleep() as Void {}
}
