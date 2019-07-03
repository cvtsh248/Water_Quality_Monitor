// Backend

/*
 * TO DO:
 * 1. Add in turbidity functionality
 * 2. Calibrate sensor
 */

void setup() {
  Serial.begin(9600);
  pinMode(2, OUTPUT);
  pinMode(3, OUTPUT);

}

//for tds
float volt = 0; 
float avg = 0;
char incoming; //see when to send what

//for turbidity
int val_light = 0;
int val_no_light = 0;
int val = 0;
int avgval = 0;

void loop() {
  weight = 0;
  avg = 0;
  ppm = 0;
  micromhos = 0;
  if (Serial.available()>0){
    
    incoming = Serial.read();
    Serial.println(incoming);
    /*
     *  To prevent electrolysis,
     *  the program does not apply a constant voltage to the water, 
     *  but only when you ask the program to send you a reading.
     */
    if (incoming == 'd'){ //tds
      //reading data
      for (int i = 0; i <= 100; i++){
        digitalWrite(2, HIGH);
        volt = analogRead(A3);
        avg += volt; //an average is taken for the sake of accuracy, and denoising
      }
      digitalWrite(2, LOW);
      avg = avg/100;
      Serial.print(avg); //average printed to serial
      avg = 0;
    }
    /*
     * A turbidity sensor measures the cloudiness of water. 
     * This can be achieved using a LDR and a LED. 
     * The less light that comes through from the LED to the LDR, the cloudier the water is. 
     * To cancel out background light, I am turning the LED on and off every 50 milliseconds. 
     * The reading of the LDR during the time that the LED is off 
     * can be subtracted from the reading of the LDR during the 
     * time that the LED is on, to get a final turbidity reading, 
     * free of background light. 
     * In theory this eliminates the need of something 
     * like a dark box for the system to be housed in. 
     */
    if (incoming == 'e'){ //turbidity
      //reading data
      for (int n = 0; n <= 20; n++){
        digitalWrite(3, LOW); 
        val_no_light = analogRead(A1); //reading with no light
        delay(50); //50 ms delay
        digitalWrite(3, HIGH);
        val_light = analogRead(A1); //reading with light on
        delay(50); //50 ms delay
        val = val_light - val_no_light; //subtracting the two
        avgval += val
      }
      avgval /= 20; //calculating average for the sake of accuracy/denoising
      Serial.println(avgval); //print to serial
    }
  }
}
