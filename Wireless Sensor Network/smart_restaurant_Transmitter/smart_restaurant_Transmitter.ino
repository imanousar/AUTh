/*  
 *  @Authors: 
 *  Giannis Manousaridis AEM 8855
 *  Antonis Myrsinias AEM 8873
 * 
 *  @Description: 
 *  This is the transmitter code
 *  for the demo application we 
 *  made during the course of
 *  Wireless Sensor Networks.
 *  
 */


// Libraries for Network Card
#include <SPI.h>  // The RF22 module uses the SPI bus to communicate with the Arduino
#include <RF22.h>
#include <RF22Router.h>

// Network Card initializations
#define SOURCE_ADDRESS 5
#define DESTINATION_ADDRESS 24
RF22Router rf22(SOURCE_ADDRESS);
float throughput = 0;
int flag_measurement = 0;
int max_counter = 5;
int number_of_bytes = 0;
int current_number_of_bytes = 0;

int success = 0;
int fails = 0;
float success_rate = 0.0;

int flag_ALOHA_SUCCESS = 0;
int aloha_delay = 0;

// Useful INFO about the RFM22 shield and network car

//#define RF22_ROUTER_MAX_MESSAGE_LEN 50

// Hardware Restrictions of RFM22 shield for Arduino Uno
//                  Arduino      RFM-22B
//                 GND----------GND-\ (ground in)
//                              SDN-/ (shutdown in)
//                  3V3----------VCC   (3.3V in)
//  interrupt 0 pin D2-----------NIRQ  (interrupt request out)
//           SS pin D10----------NSEL  (chip select in)
//         SCK pin D13----------SCK   (SPI clock in)
//         MOSI pin D11----------SDI   (SPI Data in)
//        MISO pin D12----------SDO   (SPI data out)
//                           /--GPIO0 (GPIO0 out to control transmitter antenna TX_ANT
//                           \--TX_ANT (TX antenna control in)
//                           /--GPIO1 (GPIO1 out to control receiver antenna RX_ANT
//                           \--RX_ANT (RX antenna control in)
//

// Libraries for temperature sensor
#include <OneWire.h>
#include <DallasTemperature.h>

// Libraries for LCD I2C
#include <Wire.h>
#include <LiquidCrystal_I2C.h>

#define BRIGHTNESS 50
#define GAS_THRES 160
#define MIN_BATTERY 0
#define INTERVAL 500
#define TEMPERATURE_LIMIT 27

/* Temperature Sensor DS18B20 */
#define ONE_WIRE_BUS 4  // Data wire is plugged into port 4 on the Arduino
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);  // Pass our oneWire reference to Dallas Temperature.


/* LCD display */
LiquidCrystal_I2C lcd(0x27, 16, 2); // Set the LCD address to 0x27 for a 16 chars and 2 line display

/* hardware initializations*/
const int ldr = A0;              // the ldr sensor for measuring luminosity
const int gasSensor = A1;        // the gas sensor for detecting smoke
const int potentiometerPin = A2; // the potentiometer with which we can browse in the menu
const int candle = 9;           // this led represents the candle of the table
const int dangerLed = 7;        // a red led flashes when smoke is detected
const int fanLed = 6;           // this led represents a fan
const int buzzer = 8;            // the buzzer. It produce sound when smoke is detected
const int buttonONOFF = 5;       // button to turn on or off the menu aka LCD I2C
const int buttonOrder = 3;       // button to select and order a product

/* software initializations*/
int ldrVal = 0; 			// the ldr value
int gasVal = 0;				// the gas value
double temperature = 0;     // the temperature value
bool gasDanger = false;	  	// flag for when gas value surpass the limit
bool dangerLedFlag = false; // flag to blink the danger Led
unsigned long previousMillis = 0; //used to measure time
unsigned long currentMillis = 0;  //used to measure time
int potentiometerVal = 0;        // the value of the potentiometer
volatile byte state = false;    // state indicates if the LCD should be turn on or off
volatile byte orderState = 0;   // order state is used to show when a product is selected and ordered
bool ONOFFFlag = false;			// flag to show if LCD is turned off or on
int productID = 0;				// the ID of the available products
bool productOrderFlag = false;  // the state of the order : not selected : selected : ordered

