//Front End

/*
TO DO:
1. Implement storing of data locally
2. Add turbidity functionality (also need to work on back end)
3. Convert TDS to PPM (maybe, not compulsory as of now given the nature of the project)
4. Work on fixing tds data receiving. Try to remove the need of spamming the button. 
4. Improve GUI?
*/

import controlP5.*;

import processing.serial.*;

import java.io.BufferedWriter;

import java.io.FileWriter;

Serial arduino;

ControlP5 cp5;

void setup() {
  size(400,400);
  
  arduino = new Serial (this, "/dev/ttyACM0", 9600); //initialising arduino serial connection
  arduino.bufferUntil( '\n' );
  
  //gui elements
  cp5 = new ControlP5(this);
  cp5.addButton("TDS").setValue(0).setPosition(20,20).setSize(90,40);
  cp5.addButton("Within_range").setValue(0).setPosition(20,80).setSize(90,40);
  cp5.addButton("Save").setValue(0).setPosition(20,140).setSize(90,40);
  cp5.addButton("Calibration_On").setValue(0).setPosition(20,200).setSize(90,40);
  cp5.addButton("Calibration_Off").setValue(0).setPosition(20,260).setSize(90,40);
}

float std(float data[]) { //function to calculate standard deviation
  float avg = 0;
  float stdev = 0;
  for (int i = 0; i < data.length; i++) { //calculating average
    avg += data[i];
  }
  avg /= data.length;
  for (int i = 0; i < data.length; i++) {
    stdev += sq(data[i]-avg);
  }
  stdev /= data.length; //calculating standard deviation
  stdev = sqrt(stdev);
  return (stdev);
}

boolean within_range(float val, float data[]){ //check whether new value is outside usual standard deviation
  float avg = 0; //average
  float dev = std(data); //standard deviation
  for (int i = 0; i < data.length; i++) { //average calculation
    avg += data[i];
  }
  avg /= data.length;
  if (abs(val - avg) <= dev){ 
    return (true);
  } else {
    return (false);
  }
}

float tds[] = {}; //tds values
String val = null; //buffer
boolean c = false; //calibration mode
boolean range = false; //in acceptable range of standard deviation or not
float s = 0; //variable containing standard deviation

void draw() { //begin application
  background(0); //refresh background
  text("Value of TDS:",160,45);
  if (tds.length > 0 && c == true){
    text(tds[tds.length-1],250,45); //display tds value, in calibration mode: taking value from tds buffer array
  }
  if (c == false && val != null){
    text(float(val),250,45); //display tds value when not in calibration mode
  }
  if (val != null){
    s = std(tds); //calculate standard deviation of the tds array
  }
  text("Standard Deviation:",160,70); //lines 82&83 are responsible for displaying standard deviation
  text(String.format("%.2f", s),290,70);
  text("Abnormal:",160,90); //check for abnormality (i.e. outside acceptable difference based on standard deviation)
  if (range == true){ //uses the boolean function within_range()... Look at bool within_range() for more info. 
    text("False",230,90);
  }
  if (range == false){
    text("True",230,90);
  }
}

//buttons galore
public void TDS() { //TDS button function
  arduino.write('d'); //send the char 'd' to the arduino
  val = arduino.readStringUntil('\n'); //receive the response (spam this button at least 5 times to get fresh data)
}

public void Save() { //Save the data to a list (eventually will append to a file)
  if (Float.isNaN(float(val)) == false){
    if (c == true){ //do so only if calibration mode is enabled
      tds = append(tds, float(val));
    } else {
      val = "Cannot Save\nEnter calibration mode";
    }
  }
}

public void Within_range() { //set the boolean value to check whether water has changed significantly
  range = within_range(float(val), tds);
}

//toggling calibration on and off

public void Calibration_On() { 
  c = true;
}

public void Calibration_Off() {
  c = false;
}
