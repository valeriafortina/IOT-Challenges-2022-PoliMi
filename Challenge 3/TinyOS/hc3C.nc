#include "Timer.h"
#include "printf.h"	

long int code=10537962;


//components
module hc3C @safe(){
	uses interface Timer<TMilli> as Timer;
	uses interface Leds; //da accendere e spegnere
	uses interface Boot; //interfaccia sempre presente per il system
}

//implementation
implementation{
	
//timer declaration
  event void Boot.booted() {
    call Timer.startPeriodic(60000);	
  }
  
  bool LED0=0;
  bool LED1=0;
  bool LED2=0;
  
  event void Timer.fired() {
 	
  	int remaind=0;
  	
  	if(code>0){
  		
  		remaind=code%3;
  		code=code/3;
  		
  		if(remaind==0){
  			 call Leds.led0Toggle();
  			 if(LED0==0){
  			 	LED0=1;
  			 }
  			 else{
  			 	LED0=0;
  			 }
  			 printf("Led,0,Status,%d,\n",LED0);
  		}
  		else if(remaind==1){
  		 	call Leds.led1Toggle();
  		 	if(LED1==0){
  			 	LED1=1;
  			 }
  			 else{
  			 	LED1=0;
  			 }
  		 	printf("Led,1,Status,%d,\n",LED1);
  		}
  		else if(remaind==2){
  			 call Leds.led2Toggle();
  			 if(LED2==0){
  			 	LED2=1;
  			 }
  			 else{
  			 	LED2=0;
  			 }
  			 printf("Led,2,Status,%d,\n",LED2);
  		}
  		printfflush();
  	}
  	if(code==0){
  		call Timer.stop();
  		
  	}
  	
  }
  
  
		
}