void setup() {

  Serial.begin(9600);
  while (!Serial);

  // initialization of Network Card components
  if (!rf22.init())
    Serial.println("RF22 init failed");
  if (!rf22.setFrequency(430.0))  // Defaults after init are 434.0MHz, 0.05MHz AFC pull-in, modulation FSK_Rb2_4Fd36
    Serial.println("setFrequency Fail");
  rf22.setTxPower(RF22_TXPOW_20DBM);           //Sets the transmitter power output level   1,2,5,8,11,14,17,20 DBM
  rf22.setModemConfig(RF22::OOK_Rb40Bw335  );  //Sets all the registered required to configure the data modem in the RF22

  // Manually define the routes for this network
  rf22.addRouteTo(DESTINATION_ADDRESS, DESTINATION_ADDRESS);


 // set input and output pins
  sensors.begin(); //for temperature
  pinMode(ldr, INPUT); 
  pinMode(gasSensor, INPUT);
  pinMode(candle, OUTPUT);
  pinMode(dangerLed, OUTPUT);
  pinMode(fanLed, OUTPUT);

  // Initialize button to work with interrupts
  pinMode(buttonOrder, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(buttonOrder), orderButtonPressed, RISING);

  pinMode(buttonONOFF, INPUT);


  lcd.init(); // Initialize LCD Monitor
  lcd.noBacklight(); // Disable LCD's Back Light

  //Initialize everything to low and avoid any initial high conditions by mistake
  digitalWrite(candle, LOW);
  digitalWrite(dangerLed, LOW);
  digitalWrite(fanLed, LOW);
  gasDanger = false;
  dangerLedFlag = false;
  state = false;
  orderState = 0;
  productOrderFlag = false;
  ONOFFFlag = false;
}

void loop() {

  regulateCandle(); 
  checkSmoke();
  checkTemperature();
  checkLCD();
  ONOFFButtonPressed();
  sendData();
}


/* check state of the LCD screen */
void checkLCD()
{
  if (state == true)
  {
    printLCD();
  }
  else {
    lcd.noBacklight(); // Disable LCD's Back Light
    orderState = 0;
    productID = 0;
    productOrderFlag = false;
  }
}


/* read luminosity and turn on or off the candle accordingly*/
void regulateCandle()
{
  ldrVal = analogRead(ldr);  // Read brightness

  if (ldrVal < BRIGHTNESS) {
    digitalWrite(candle, HIGH);
  } else
  {
    digitalWrite(candle, LOW);
  }
}


/* check gas value and hit alarm if the permitted value is exceeded */
void checkSmoke()
{
  gasVal = analogRead(gasSensor);
  if (gasVal > GAS_THRES)
  {
    gasDanger = true;
    hitAlarm();
  } else {
    gasDanger = false;
    noTone(buzzer);
    digitalWrite(dangerLed, LOW);
  }
}


/* make the buzzer play and blink the red led when it's called */
void hitAlarm()
{
  currentMillis = millis();

  if (currentMillis - previousMillis >= INTERVAL) {
    previousMillis = currentMillis;
    dangerLedFlag = !dangerLedFlag;
    if (dangerLedFlag)
    {
      digitalWrite(dangerLed, HIGH);
      tone(buzzer, 1000);
    } else {
      digitalWrite(dangerLed, LOW);
      noTone(buzzer);
    }
  }
}


/* check temperature and turn on the fan led accordingly */
void checkTemperature()
{
  sensors.requestTemperatures();
  temperature = sensors.getTempCByIndex(0);
  //Serial.println(sensors.getTempCByIndex(0));

  if (temperature >= TEMPERATURE_LIMIT)
  {
    digitalWrite(fanLed, HIGH);
  } else {
    digitalWrite(fanLed, LOW);
  }
}


