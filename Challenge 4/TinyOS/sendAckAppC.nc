/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"

configuration sendAckAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendAckC as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components ActiveMessageC;
  components new TimerMilliC();
  components new FakeSensorC();

/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.Packet -> AMSenderC;
  App.PacketAcknowledgements -> AMSenderC;
  App.SplitControl -> ActiveMessageC;
  App.MilliTimer -> TimerMilliC;
  App.Read -> FakeSensorC;
}