import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Math;
import Toybox.UserProfile;

import Toybox.Application;

class infocalReduxView extends WatchUi.WatchFace {

    var fontComp;
    var fontMedium;
    var fontBig;
    var fontBigOutline;
    var fontIcon;

    var currentTime;

    var X;
    var Y;

    var colorAccent;
    var colorAccentDark;
    var colorText;
    var colorBackground;

    var alternatePosition = null;

    var inLowPower = false;

    var OUTER_COMPLICATION_TEXT_RADIUS_CCW;
    var OUTER_COMPLICATION_TEXT_RADIUS_CW;
    var STATUS_ICON_Y_LEVEL;
    var SECONDS_X_FOR_BIG_MINUTES;
    var SECONDS_Y_FOR_BIG_MINUTES;
    var GAUGE_ARC_RADIUS;
    var AOD_H_M_SPACING;
    var GAUGE_ICON_RADIUS;
    var DIAL_INNER_RADIUS;
    var UI_LINE_WIDTH;
    var HATCH_LINE_WIDTH;
    var HATCH_LINE_SEP;
    var INNER_COMPLICATION_TEXT_RADIUS_CCW;
    var INNER_COMPLICATION_TEXT_RADIUS_CW;
    var OUTER_GAUGE_RADIUS;
    var HORIZONTAL_COMPLICATION_Y;
    var MAX_LOCATION_TEXT_WIDTH;
    var MAX_LOCATION_TEXT_LENGTH;
    var TEMP_GAUGE_WHITESPACE_CCW;
    var TEMP_GAUGE_WHITESPACE_CW;
    var SUN_GAUGE_WHITESPACE;
    var DATE_HOUR_LEFT_XOFF;
    var DATE_HOUR_RIGHT_XOFF;
    var HOUR_STR_Y;
    var DATE_STR_Y;
    var DATE_HOUR_SEP_Y;
    var SECONDS_X_FOR_INLINE_TIME;


    function initialize()
    {
        WatchFace.initialize();
    }


