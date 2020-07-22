# mac-display-focus-follows-cursor

### A tiny swift CMD utility that makes your mac's display focus follow the mouse, like some Linux WMs

This checks for when the display quartz events are being directed to changes, and fake clicks the middle of the left edge of the display to focus the new display.

There could be problems with this approach (mainly with odd windows being focussed), but I'm going to roll with it for the next few days and get to focussing the top-most window as a second step

# Licence
MIT, so have at it
