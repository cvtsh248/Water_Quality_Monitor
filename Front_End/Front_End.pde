//Front End

/*

This is the front end.
This works in unison with the back end.
Only edit lines that ask you to,
if you don't want to break anything.

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

boolean sigma(float data[], float val){ //evaluate standard deviation
  float stdev = std(data);
  float avg = 0;
  float nans = 0; //count how many nan
  float diff = 0;
  float sigmas = 0;
  for (int i = 0; i < data.length; i++) { //calculating average
    if (Float.isNaN(data[i])==false){
      avg += data[i];
    }
    if (Float.isNaN(data[i])==true){
      nans+=1;
    }
  }
  avg /= (data.length-nans);
  diff = val-avg;
  
  sigmas = diff/stdev;
  println(sigmas);
  if (abs(sigmas) > 3){
    return (true);
  }else{
    return (false);
  }
}


String buff[] = {""}; //reseting file
float Buff[] = {}; //for reseting lists
float tds[] = {}; //tds values
float turbidity[] = {}; //turbidty values
String val = null; //buffer for tds
String val_t = null; //buffer for turbidity
boolean range = false; //in acceptable range of standard deviation or not (tds)
boolean range_t = false; //same as range but for turbidity 
float s = 0; //variable containing standard deviation for tds
float s_t = 0; //standard deviation for turbidity
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
  cp5.addButton("Data").setValue(0).setPosition(20,40).setSize(90,40);
  cp5.addButton("Save").setValue(0).setPosition(20,100).setSize(90,40);
  cp5.addButton("Reset").setValue(0).setPosition(20,160).setSize(90,40);
  
  for (int i = 0; i < lines.length; i++){
    tds = append(tds,float(lines[i]));
  }
  
  for (int i = 0; i < lines_t.length; i++){
    turbidity = append(turbidity,float(lines_t[i]));
  }
  
}


void draw() { //begin application
  //tds
  background(0); //refresh background
  text("Value of TDS:",160,45);
  if (tds.length > 0 && val != null){
    text(float(val),250,45); //display tds value, in calibration mode: taking value from tds buffer array
    //text(float(val)*m+c,250,45); <If you have calibration data (linear), uncomment this line and comment out line 119, replace m with gradient and c with constant and remove this text>
    //text(a*pow(float(val),exp)+c,250,45); <If you have calibration data (exponential), uncomment this line and comment out line 119, replace exp with the exponent and c with constant and remove this text>
    //text(a*pow(float(val),2)+b*(float(val))+c,250,45); <If you have calibration data (quadratic), uncomment this line and comment out line 119, replace a with the coefficient of x^2, b with the coefficient of x and c with constant and remove this text>
    
  }
  if (val != null){
    s = std(tds); //calculate standard deviation of the tds array
  }
  text("Standard Deviation:",160,70); //lines 82&83 are responsible for displaying standard deviation
  text(String.format("%.5f", s),290,70);

  text("Abnormal:",160,95); //check for abnormality (i.e. outside acceptable difference based on standard deviation)
  if (range == true){ //uses the boolean function within_range()... Look at bool within_range() for more info. 
    text("true",230,95);
  }
  if (range == false){
    text("false",230,95);
  }
  
  //turbidty
  text("Value of turbidity:",160,150);
  if (turbidity.length > 0 && val_t != null){
    text(float(val_t),280,150); //display tds value, in calibration mode: taking value from tds buffer array
    //text(float(val_t)*m+c,250,45); <If you have calibration data (linear), uncomment this line and comment out line 142, replace m with gradient and c with constant and remove this text>
    //text(a*pow(float(val_t),exp)+c,250,45); <If you have calibration data (exponential), uncomment this line and comment out line 142, replace exp with the exponent and c with constant and remove this text>
    //text(a*pow(float(val_t),2)+b*(float(val_t))+c,250,45); <If you have calibration data (quadratic), uncomment this line and comment out line 142, replace a with the coefficient of x^2, b with the coefficient of x and c with constant and remove this text>
  }
  if (val_t != null){
    s_t = std(turbidity); //calculate standard deviation of the tds array
  }
  text("Standard Deviation:",160,175); //lines 82&83 are responsible for displaying standard deviation
  text(String.format("%.5f", s_t),290,175);

  text("Abnormal:",160,200); //check for abnormality (i.e. outside acceptable difference based on standard deviation)
  if (range_t == true){ //uses the boolean function within_range()... Look at bool within_range() for more info. 
    text("true",230,200);
  }
  if (range_t == false){
    text("false",230,200);
  }
  
  
}

//buttons galore
public void Data() { //receive data button function
  
  arduino.write('d'); //send the char 'd' to the arduino
  delay(15);
  val = arduino.readStringUntil('\n'); //receive the response (spam this button at least 5 times to get fresh data)
  
  val_t = val.split(",")[1];
  val = val.split(",")[0];
  
  arduino.clear();//clear buffer
  
}

public void Save() { //Save the data to a list (eventually will append to a file)
  //tds
  range = sigma(tds,float(val)); //calculating abnormality
  
  if (Float.isNaN(float(val)) == false){
      tds = append(tds, float(val));
      //tds = append(tds, (float(val)*m+c)); <If you have calibration data (linear), uncomment this line and comment out line 183, replace m with gradient and c with constant and remove this text>
      //tds = append(tds, (a*pow(float(val),exp)+c)); <If you have calibration data (exponential), uncomment this line and comment out line 183, replace exp with the exponent and c with constant and remove this text>
      //tds = append(tds, (a*pow(float(val),2)+b*(float(val))+c,250,45); <If you have calibration data (quadratic), uncomment this line and comment out line 183, replace a with the coefficient of x^2, b with the coefficient of x and c with constant and remove this text>
      lines = append(lines, str(float(val)));
      //lines = append(lines, str((float(val)*m+c))); <If you have calibration data (linear), uncomment this line and comment out line 187, replace m with gradient and c with constant and remove this text>
      //lines = append(lines, str((a*pow(float(val),exp)+c))); <If you have calibration data (exponential), uncomment this line and comment out line 187, replace exp with the exponent and c with constant and remove this text>
      //lines = append(lines, str((a*pow(float(val),2)+b*(float(val)))); <If you have calibration data (quadratic), uncomment this line and comment out line 187, replace a with the coefficient of x^2, b with the coefficient of x and c with constant and remove this text>
      saveStrings("log_tds.txt", lines);
  }

  
  //turbidty
  range_t = sigma(turbidity,float(val_t));
  if (Float.isNaN(float(val_t)) == false){
      turbidity = append(turbidity, float(val_t));
      //turbidity = append(turbidity, (float(val_t)*m+c)); <If you have calibration data (linear), uncomment this line and comment out line 198, replace m with gradient and c with constant and remove this text>
      //turbidity = append(turbidity, (a*pow(float(val_t),exp)+c)); <If you have calibration data (exponential), uncomment this line and comment out line 198, replace exp with the exponent and c with constant and remove this text>
      //turbidity = append(turbidity, (a*pow(float(val_t),2)+b*(float(val))+c,250,45); <If you have calibration data (quadratic), uncomment this line and comment out line 198, replace a with the coefficient of x^2, b with the coefficient of x and c with constant and remove this text>
      lines_t = append(lines_t, str(float(val_t)));
      //lines_t = append(lines_t, str((float(val_t)*m+c))); <If you have calibration data (linear), uncomment this line and comment out line 202, replace m with gradient and c with constant and remove this text>
      //lines_t = append(lines_t, str((a*pow(float(val_t),exp)+c))); <If you have calibration data (exponential), uncomment this line and comment out line 202, replace exp with the exponent and c with constant and remove this text>
      //lines_t = append(lines_t, str((a*pow(float(val_t),2)+b*(float(val_t)))); <If you have calibration data (quadratic), uncomment this line and comment out line 202, replace a with the coefficient of x^2, b with the coefficient of x and c with constant and remove this text>
      saveStrings("log_turb.txt", lines_t);
  }
  
}

public void Reset() { //Reset after abnormality
    saveStrings("log_tds.txt", buff);
    saveStrings("log_turb.txt", buff);
    tds = Buff;
    turbidity = Buff;
  
}