    function onLayout(dc as Dc) as Void {
        X = dc.getWidth() / 2;
        Y = dc.getHeight() / 2;

        setLayout(Rez.Layouts.WatchFace(dc));

        fontBigOutline = WatchUi.loadResource(Rez.Fonts.BionicBigOutline);
        OUTER_COMPLICATION_TEXT_RADIUS_CCW = X - 5;
        OUTER_COMPLICATION_TEXT_RADIUS_CW = X - 25;
        STATUS_ICON_Y_LEVEL = X * 51 / 40;
        SECONDS_X_FOR_BIG_MINUTES = X * 3 / 2;
        SECONDS_Y_FOR_BIG_MINUTES = Y * 11 / 10;
        GAUGE_ARC_RADIUS = X * 7 / 9;
        AOD_H_M_SPACING = 6;
        GAUGE_ICON_RADIUS = X * 5 / 8;
        DIAL_INNER_RADIUS = X * 9 / 10;
        UI_LINE_WIDTH = 5;
        INNER_COMPLICATION_TEXT_RADIUS_CCW = X - 35;
        INNER_COMPLICATION_TEXT_RADIUS_CW = X - 55;
        OUTER_GAUGE_RADIUS = X - 15;
        HORIZONTAL_COMPLICATION_Y = Y * 11 / 20;
        DATE_HOUR_LEFT_XOFF = X * 12 / 20;
        DATE_HOUR_RIGHT_XOFF = X * 34 / 20;
        HOUR_STR_Y = Y * 14 / 20;
        DATE_STR_Y = Y * 9 / 20;
        DATE_HOUR_SEP_Y = Y * 13 / 20;
        HATCH_LINE_WIDTH = 3;
        SECONDS_X_FOR_INLINE_TIME = X * 9 / 5;

        switch (dc.getWidth())
        {
            case 360: // fr265s
                fontBig = WatchUi.loadResource(Rez.Fonts.Bionic158);
                fontComp = Graphics.getVectorFont({:face=>"BionicBold", :size=>40}) as Graphics.VectorFont;
                fontMedium = WatchUi.loadResource(Rez.Fonts.Bionic88);
                OUTER_COMPLICATION_TEXT_RADIUS_CCW = X - 4;
                INNER_COMPLICATION_TEXT_RADIUS_CCW = X - 32;
                INNER_COMPLICATION_TEXT_RADIUS_CW = X - 52;
                UI_LINE_WIDTH = 4;
                MAX_LOCATION_TEXT_WIDTH = dc.getTextWidthInPixels("LOREM IPSUM DOLOR SIT", fontComp);
                MAX_LOCATION_TEXT_LENGTH = 21;
                TEMP_GAUGE_WHITESPACE_CCW = "            ";
                TEMP_GAUGE_WHITESPACE_CW = "          ";
                SUN_GAUGE_WHITESPACE = "              ";
                HATCH_LINE_WIDTH = 2;
                HATCH_LINE_SEP = 10;
                break;
            case 390: // fr165, fr165m
                fontBig = WatchUi.loadResource(Rez.Fonts.Bionic172);
                fontComp = Graphics.getVectorFont({:face=>"BionicBold", :size=>40}) as Graphics.VectorFont;
                fontMedium = WatchUi.loadResource(Rez.Fonts.Bionic96);
                MAX_LOCATION_TEXT_WIDTH = dc.getTextWidthInPixels("LOREM IPSUM DOLOR SIT", fontComp);
                MAX_LOCATION_TEXT_LENGTH = 21;
                TEMP_GAUGE_WHITESPACE_CCW = "            ";
                TEMP_GAUGE_WHITESPACE_CW = "          ";
                SUN_GAUGE_WHITESPACE = "              ";
                HATCH_LINE_SEP = 12;
                break;
            case 416: // fr265
                fontBig = WatchUi.loadResource(Rez.Fonts.Bionic182);
                fontComp = Graphics.getVectorFont({:face=>"BionicBold", :size=>40}) as Graphics.VectorFont;
                fontMedium = WatchUi.loadResource(Rez.Fonts.Bionic100);
                MAX_LOCATION_TEXT_WIDTH = dc.getTextWidthInPixels("LOREM IPSUM DOLOR SIT AMET", fontComp);
                MAX_LOCATION_TEXT_LENGTH = 25;
                TEMP_GAUGE_WHITESPACE_CCW = "             ";
                TEMP_GAUGE_WHITESPACE_CW = "           ";
                SUN_GAUGE_WHITESPACE = "                ";
                HATCH_LINE_SEP = 12;
                break;
            case 454: // fr965
                fontBig = WatchUi.loadResource(Rez.Fonts.Bionic200);
                fontComp = Graphics.getVectorFont({:face=>"BionicBold", :size=>44}) as Graphics.VectorFont;
                fontMedium = WatchUi.loadResource(Rez.Fonts.Bionic110);
                MAX_LOCATION_TEXT_WIDTH = dc.getTextWidthInPixels("LOREM IPSUM DOLOR SIT AMET", fontComp);
                MAX_LOCATION_TEXT_LENGTH = "LOREM IPSUM DOLOR SIT AMET".length();
                TEMP_GAUGE_WHITESPACE_CCW = "              ";
                TEMP_GAUGE_WHITESPACE_CW = "            ";
                SUN_GAUGE_WHITESPACE = "                 ";
                INNER_COMPLICATION_TEXT_RADIUS_CCW = X - 40;
                INNER_COMPLICATION_TEXT_RADIUS_CW = X - 60;
                HATCH_LINE_SEP = 15;
                break;
            default:
                break;
        }

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
        // heartRateText = "HR 130";
        if (activity != null && activity.currentHeartRate != null)
        {
            heartRateText = Lang.format("HR $1$", [activity.currentHeartRate.format("%d")]);
        }
        return heartRateText;
    }


    function getStepsText() as Lang.String
    {
        var steps = ActivityMonitor.getInfo().steps;
        return steps == null ? "STP --" : Lang.format("STP $1$k", [(((steps / 100) * 100).toDouble() / 1000).format("%.1f")]);
    }


