# IOT-Challenges-2022-PoliMi
These challanges have been developed as part of the "Internet of Things" course at Politecnico di Milano.
- Final Evaluation: 4/4.

## Challenges
### Challenge 1 - Sniffing
- The objective of this challenge was to analyze traffic using Wireshark and answer a set of questions on the COAP and MQTT protocols.
### Challenge 2 - Node-RED
- The objective of this challenge was to generate 100 messages from a provided CSV file and then send them to the ThingSpeak channel using MQTT through a Node-RED simulation.
### Challenge 3 - TinyOS & Node-RED
- The objective of this challenge was to simulate a TinyOS device capable of performing the division by three of a specific number (person code). Based on the remainder of this division, specific LEDs were turned on or off.In particular, the remainder equal to zero toggles Led0 and so on.
### Challenge 4 - TinyOS & TOSSIM
- The objective of this challenge was to simulate a TinyOS system made up of two nodes communicating with each other. Node1 performs requests to Node2, where requests are identified by a counter. For each request, Node2 takes a value from a fake sensor and sends it back to Node1 inserting the counter in the response. This way the response can be associated with a request. Nodes require acks to make sure the receiver received the message. The simulation was done using TOSSIM.
