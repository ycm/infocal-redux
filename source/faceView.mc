import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Weather;
import Toybox.Math;

class faceView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    function updateTime() as Void
    {
        var greg = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        (View.findDrawableById("TimeLabel") as Text).setText(Lang.format(
            "$1$$2$",
            [greg.hour.format("%02d"), greg.min.format("%02d")]
        ));
        (View.findDrawableById("DateLabel") as Text).setText(Lang.format(
            "$1$, $2$ $3$",
            [
                (greg.day_of_week as Lang.String).toLower(),
                (greg.month as Lang.String).toLower(),
                greg.day.format("%d")
            ]
        ));
    }

    function updateStepCount() as Void
    {
        var steps = ActivityMonitor.getInfo().steps;
        var stepsText = steps == null ? "step\n--" : Lang.format("step\n$1$", [steps.format("%d")]);
        (View.findDrawableById("StepCountLabel") as Text).setText(stepsText);
    }

    function updateHeartRate() as Void
    {
        var activity = Activity.getActivityInfo();
        var heartRateText = "hr\n--";
        if (activity != null && activity.currentHeartRate != null)
        {
            heartRateText = Lang.format("hr\n$1$", [activity.currentHeartRate.format("%d")]);
        }
        (View.findDrawableById("HeartRateLabel") as Text).setText(heartRateText);
    }

    function updateBattery() as Void
    {
        var battery = Math.ceil(System.getSystemStats().battery);
        var batteryText = Lang.format("bty\n$1$", [battery.format("%d")]);
        (View.findDrawableById("BatteryLabel") as Text).setText(batteryText);
    }

    function updateInfo() as Void
    {
        var cc = Weather.getCurrentConditions();
        var str = "placeholder";
        if (cc != null)
        {
            // var t = cc.temperature;
            var t = cc.observationLocationName;
            if (t != null)
            {
                // str = Lang.format("$1$", [t.format("%d")]);
                str = t;
            }
            else
            {
                str = "t null";
            }
        }
        else
        {
            str = "cc null";
        }
        (View.findDrawableById("InfoLabel") as Text).setText(str);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void
    {
        updateTime();
        updateStepCount();
        updateHeartRate();
        updateBattery();

        updateInfo();

        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