    function getBatteryText() as Lang.String
    {
        var battery = Math.ceil(System.getSystemStats().battery);
        return Lang.format("BTY $1$", [battery.format("%d")]);
    }


    function getBatteryDaysLeftText() as Lang.String
    {
        return System.getSystemStats().batteryInDays.format("%0.1f") + " DAYS";
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
                    OUTER_GAUGE_RADIUS,
                    dir,
                    phi,
                    psi,
                    progress,
                    UI_LINE_WIDTH,
                    UI_LINE_WIDTH,
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
                    degrees > 180 ? INNER_COMPLICATION_TEXT_RADIUS_CCW : INNER_COMPLICATION_TEXT_RADIUS_CW,
                    degrees > 180 ? Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE : Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE
                );
            }
            dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);
            var whitespace = degrees > 180 ? TEMP_GAUGE_WHITESPACE_CCW : TEMP_GAUGE_WHITESPACE_CW;
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
        var radius = angle > 180 ? OUTER_COMPLICATION_TEXT_RADIUS_CCW : OUTER_COMPLICATION_TEXT_RADIUS_CW;
        var direction = angle > 180
            ? Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
            : Graphics.RADIAL_TEXT_DIRECTION_CLOCKWISE;
        dc.drawRadialText(X, Y, fontComp, text, Graphics.TEXT_JUSTIFY_CENTER, angle, radius, direction);
    }


    function drawHorizontalComplication(dc as Dc)
    {
        var text = "";
        dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);
        switch (Properties.getValue("comp_horizontal"))
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
                // nothing - temperature gauge is unavailable here due to the space it takes up
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
            case 9:
                text = getAlternateTimezoneText();
                break;
            case 10:
                text = getBatteryDaysLeftText();
                break;
            default:
                break;
        }
        dc.drawText(X, HORIZONTAL_COMPLICATION_Y, fontComp, text, Graphics.TEXT_JUSTIFY_CENTER);
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
            case 9:
                text = getAlternateTimezoneText();
                break;
            case 10:
                text = getBatteryDaysLeftText();
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
        drawIndividualComplication(dc, 150, "comp_10");
        if (!Properties.getValue("override_6_and_8_comps"))
        {
            drawIndividualComplication(dc, 270, "comp_6");
            drawIndividualComplication(dc, 210, "comp_8");
        }
    }


    function getAlternateTimezoneText() as Lang.String
    {
        if (Properties.getValue("use_alternate_timezone") && alternatePosition != null)
        {
            var info = Gregorian.info(Gregorian.localMoment(alternatePosition, Time.now()),Time.FORMAT_SHORT);
            return formatGregorianInfoAsTimeString(info);
        }
        return "--";
    }


    function drawBigMinutes(dc as Dc, showSeconds)
    {
        var minutesText = currentTime.min.format("%02d");
        var dim = dc.getTextDimensions(minutesText, fontBig);
        dc.drawText(X, Y - dim[1] / 2, fontBig, minutesText, Graphics.TEXT_JUSTIFY_CENTER);

        if (showSeconds)
        {
            dc.drawText(SECONDS_X_FOR_BIG_MINUTES, SECONDS_Y_FOR_BIG_MINUTES, fontComp, currentTime.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if (Properties.getValue("draw_hatch_lines"))
        {
            drawHatchLines(dc, -90);
        }
    }


    function drawDateHour(dc, xoff)
    {
        var layoutFormat = Properties.getValue("time_display_layout");
        if (layoutFormat == 2)
        {
            return;
        }

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

        var hourStrWidth = dc.getTextWidthInPixels(hourStr, fontMedium);
        // var hourStrHeight = Y - 60;
        // var dateStrHeight = Y - 110;
        var hourStrHeight = HOUR_STR_Y;
        var dateStrHeight = DATE_STR_Y;
        dc.drawText(xoff, hourStrHeight, fontMedium, hourStr, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(xoff - hourStrWidth / 2, dateStrHeight, fontComp, dateStr, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setPenWidth(UI_LINE_WIDTH);
        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        var lineLen = 60;
        dc.drawLine(
            xoff - (hourStrWidth + lineLen) / 2,
            DATE_HOUR_SEP_Y,
            xoff - (hourStrWidth - lineLen) / 2,
            DATE_HOUR_SEP_Y
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
                        if (locationNameWidth > MAX_LOCATION_TEXT_WIDTH)
                        {
                            location = location.substring(0, MAX_LOCATION_TEXT_LENGTH) + "...";
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
            OUTER_COMPLICATION_TEXT_RADIUS_CCW,
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
                // now = new Time.Moment(1771360496);
                // System.println(now.value());
                // System.println(sunrise_moment.value());
                // System.println(sunset_moment.value());
                // System.println("");
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
                    sunrise_str + SUN_GAUGE_WHITESPACE  + sunset_str,
                    Graphics.TEXT_JUSTIFY_CENTER,
                    240,
                    INNER_COMPLICATION_TEXT_RADIUS_CCW,
                    Graphics.RADIAL_TEXT_DIRECTION_COUNTER_CLOCKWISE
                );

                dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
                dc.drawText(
                    X + GAUGE_ICON_RADIUS * Math.cos(Math.toRadians(240)),
                    Y - GAUGE_ICON_RADIUS * Math.sin(Math.toRadians(240)),
                    fontIcon,
                    "I",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
                );
                drawProgressArc(
                    dc,
                    X,
                    Y,
                    GAUGE_ARC_RADIUS,
                    Graphics.ARC_COUNTER_CLOCKWISE,
                    240 - 15,
                    240 + 15,
                    progress,
                    UI_LINE_WIDTH,
                    UI_LINE_WIDTH,
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
        dc.setPenWidth(UI_LINE_WIDTH);
        var R = X + 5;
        var r = DIAL_INNER_RADIUS;

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
            dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                X + GAUGE_ICON_RADIUS * Math.cos(Math.toRadians(angle)),
                Y - GAUGE_ICON_RADIUS * Math.sin(Math.toRadians(angle)),
                fontIcon,
                steps < stepGoal ? "H" : "C",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
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
                GAUGE_ARC_RADIUS,
                dir,
                phi,
                psi,
                steps.toDouble() / stepGoal,
                UI_LINE_WIDTH,
                UI_LINE_WIDTH,
                colorAccent,
                colorAccentDark,
                false
            );
        }
    }
    

    function drawBatteryGauge(dc as Dc, angle)
    {
        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            X + GAUGE_ICON_RADIUS * Math.cos(Math.toRadians(angle)),
            Y - GAUGE_ICON_RADIUS * Math.sin(Math.toRadians(angle)),
            fontIcon,
            "B",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
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
            GAUGE_ARC_RADIUS,
            dir,
            phi,
            psi,
            Math.ceil(System.getSystemStats().battery) / 100,
            UI_LINE_WIDTH,
            UI_LINE_WIDTH,
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
        // hr = 130;
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
            dc.setPenWidth(UI_LINE_WIDTH);
            dc.drawArc(X, Y, GAUGE_ARC_RADIUS, Graphics.ARC_CLOCKWISE,
                angle + 30 - 12 * (i - 1) - 1,
                angle + 30 - 12 * i + 1
            );
        }
        // draw highlighted bar
        if (currZone != 0)
        {
            dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(UI_LINE_WIDTH * 3 / 2);
            var currZoneIdx = angle <= 180 ? currZone : 6 - currZone;
            dc.drawArc(X, Y, GAUGE_ARC_RADIUS, Graphics.ARC_CLOCKWISE,
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
        drawIndividualSmallComplicationGauge(dc, 150, "comp_10_gauge");
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
        if (Properties.getValue("status_phone_connected"))
        {
            statusIconStr += deviceSettings.phoneConnected ? "D" : "E";
        }
        if (Properties.getValue("status_alarms_set") && deviceSettings.alarmCount > 0)
        {
            statusIconStr += "A";
        }
        if (Properties.getValue("status_do_not_disturb") && deviceSettings.doNotDisturb)
        {
            statusIconStr += "G";
        }
        if (Properties.getValue("status_api_failed") && lastApiRequestFailed)
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
            dc.drawText(X, STATUS_ICON_Y_LEVEL, fontIcon, statusIconStrSpaces, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }


    function drawInlineTime(dc as Dc, showSeconds)
    {
        var h = (Properties.getValue("use_military_time") || System.getDeviceSettings().is24Hour)
            ? currentTime.hour.format("%02d")
            : (((currentTime.hour + 11) % 12) + 1).format("%02d");
        var m = currentTime.min.format("%02d");

        var hW = dc.getTextWidthInPixels(h, fontBig);
        var mW = dc.getTextWidthInPixels(m, fontBig);
        var middle = (hW + mW) / 2;
        
        dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(X - mW + middle, Y, fontBig, m, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        if (showSeconds)
        {
            dc.drawText(SECONDS_X_FOR_INLINE_TIME, Y, fontComp, currentTime.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
        if (Properties.getValue("draw_hatch_lines"))
        {
            drawHatchLines(dc, -mW + middle - 20);
        }
        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(X + hW - middle, Y, fontBig, h, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    function drawAlwaysOnTime(dc as Dc)
    {
        var h = (Properties.getValue("use_military_time") || System.getDeviceSettings().is24Hour)
            ? currentTime.hour.format("%02d")
            : (((currentTime.hour + 11) % 12) + 1).format("%02d");
        var m = currentTime.min.format("%02d");

        var xoff = currentTime.min % 2 == 0 ? 2 : -2;
        var yoff = (currentTime.min / 2) % 2 == 0 ? 2 : -2;

        dc.setColor(colorAccent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(X - AOD_H_M_SPACING / 2 + xoff, Y + yoff, fontBigOutline, h, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(colorText, Graphics.COLOR_TRANSPARENT);
        dc.drawText(X + AOD_H_M_SPACING / 2 + xoff, Y + yoff, fontBigOutline, m, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }


    function drawTime(dc as Dc)
    {
        var showSeconds = Properties.getValue("show_seconds");
        switch (Properties.getValue("time_display_layout"))
        {
            case 0: // big minutes, date/hour left
                drawBigMinutes(dc, showSeconds);
                drawDateHour(dc, DATE_HOUR_LEFT_XOFF);
                break;
            case 1: // big minutes, date/hour right
                drawBigMinutes(dc, showSeconds);
                drawDateHour(dc, DATE_HOUR_RIGHT_XOFF);
                break;
            case 2: // inline, no date
                drawInlineTime(dc, showSeconds);
                break;
            default:
                break;
        }
    }


    function drawHatchLines(dc as Dc, xoff)
    {
        dc.setColor(colorBackground, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(HATCH_LINE_WIDTH);
        var d = 160;
        for (var i = 0; i < HATCH_LINE_SEP * 12; i += HATCH_LINE_SEP)
        {
            dc.drawLine(X + xoff, Y + i - 100, X + xoff + d - i, Y + d - 100);
        }
    }


    function onUpdate(dc as Dc) as Void
    {
        currentTime = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        // currentTime = Time.Gregorian.info(new Time.Moment(1771360496), Time.FORMAT_MEDIUM);
        if (inLowPower)
        {
            drawAlwaysOnTime(dc);
            return;
        }
        if (needToRefreshLayout)
        {
            onLayout(dc);
        }
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

        drawTime(dc);


        drawHorizontalComplication(dc);
        drawSmallRadialComplications(dc);

        if (Properties.getValue("override_6_and_8_comps"))
        {
            drawLocationName(dc);
            drawSunriseSunset(dc);
        }

        if (Properties.getValue("draw_dial"))
        {
            drawDial(dc);
        }

        drawSmallComplicationGauges(dc);
        drawStatusIcons(dc);
    }


    function onHide() as Void {}


    function onExitSleep() as Void {
        inLowPower = false;
        WatchUi.requestUpdate();
    }


    function onEnterSleep() as Void {
        inLowPower = true;
        WatchUi.requestUpdate();
    }

}
