configuration hc3AppC{
}
implementation
{ //prima i componenti
	components MainC, hc3C, LedsC; 
	components new TimerMilliC();
	components SerialPrintfC; 
	components SerialStartC;
	hc3C -> MainC.Boot;
	hc3C.Timer -> TimerMilliC;
	hc3C.Leds -> LedsC;
  
}
