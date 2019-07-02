void setup() {
  Serial.begin(9600);
  pinMode(2, OUTPUT);

}

float ohms = 0;
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
        volt = analogRead(A3);
        volt = volt*(5.0/1023.0);
        avg += volt;
        }
        digitalWrite(2, LOW);
        avg = avg/100;
        offset = avg; //y = mx+c, c is the offset, gradient should remain the same.
        Serial.println(avg); //print output
        avg = 0;
    }
    
    
    if (incoming == 'd'){
      //reading data
      for (int i = 0; i <= 100; i++){
        digitalWrite(2, HIGH);
        volt = analogRead(A3);
        //volt = volt*(5.0/1023.0);
        avg += volt; //an average is taken for the sake of accuracy, and denoising
      }
      digitalWrite(2, LOW);
      avg = avg/100;
      if (micromhos < 0){
        micromhos = 0;
      }

      //ohms = avg/(((5-avg)/10000)-(avg/3300));
      //Serial.print(";");
      Serial.print(avg);
      avg = 0;
    }
  }
}
