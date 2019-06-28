import controlP5.*;

import processing.serial.*;

Serial arduino;

ControlP5 cp5;

void setup() {
  size(400,400);
  
  arduino = new Serial (this, "/dev/ttyACM0", 9600);
  arduino.bufferUntil( '\n' );
  
  cp5 = new ControlP5(this);
  cp5.addButton("Data").setValue(0).setPosition(20,20).setSize(90,40);
}

float std(float data[]) { //function to calculate standard deviation
  float avg = 0;
  float stdev = 0;
  for (int i = 0; i < data.length; i++) {
    avg += data[i];
  }
  avg /= data.length;
  for (int i = 0; i < data.length; i++) {
    stdev += sq(data[i]-avg);
  }
  stdev /= data.length;
  stdev = sqrt(stdev);
  return (stdev);
}

float tds[] = {0.00};
String val = null;

void draw() {
  background(0);
  text("Value tds:",160,45);
  text(tds[tds.length-1],250,45);
  text("Standard Deviation:",160,70);
  text(String.format("%.2f", std(tds)),160,90);
}

public void Data(){
  arduino.write('d');
  val = arduino.readStringUntil('\n');
  val = arduino.readStringUntil('\n');
  tds = append(tds, float(val));
}
