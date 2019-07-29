# screenswitcher
PyGTK+Bash based monitor &amp; audio output switcher. Based on cb-exit from crunchbang

# How it works

You run screenswitcher-v2.sh and this draws a window with 3 buttons on it. Each of them for a different display of the ones I have plugged into my machine. I click on one of them and the video output switches from my currently running display to the one I clicked to use. These are bash commands retrieved from the accompanying bash script. 

In order to make it easier for me, I used sed variables to define the PulseAudio sink outputs and XRandr monitor identifiers every time the program runs. Since I only have one monitor of each type (DVI, HDMI and VGA) XRandr differentiates between them easily.

This script can be easily modded to acommodate one's own setup, so in case it's ever useful to anyone, I made this repository for it.
