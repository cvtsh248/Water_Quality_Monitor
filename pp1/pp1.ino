void setup() {
  Serial.begin(9600);

}

float volt = 0; 
float ppm = 0;
float avg = 0;
int incoming = 0; //see when to calibrate
float offset = 3.43;
float conversion_factor = 0.67; //if unknown, it is often assumed to be this by authorities
float gradient = 0.057;
float micromhos = 0;

void loop() {
  //check for calibration command
  if (Serial.available()>0){
    incoming = Serial.read();
    if ((incoming,DEC) == 1){
      Serial.println("CALIBRATION MODE, DIP PROBE INTO DISTILLED WATER, YOU HAVE 2 SECONDS TO DO SO");
      delay(2000);
      for (int i = 0; i <= 100; i++){
        volt = analogRead(A0);
        volt = volt*(5.0/1023.0);
        avg += volt;
        }
        avg = avg/100;
        offset = avg; //y = mx+c, c is the offset, gradient should remain the same.
        Serial.println(avg); //print output
    }
  }
  //reading data
  for (int i = 0; i <= 100; i++){
    volt = analogRead(A0);
    volt = volt*(5.0/1023.0);
    avg += volt; //an average is taken for the sake of accuracy, and denoising
  }
  avg = avg/100;
  
  /*
  micromhos = (avg/gradient)-(offset/gradient);
  micromhos = micromhos/(100+micromhos);
  micromhos = micromhos*1000000;
  micromhos = 1.78*micromhos-169;
  */
  
  micromhos = 1.78*(((avg/gradient)-(offset/gradient))/(100+((avg/gradient)-(offset/gradient)))*1000000)-169; //convert voltage to micromhos/micrsiemens (literally the same thing)
  ppm = micromhos*conversion_factor //convert to PPM
  Serial.println(micromhos);
}
