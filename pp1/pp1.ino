void setup() {
  Serial.begin(9600);
  pinMode(2, OUTPUT);

}

float weight = 0;
float volt = 0; 
float ppm = 0;
float avg = 0;
char incoming; //see when to calibrate
float offset = 3.43;
float conversion_factor = 0.67; //if unknown, it is often assumed to be this by authorities
float gradient = 0.057;
float micromhos = 0;
float fine_tune = 5.0;

void loop() {
  weight = 0;
  avg = 0;
  ppm = 0;
  micromhos = 0;
  if (Serial.available()>0){
    
    incoming = Serial.read();
    Serial.println(incoming);
    
    if (incoming == 'c'){ //Calibration
      Serial.println("CALIBRATION MODE, DIP PROBE INTO DISTILLED WATER, YOU HAVE 2 SECONDS TO DO SO");
      delay(2000);
      for (int i = 0; i <= 100; i++){
        digitalWrite(2, HIGH);
        volt = analogRead(A5);
        volt = volt*(5.0/1023.0);
        avg += volt;
        }
        digitalWrite(2, LOW);
        avg = avg/100;
        offset = avg; //y = mx+c, c is the offset, gradient should remain the same.
        Serial.println(avg); //print output
        avg = 0;
    }
    
    if (incoming == 'r'){ //Raw
      //reading data
      for (int i = 0; i <= 100; i++){
        digitalWrite(2, HIGH);
        volt = analogRead(A5);
        volt = volt*(5.0/1023.0);
        avg += volt; //an average is taken for the sake of accuracy, and denoising
      }
      digitalWrite(2, LOW);
      avg = avg/100; 
      Serial.println(ppm);
      avg = 0;
    }
    
    if (incoming == 'd'){
      //reading data
      for (int i = 0; i <= 100; i++){
        digitalWrite(2, HIGH);
        volt = analogRead(A5);
        volt = volt*(5.0/1023.0);
        avg += volt; //an average is taken for the sake of accuracy, and denoising
      }
      digitalWrite(2, LOW);
      avg = avg/100;
      micromhos = 0;
      micromhos = (avg/gradient)-(offset/gradient)-fine_tune;
      weight = micromhos;
      micromhos = micromhos/(100+micromhos);
      micromhos = micromhos*1000000;
      micromhos = 1.78*micromhos-169;//conversion
      if (micromhos < 0){
        micromhos = 0;
      }
      
      //micromhos = 1.78*(((avg/gradient)-(offset/gradient))/(100+((avg/gradient)-(offset/gradient)))*1000000)-169; //convert voltage to micromhos/microsiemens (literally the same thing)
      ppm = micromhos*conversion_factor; 
      Serial.println(avg);
      //Serial.println(ppm);
      //Serial.println(weight);
      ppm = 0;
      avg = 0;
    }
  }
}
