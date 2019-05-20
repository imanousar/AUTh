/*  
 *  @Authors: 
 *  Giannis Manousaridis AEM 8855
 *  Antonis Myrsinias AEM 8873
 * 
 *  @Description: 
 *  This is the receiver code for the 
 *  smart restauran application.
 *  It just receives the data from the different
 *  transmitters.
 *  
 */

// Include libraries
#include <SPI.h>
#include <RF22.h>
#include <RF22Router.h>

//define source nodes
#define SOURCE_ADDRESS1 5
#define SOURCE_ADDRESS2 6

/*
#define SOURCE_ADDRESS3 3
#define SOURCE_ADDRESS4 4
#define SOURCE_ADDRESS5 6
#define SOURCE_ADDRESS6 8
#define SOURCE_ADDRESS7 7
*/
#define DESTINATION_ADDRESS 24

RF22Router rf22(DESTINATION_ADDRESS);

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
  rf22.addRouteTo(SOURCE_ADDRESS1, SOURCE_ADDRESS1);
  rf22.addRouteTo(SOURCE_ADDRESS2, SOURCE_ADDRESS2);
  
  /*rf22.addRouteTo(SOURCE_ADDRESS2, SOURCE_ADDRESS2);
  rf22.addRouteTo(SOURCE_ADDRESS3, SOURCE_ADDRESS3);
  rf22.addRouteTo(SOURCE_ADDRESS4, SOURCE_ADDRESS4);
  rf22.addRouteTo(SOURCE_ADDRESS5, SOURCE_ADDRESS5);
  rf22.addRouteTo(SOURCE_ADDRESS6, SOURCE_ADDRESS6);
  rf22.addRouteTo(SOURCE_ADDRESS7, SOURCE_ADDRESS7);
  */
}

// continuously receive messages
void loop(){
  int received_value = 0;
  // Should be a message for us now
  uint8_t buf[RF22_ROUTER_MAX_MESSAGE_LEN];
  char incoming[RF22_ROUTER_MAX_MESSAGE_LEN];
  memset(buf, '\0', RF22_ROUTER_MAX_MESSAGE_LEN);
  memset(incoming, '\0', RF22_ROUTER_MAX_MESSAGE_LEN);
  uint8_t len = sizeof(buf);
  uint8_t from;
  if (rf22.recvfromAck(buf, &len, &from))
  {
    buf[RF22_ROUTER_MAX_MESSAGE_LEN - 1] = '\0';
    memcpy(incoming, buf, RF22_ROUTER_MAX_MESSAGE_LEN);
    Serial.print("Table: ");
    Serial.println(from, DEC);
    received_value=atoi((char*)incoming);

    Serial.println(incoming);
  }  

}
