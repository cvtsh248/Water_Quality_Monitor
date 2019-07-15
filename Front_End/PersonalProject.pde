//Front End

/*
TO DO:
1. Implement storing of data locally [DONE]
2. Add turbidity functionality (also need to work on back end) [DONE]
3. Convert TDS to PPM (maybe, not compulsory as of now given the nature of the project) [NOT DONE]
4. Work on fixing tds data receiving. Try to remove the need of spamming the button. [NOT DONE]
4. Improve GUI? [NOT DONE]
*/

import controlP5.*;

import processing.serial.*;

import java.io.BufferedWriter;

import java.io.FileWriter;

Serial arduino;

ControlP5 cp5;

float std(float data[]) { //function to calculate standard deviation
  float avg = 0;
  float stdev = 0;
  float nans = 0; //count how many nan
  for (int i = 0; i < data.length; i++) { //calculating average
    if (Float.isNaN(data[i])==false){
      avg += data[i];
    }
    if (Float.isNaN(data[i])==true){
      nans+=1;
    }
  }
  avg /= (data.length-nans);
  for (int i = 0; i < (data.length-nans); i++) {
    if (Float.isNaN(data[i])==false){
      stdev += sq(data[i]-avg);
    }
    
  }
  stdev /= (data.length-nans); //calculating standard deviation
  stdev = sqrt(stdev);
  return (stdev);
}



String buff[] = {""}; //reseting file
float Buff[] = {}; //for reseting lists
float tds[] = {}; //tds values
float turbidity[] = {}; //turbidty values
float deviation[] = {}; //standard deviation list (tds)
float deviation_t[] = {}; //standard deviation list (tubidity)
String val = null; //buffer for tds
String val_t = null; //buffer for turbidity
boolean c = false; //calibration mode
boolean range = true; //in acceptable range of standard deviation or not (tds)
boolean range_t = true; //same as range but for turbidity 
float s = 0; //variable containing standard deviation for tds
float s_t = 0; //standard deviation for turbidity
float sOfs = 0; //standard deviation of standard deviation list for tds
float sOfs_t = 0; //standard deviation of standard deviation for turbidity
String [] lines; //open file for tds
String [] lines_t; //open file for turbidity

void setup() {
  size(400,400);
  
  arduino = new Serial (this, "/dev/ttyACM0", 9600); //initialising arduino serial connection
  arduino.bufferUntil( '\n' );
  
  lines = loadStrings("log_tds.txt"); //load save file for tds
  lines_t = loadStrings("log_turb.txt"); //load save file for turbidity
  
  //gui elements
  cp5 = new ControlP5(this);
  cp5.addButton("TDS").setValue(0).setPosition(20,20).setSize(90,40);
  cp5.addButton("Save").setValue(0).setPosition(20,80).setSize(90,40);
  cp5.addButton("Reset").setValue(0).setPosition(20,140).setSize(90,40);
  
  for (int i = 0; i < lines.length; i++){
    deviation = append(deviation,float(lines[i]));
  }
  
  for (int i = 0; i < lines_t.length; i++){
    deviation_t = append(deviation,float(lines_t[i]));
  }
  
}


void draw() { //begin application
  //tds
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
  text(String.format("%.5f", s),290,70);
  text("Change in Standard Deviation:",160,95);
  text(String.format("%.5f", sOfs),340,95);

  text("Abnormal:",160,120); //check for abnormality (i.e. outside acceptable difference based on standard deviation)
  if (range == true){ //uses the boolean function within_range()... Look at bool within_range() for more info. 
    text("False",230,120);
  }
  if (range == false){
    text("True",230,120);
  }
  
  //turbidty
  text("Value of turbidity:",160,150);
  if (turbidity.length > 0 && c == true){
    text(turbidity[turbidity.length-1],280,150); //display tds value, in calibration mode: taking value from tds buffer array
  }
  if (c == false && val_t != null){
    text(float(val_t),280,150); //display tds value when not in calibration mode
  }
  if (val_t != null){
    s_t = std(turbidity); //calculate standard deviation of the tds array
  }
  text("Standard Deviation:",160,175); //lines 82&83 are responsible for displaying standard deviation
  text(String.format("%.5f", s_t),290,175);
  text("Change in Standard Deviation:",160,200);
  text(String.format("%.5f", sOfs_t),340,200);

  text("Abnormal:",160,225); //check for abnormality (i.e. outside acceptable difference based on standard deviation)
  if (range_t == true){ //uses the boolean function within_range()... Look at bool within_range() for more info. 
    text("False",230,225);
  }
  if (range_t == false){
    text("True",230,225);
  }
  
}

//buttons galore
public void TDS() { //TDS button function
  arduino.write('d'); //send the char 'd' to the arduino
  val = arduino.readStringUntil('\n'); //receive the response (spam this button at least 5 times to get fresh data)
  arduino.write('d'); //send the char 'd' to the arduino
  val = arduino.readStringUntil('\n'); //receive the response (spam this button at least 5 times to get fresh data)
  
  val_t = val.split(",")[1];
  val = val.split(",")[0];

  //delay(2000);
  //arduino.write('e'); //send the char 'e' to the arduino
  //delay(2000);
  //val_t = arduino.readStringUntil('\n'); 
}

public void Save() { //Save the data to a list (eventually will append to a file)
  //tds
  if (Float.isNaN(float(val)) == false){
      tds = append(tds, float(val));
  }
  if(Float.isNaN(s) == false){
    deviation = append(deviation, s); //standard deviation of standard deviation
    lines = append(lines, str(s));
    saveStrings("log_tds.txt", lines);
  }

  if (deviation.length > 0 && Float.isNaN(s) == false){
    sOfs = std(deviation);

    if(Float.isNaN(sOfs) == true){
      sOfs = 0;
    }

  }
  if (sOfs > 0.2){ //if standard deviation of standard deviation is greater than 0.08, there is a problem
    range = false;
  }
  if (sOfs < 0.2){
    range = true;
  }
  //turbidty
  if (Float.isNaN(float(val_t)) == false){
      turbidity = append(turbidity, float(val_t));
  }
  if(Float.isNaN(s_t) == false){
    deviation_t = append(deviation_t, s_t); //standard deviation of standard deviation
    lines_t = append(lines_t, str(s_t));
    saveStrings("log_turb.txt", lines_t);
  }

  if (deviation_t.length > 0 && Float.isNaN(s_t) == false){
    sOfs_t = std(deviation_t);
    if(Float.isNaN(sOfs_t) == true){
      sOfs_t = 0;
    }

  }
  if (sOfs_t > 0.2){ //if standard deviation of standard deviation is greater than 0.08, there is a problem
    range_t = false;
  }
  if (sOfs < 0.2){
    range_t = true;
  }
}

public void Reset() { //Reset after abnormality
    saveStrings("log_tds.txt", buff);
    saveStrings("log_tds.txt", buff);
    deviation = Buff;
    tds = Buff;
    turbidity = Buff;
  
}
