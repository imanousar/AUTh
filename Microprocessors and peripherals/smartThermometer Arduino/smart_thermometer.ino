// Include the libraries we need
#include <OneWire.h>
#include <DallasTemperature.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <NewPing.h>
#include <avr/sleep.h>
#include <avr/power.h>

/* LCD display */
LiquidCrystal_I2C lcd(0x27, 16, 2); // Set the LCD address to 0x27 for a 16 chars and 2 line display

/* Temperature Sensor DS18B20 */
#define ONE_WIRE_BUS 4  // Data wire is plugged into port 4 on the Arduino
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);  // Pass our oneWire reference to Dallas Temperature.

/* Ultrasonic Sensor HC-SR04*/
#define TRIGGER_PIN 7 // Ultrasonic sensor's pin used to initialize measurement by sending US wave
#define ECHO_PIN 8 // Ultrasonic sensor's pin used to receive the US wave
#define MAX_DISTANCE 200 // Maximum recognisable distance
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE); // constructor for sonar


/*Definitions*/
#define MAX_TEMP 26 // in Celsius -> RED AND BLUE LED ON
#define MIN_TEMP 20 // in Celsius -> WHITE LED ON
#define ACTIVATION_DISTANCE 10 // Distance (10cm) less than which LCD show's temperature mean value and current measurement 

// Define Pins for LEDs
#define RED_LED 11  
#define BLUE_LED 12
#define WHITE_LED 13

/* Variable Initializations */
int index = 0; // Index for measurements taken every 5 seconds
int distance = 0; // Variable used to store the distance measurements from UltraSonic sensor
int powerOffLCDcounter = 0;
int timer1init=0xE488; // Hex Value to adjust Timer's 1 overflow time
double sum = 0; // Variable used to find the sum of all temperature measurements taken the past 2 minutes
double mean = 0; // Mean value of temperature measurements taken the past 2 minutes
double tempArr[24] = {0}; // initialize temperature-measurements array with zeros

/*-------------------------------------------------------------------------------*/

void setup() {
  Serial.begin(9600); // Set Baud Rate: 9600
  while (!Serial);

  // Set Pins for LEDs as output
  pinMode(RED_LED, OUTPUT);
  pinMode(BLUE_LED, OUTPUT);
  pinMode(WHITE_LED, OUTPUT);

  lcd.init(); // Initialize LCD Monitor
  lcd.noBacklight(); // Disable LCD's Back Light
  sensors.begin(); // Initialize Temperature Sensor
  
  // Initialize Timer 1 - 7031 cycles * 64 usec/cycle = 450 msec
  TCNT1=timer1init;	 		// Initialize Timer 1 from value 65535-7031=58504 - Overflow every 450 msec
  TIMSK1=1<<TOIE1;	 	// Enable Timer 1 Overflow Interrupt 
  TCCR1A = 0x00; 	// Normal timer operation
  TCCR1B=0x05;			// Clock Prescaler (1024): 16000000/1024 = 64 usec/cycle
  sei();				// Enable Global Interrupts
	
}

/*-------------------------------------------------------------------------------*/

void loop() {

  if (index < 24) { // Time < 2 minutes

    tempArr[index] = getTemp(); // Get temperature measurement

    /* Check if temperature is higher or lower than normal */
    if (tempArr[index] > MAX_TEMP) {
      digitalWrite(RED_LED, HIGH);
      digitalWrite(BLUE_LED, LOW);
      digitalWrite(WHITE_LED, HIGH);
    } else if (tempArr[index] > MIN_TEMP) {
      digitalWrite(RED_LED, LOW);
      digitalWrite(BLUE_LED, LOW);
      digitalWrite(WHITE_LED, LOW);
    } else {
      digitalWrite(RED_LED, LOW);
      digitalWrite(BLUE_LED, HIGH);
      digitalWrite(WHITE_LED, LOW);
    }


    index++; // Increase index for the next measurement
    powerOffLCDcounter++; // used to make LCD black again after displaying value becaused distance was < 10 cm


    /* Sleep Arduino - Save energy and get distance measurements every 500ms*/

    for (int k = 0; k < 10; k++) {
      enterSleep(); // Sleep for approximately 450 ms

      // The rest of the code inside the loop lasts approximately 50 ms 
      // 500 ms on every loop in total
      
      
      // Code resumes here on wake.

      distance = sonar.ping_cm(); // Get distance measurement
      if (distance < ACTIVATION_DISTANCE && distance != 0)
      {
        powerOffLCDcounter = 0;
        showTemperatureNow(tempArr, index - 1, mean); // LCD show's temperature mean value and current measurement
      }

    }// 500 ms * 10 times = 5 seconds

    if (powerOffLCDcounter == 2) switchOffLCD();

  } else if (index == 24) { // Print Mean Value of Temperatures + Reset Time = 2 minutes

    /* Calculate Mean Value of Temperatures */
    sum = 0;
    for (int i = 0; i < 24; i++) {
      sum += tempArr[i];
    }
    mean = sum / 24.0;


    printLCD_every2min(mean); // Print mean value on LCD
    index = 0; // Reset on every 2 minutes
    powerOffLCDcounter = 0;
  }
}


/********************************** METHODS *****************************************/

/* Puts Arduino to Sleep */
void enterSleep(void)
{
  set_sleep_mode(SLEEP_MODE_IDLE);
  
  sleep_enable();


  // Disable all of the unused peripherals. This will reduce power
  // consumption further and, more importantly, some of these peripherals 
  // may generate interrupts that will wake our Arduino from sleep!
  power_adc_disable();
  power_spi_disable();
  power_timer0_disable();
  power_timer2_disable();
  power_twi_disable();  

  /* Now enter sleep mode. */
  sleep_mode();
  
  /* The program will continue from here after the timer timeout*/
  sleep_disable(); /* First thing to do is disable sleep. */
  
  /* Re-enable the peripherals. */
  power_all_enable();
}

/* Returns Temperature Measurement */
double getTemp() {
  sensors.requestTemperatures();
  return sensors.getTempCByIndex(0);
}

/* Turn's off LCD Monitor */
void switchOffLCD() {
  lcd.clear();
  lcd.noBacklight();
  return;
}


/* Turn's on LCD Monitor - Prints the mean value of the last 2 minute measurements*/
void printLCD_every2min(double mean) {
  lcd.backlight();
  lcd.clear();  // Clears the LCD screen and positions the cursor in the upper-left corner.
  lcd.setCursor(0, 0); // set cursor to write in the first row from the begining
  lcd.print("Celsius: ");
  lcd.print(mean);
  return;
}

/* Prints the temperature and the mean value of the last 2 minute measurements on LCD */
void showTemperatureNow(double tempArr[], int index, double mean) {
  lcd.backlight();
  lcd.clear();  // Clears the LCD screen and positions the cursor in the upper-left corner.
  lcd.setCursor(0, 0); // set cursor to write in the first row from the begining
  lcd.print("Last temp: ");
  lcd.print(tempArr[index]);
  lcd.setCursor(0, 1); // set cursor to write in the second row from the begining
  lcd.print("Mean temp: ");
  lcd.print(mean);
  return;
}

/* Interrupt Service Routine */
ISR(TIMER1_OVF_vect)
{
    TCNT1=timer1init; // Reset Timer 1
}
