/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author Luca Pietro Borsani
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC
{

	uses
	{
		/****** INTERFACES *****/
		interface Boot;
		interface Receive;
		interface AMSend;
		interface SplitControl;
		interface Packet;
		interface PacketAcknowledgements;
		interface Timer<TMilli> as MilliTimer;
		//interface used to perform sensor reading (to get the value from a sensor)
		interface Read<uint16_t>;
	}
}
implementation
{

	uint16_t counter = 0;
	uint16_t ackcounter = 0;
	uint16_t last_digit= 2; //personal code 10537962
	uint16_t x = 3; // lastdigit plus one
	message_t packet;

	bool locked = FALSE;

	void sendReq();
	void sendResp();

	//***************** Send request function ********************//
	void sendReq()
	{
		/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */

		if(locked)
		{
			return;
		}
		else
		{
			//Create packet
			my_msg_t* message = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
			if(message == NULL)
			{
				dbg("radio", "ERROR: THE REQUEST PACKET WAS NOT CREATED\n");
				return;
			}

			message->msg_type = REQ;
			message->msg_counter = counter+1;
			message->value = 0; //Set to 0 since there is nothing to send from the first mote

			//To set the ACK flag
			call PacketAcknowledgements.requestAck(&packet);
			
			//Send the message to mote 2 using UNICAST
			if( call AMSend.send(2, &packet, sizeof(my_msg_t)) == SUCCESS )
			{
				dbg("radio", "SENDING THE REQUEST PACKET NUMBER: %hu \n", counter+1);
				//Lock transmission until it ends
				locked = TRUE;
			}
		}
	}

	//****************** Task send response *****************//
	void sendResp()
	{
		/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
		call Read.read();
	}

	//***************** Boot interface ********************//
	event void Boot.booted()
	{
		dbg("boot", "APPLICATION BOOTED\n");
		
		if(TOS_NODE_ID == 1) //if true, start timer
		{
			call MilliTimer.startPeriodic(1000);
		}

		//Start the radio
		call SplitControl.start();
	}

	//***************** SplitControl interface ********************//
	event void SplitControl.startDone(error_t err)
	{
		if(err == SUCCESS)
		{
			dbg("radio", "RADIO SUCCESSFULLY STARTED\n");
		}
		else
		{
			dbg("radio", "ERROR: RADIO DIDN'T START, YOU HAVE TO TRY AGAIN...\n");
			call SplitControl.start();
		}
	}

	event void SplitControl.stopDone(error_t err)
	{
		//Debug statements even if this event will never fire, just in case
		if(err == SUCCESS)
		{
			dbg("radio", "RADIO STOPPED\n");
		}
		else
		{
			dbg("radio", "ERROR: RADIO FAILED TO STOP, TRY AGAIN TO STOP IT \n");
		}
	}

	//***************** MilliTimer interface ********************//
	event void MilliTimer.fired()
	{
		/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
		sendReq();
	}

	//********************* AMSend interface ****************//
	event void AMSend.sendDone(message_t* buf, error_t err)
	{

	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer according to your id. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
		if(&packet == buf)
		{
			//Remove transmission lock when our packet finished being sent
			locked = FALSE;

			if(TOS_NODE_ID == 1) //Increment the counter just if on mote 1
			{
				counter++;
				
			}

			if(call PacketAcknowledgements.wasAcked(buf))
			{
				switch(TOS_NODE_ID)
				{
					
					case 1:
					{
						dbg("radio_ack", "MOTE#1 RECEIVED THE ACK OF THE REQUEST SENT FROM MOTE#1 TO MOTE#2 \n");
						ackcounter++;
						if(ackcounter>=x)   //stop sending packet because we have receive x request ack
						{
						call MilliTimer.stop();
						}
						break;
					}
					case 2:
					{
						dbg("radio_ack", "MOTE#2 RECEIVED THE ACK OF THE RESPONSE SENT FROM MOTE#2 TO MOTE#1 \n\n");
						break;
					}
				}
			}
			else
			{
				dbg("radio_ack", "ERROR: NOT RECEIVED THE ACK OF LAST PACKET SENT\n\n");
			}
		}
	}

	//***************************** Receive interface *****************//
	event message_t *Receive.receive(message_t* buf, void *payload, uint8_t len)
	{
		/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
		if(len != sizeof(my_msg_t))
		{
			dbg("radio_rec", "ERROR: RECEIVED THE PACKET WITH THE WRONG SIZE\n");
		}
		else
		{
			my_msg_t* message = (my_msg_t*)payload;

			switch(message->msg_type)
			{
				case RESP: //Received by mote 1
				{
					dbg("radio_rec", "MOTE#1 RECEIVED THE RESPONSE WITH COUNTER =%hu AND VALUE =%hu \n", message->msg_counter, message->value);
					break;
				}
				case REQ: //Received by mote 2
				{
					dbg("radio_rec", "MOTE#2 RECEIVED THE REQUEST WITH COUNTER =%hu \n", message->msg_counter);
					counter = message->msg_counter;
					sendResp();
					
					break;
				}
			}
		}

		return buf;
	}

	//************************* Read interface **********************//
	event void Read.readDone(error_t result, uint16_t data)
	{
		/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
		if(result == SUCCESS)
		{
			if(locked)
			{
				return;
			}
			else
			{
				//Create packet
				my_msg_t* message = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
				if(message == NULL)
				{
					dbg("radio", "ERROR: UNABLE ON CREATING REQUEST PACKET\n");
					return;
				}


				message->msg_type = RESP;
				message->msg_counter = counter;
				message->value = data; //Set to 0 since there is nothing to send from the first mote

				//Set the ACK flag
				call PacketAcknowledgements.requestAck(&packet); 
				
				//Send the message to mote 1
				if( call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS )
				{
					dbg("radio", "SENDING THE RESPONSE WITH COUNTER = %hu AND VALUE= %hu \n", counter, data);
					//Lock transmission until it ends
					locked = TRUE;
				}
			}
		}
		else
		{
			dbg("sensor", "ERROR: UNABLE ON GETTING VALUE FROM SENSOR\n");
		}
		
	}
}
