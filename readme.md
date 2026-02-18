# Infocal Redux

Highly customizable watchface. Uses OpenWeatherMap for reverse-geocoded location names as well as one-call v3.0 temperature/sunrise/sunset.

Inspired by [Infocal](https://github.com/RyanDam/Infocal). Not a fork. Please support the original.

<img src="https://github.com/ycm/infocal-redux/blob/1c5404546302ed772ddceb1af2a702c6f2a3c25b/screenshots/hero.png">

## Screenshots

<p float="left" align="center">
  <img src="https://github.com/ycm/infocal-redux/blob/1c5404546302ed772ddceb1af2a702c6f2a3c25b/screenshots/screen00.png" width="200">
  <img src="https://github.com/ycm/infocal-redux/blob/1c5404546302ed772ddceb1af2a702c6f2a3c25b/screenshots/screen01.png" width="200">
  <img src="https://github.com/ycm/infocal-redux/blob/1c5404546302ed772ddceb1af2a702c6f2a3c25b/screenshots/screen02.png" width="200">
</p>

<p align="center"><b>Always-on display</b></p>

<p align="center">
  <img src="https://github.com/ycm/infocal-redux/blob/f531f3fdbbd4963d0fcda07dd578bc37b0e92422/screenshots/screen-aod.gif">
</p>


## Supported devices

- Made for FRx65 devices (165 through 965). Tested on ConnectIQ simulator. Tested on physical 165m. Probably works for some other devices. Submit an issue or a PR.

## FAQ

**Custom colors not working**

Ensure colors are in `xxxxxx` hex format, without a leading `#`.

**Alternate timezone**

User-preset alternate timezones are not accessible from the watchface. As a workaround, to display an alternate timezone with Infocal Redux, enter the coordinates of the location. Daylight savings works out of the box.

**OpenWeatherMap API not working**

A few things to check:

1. Ensure you have a **3.0**-enabled API key. OWM is deprecating the older 2.5 version that many watchfaces use. To get a 3.0 API key you need to add a credit card, but you get 1000 free requests per day. To avoid paying, just set your daily request limit to 1000 in your OWM settings.

2. Ensure your device knows its own location. To refresh the location, **start a GPS-enabled activity** (e.g. running). Make sure the bar turns green, indicating a GPS lock. You can end and discard the activity after a few seconds. Then, once you return to the watchface it will save a copy of this GPS location for the next time it makes an API request. In other words, the location will update everytime you start a GPS-enabled activity.

3. Ensure your phone is connected. The API request is done by the phone, not the watch.
