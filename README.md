# Water Quality Monitor

This is an affordable, work-in-progress arduino based system that rates/monitors changes in water quality over a period of time. The system could potentially be used to monitor/rate the changes in tap water over time. When a significant change occurs, the system alerts the user. A change in water quality could indicate some form of contamination. 

The system currently monitors total dissolved solids (TDS) and turbidity using homemade sensors. More information is provided in the [wiki](https://github.com/cvtsh248/Water_Quality_Monitor/wiki). 

# Components Required
More information regarding the construction of the sensors and circuitry is in the [wiki](https://github.com/cvtsh248/Water_Quality_Monitor/wiki).
* Computer with functional USB ports.
* Arduino UNO 
* Resistors (10kΩ, 3.3kΩ, 100Ω, 20kΩ), note that you may need resistors of other values, more information is provided in the [wiki](https://github.com/cvtsh248/Water_Quality_Monitor/wiki)
* Wire
* Red LED (for the turbidity sensor)
* Light Dependent Resistor (for the turbidity sensor)
* Bottle Cap (For turbidity sensor, more infornamtion in the [wiki](https://github.com/cvtsh248/Water_Quality_Monitor/wiki))
* Plugpoint with two functional prongs (for the TDS sensor)

# Software Dependencies
* Processing IDE
  * processing.serial
  * controlP5
  * java.io.BufferedWriter
  * java.io.FileWriter
* Arduino IDE