/* Turn's on LCD Monitor - Prints the mean value of the last 2 minute measurements*/
void printLCD() {
  lcd.backlight();
  lcd.clear();  // Clears the LCD screen and positions the cursor in the upper-left corner.
  lcd.setCursor(0, 0);

  potentiometerVal = analogRead(potentiometerPin);

  if (potentiometerVal < 200) {
    lcd.print("1. Amstel 3.5");
    productID = 1;
  } else if (potentiometerVal < 400) {
    lcd.print("2. Heinenken 5.0");
    productID = 2;
  } else if (potentiometerVal < 600) {
    lcd.print("3. Fix 3.00");
    productID = 3;
  } else if (potentiometerVal < 800) {
    lcd.print("4. Alpha 4.0 ");
    productID = 4;
  } else {
    lcd.print("5. Vergina Free");
    productID = 5;
  }

  /* checking order*/
  lcd.setCursor(0, 1);
  if(orderState == 0) productOrderFlag = false;
  if (orderState == 1)
  {
    lcd.print("Product Selected");
    productOrderFlag = false;
  }
  else if (orderState == 2)
  {
    lcd.print("Product Ordered");
    productOrderFlag = true;
  }

  return;
}


/* check if onoff button is pressed */
void ONOFFButtonPressed() {
  
  if (digitalRead(buttonONOFF) == HIGH) {
    ONOFFFlag = true;
  }
  else {
    if (ONOFFFlag) {
      ONOFFFlag = false;
      state = !state;
    }
  }
}

/* interrupt to update the state of the order. If a product is selected or ordered. */
void orderButtonPressed()
{
  orderState += 1;
  if (orderState >= 3) orderState = 0 ;
}

void sendData() {

  int counter = 0;
  unsigned long initial_time = millis();
  unsigned long final_time = 0;
  number_of_bytes = 0;
  fails = 0;
  success = 0;

  char data_read[RF22_ROUTER_MAX_MESSAGE_LEN];
  uint8_t data_send[RF22_ROUTER_MAX_MESSAGE_LEN];
  memset(data_read, '\0', RF22_ROUTER_MAX_MESSAGE_LEN);
  memset(data_send, '\0', RF22_ROUTER_MAX_MESSAGE_LEN);
  int temperature1 = (float) temperature;
  if (gasVal < GAS_THRES && productOrderFlag == false) {
    sprintf(data_read, "gas: %d, temp: %d, light: %d,No Smoke", gasVal, temperature1, ldrVal);
  }
  else if (gasVal > GAS_THRES)
  {
    sprintf(data_read, "gas: %d, temp: %d, light: %d, Smoke!", gasVal, temperature1 , ldrVal);
  }
  else if (gasVal < GAS_THRES && productOrderFlag == true)
  {
    sprintf(data_read, "gas:%d, temp: %d, light:%d, Product:%d", gasVal, temperature1, ldrVal, productID);
  }

  data_read[RF22_ROUTER_MAX_MESSAGE_LEN - 1] = '\0';
  memcpy(data_send, data_read, RF22_ROUTER_MAX_MESSAGE_LEN);
  current_number_of_bytes = sizeof(data_send);

  for (counter = 0; counter < max_counter; counter++)
  {
    flag_ALOHA_SUCCESS = 0;

    while (flag_ALOHA_SUCCESS == 0)
    {

      if (rf22.sendtoWait(data_send, sizeof(data_send), DESTINATION_ADDRESS) != RF22_ROUTER_ERROR_NONE)
      {
        Serial.println("sendtoWait failed");
        fails = fails + 1;
      }
      else
      {
        Serial.println("sendtoWait Successful");
        success = success + 1;
        number_of_bytes = number_of_bytes + current_number_of_bytes;
        flag_ALOHA_SUCCESS = 1;
      }
      if (flag_ALOHA_SUCCESS == 0)
      {
        aloha_delay = random(1000);
        unsigned long start_delay = millis();
        while(millis()-start_delay <= aloha_delay){
          checkAll();  
          }
        Serial.print("Entered Aloha Delay= ");
        Serial.println(aloha_delay);
      }
    }
  }
  Serial.println(data_read);
  success_rate = (float)(success) / (float)(success + fails);
  final_time = millis();
  Serial.print("Success Ratio= ");
  Serial.println(success_rate);
  
  throughput = (float)number_of_bytes * 1000.0 / (final_time - initial_time);
  Serial.println("****************************************************");
  Serial.print("Throughput= ");
  Serial.println(throughput);
}

void checkAll(){
  regulateCandle();
  checkSmoke();
  checkTemperature();
  checkLCD();
  ONOFFButtonPressed();
  }
