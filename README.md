This is a [bytebeat synthesizer](http://canonical.org/~kragen/bytebeat)
implemented on the Arduino.  It's not the first bytebeat synthesizer on
the Arduino, but I think it's the first that does real-time composite
video visualizations of the signal, using the [TVout
library](https://github.com/Diex/ar_tvout) hacked to remove its audio
output.

It doesn't have any user interface yet; you have to edit the code to
change which formula it's producing.

I'm running it on an Arduino Duemilanove.  Pin 11 has the audio signal,
pin 9 has sync (through a 1-kilohm resistor), and pin 7 has video
(through a 470-ohm resistor).

![(photo)](http://farm8.staticflickr.com/7196/6935862575_d106936d0f_z_d.jpg)

[Photo by Beatrice Murch, cc-by]
(http://www.flickr.com/photos/blmurch/6935862575/sizes/z/in/photostream/)
