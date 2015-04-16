# laserCutterUtility
A processing sketch cleaning dense vector files to be lasercut. Also does some handy calculations.

I have a fractal made of thousands of single lines. Cleaning it in regular software is a pain in the ass so I made this script; it might also be useful for you!  

##The script:
 - Loads .svg and exports .pdf  
 - Crops lines to the canvas size. (alt: artboard)   
 - Computes all lines and can guess laser cutter speed and power depending on previous results.  
 - Zones with too much laser passages become holes. A treshold value lets you preview these holes.  
 - Another option remove parts of lines to prevent holes from appearing.

__Note:__ Dirty code, I didn't clean up anything.
