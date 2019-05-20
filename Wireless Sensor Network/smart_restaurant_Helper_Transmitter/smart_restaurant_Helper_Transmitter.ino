/*  
 *  @Authors: 
 *  Giannis Manousaridis AEM 8855
 *  Antonis Myrsinias AEM 8873
 * 
 *  @Description: 
 *  This is the transmitter-helper code for the 
 *  smart restauran application.
 *  It just sends random data to the central node
 *  There was a lack of HW resources and that's why
 *  why we used the helper.
 *  
 */

// include libraries 
#include <SPI.h>
#include <RF22.h>
#include <RF22Router.h>

// define no of this node and the no of the central node
#define SOURCE_ADDRESS 6
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

const int sensorPin = A0;

void setup() {
  Serial.begin(9600);
  if (!rf22.init())
    Serial.println("RF22 init failed");
  // Defaults after init are 434.0MHz, 0.05MHz AFC pull-in, modulation FSK_Rb2_4Fd36
  if (!rf22.setFrequency(430.0))
    Serial.println("setFrequency Fail");
  rf22.setTxPower(RF22_TXPOW_20DBM);
  //1,2,5,8,11,14,17,20 DBM
  rf22.setModemConfig(RF22::OOK_Rb40Bw335  );
  //modulation

  // Manually define the routes for this network
  rf22.addRouteTo(DESTINATION_ADDRESS, DESTINATION_ADDRESS);
  randomSeed(analogRead(sensorPin));

}

// send random message inside the void loop
void loop() {
  int counter = 0;
  unsigned long initial_time = millis();
  unsigned long final_time = 0;
  number_of_bytes = 0;
  fails = 0;
  success = 0;


  int sensorVal = analogRead(sensorPin);
  Serial.print("sensor Value: ");
  Serial.println(sensorVal);
  char data_read[RF22_ROUTER_MAX_MESSAGE_LEN];
  uint8_t data_send[RF22_ROUTER_MAX_MESSAGE_LEN];
  memset(data_read, '\0', RF22_ROUTER_MAX_MESSAGE_LEN);
  memset(data_send, '\0', RF22_ROUTER_MAX_MESSAGE_LEN);
  sprintf(data_read, "gas: %d, temp: %d, light: %d, Smoke!", sensorVal, sensorVal , sensorVal);
  data_read[RF22_ROUTER_MAX_MESSAGE_LEN - 1] = '\0';
  memcpy(data_send, data_read, RF22_ROUTER_MAX_MESSAGE_LEN);
  current_number_of_bytes = sizeof(data_send);


  for (counter = 0; counter < max_counter; counter++)
  {
    flag_ALOHA_SUCCESS=0;

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
        flag_ALOHA_SUCCESS=1;
      }
      if(flag_ALOHA_SUCCESS==0)
      {
        aloha_delay=random(1000);
        delay(aloha_delay);
        Serial.print("Entered Aloha Delay= ");
        Serial.println(aloha_delay);
      }
    }
  }
  success_rate = (float)(success) / (float)(success + fails);
  final_time = millis();
  Serial.print("Success Ratio= ");
  Serial.println(success_rate);


  throughput = (float)number_of_bytes * 1000.0 / (final_time - initial_time);
  Serial.println("****************************************************");
  Serial.print("Throughput= ");
  Serial.println(throughput);

}
