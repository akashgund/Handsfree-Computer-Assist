#include<Mouse.h>

#define   BAUDRATE           57600

#define   LED                13

#define   Theshold_Eyeblink  170

#define   EEG_AVG            70

//accelerometer 
const int xout = A0;
const int yout = A1;
const int zout = A2;
const int threshold=10; //mapped reading at which mouse gets triggered
float MouseSensitivity=0.5;

int px,py,pz;
int x,y,z; //volt reading on x,y,z axes
int xMap,yMap,zMap; //axes voltage mapping for mouse triggering
float xMove,yMove,wheelMove;
int st;
int mouseState;
int inPin = 8;   // EEG O/P connected to digital pin 8
int val = 0;     // variable to store the read value
int clickstate=0;


int invertY=1;
//end acc

long payloadDataS[5] = {0};

long payloadDataB[32] = {0};

byte checksum=0,generatedchecksum=0;

unsigned int Raw_data,Poorquality,Plength,Eye_Enable=0,On_Flag=0,Off_Flag=1 ;

unsigned int j,n=0;

long Temp,Avg_Raw,Temp_Avg;

 

 void setup()

 {
   Serial.begin(9600);
   Mouse.begin();
   mouseState=true;
   pinMode(inPin, INPUT);      // sets the digital pin 8 as input
   st=millis();

   
   Serial1.begin(BAUDRATE);           
   pinMode(LED, OUTPUT);
   pinMode(8,OUTPUT);//change it

 }

 

 byte ReadOneByte()           // One Byte Read Function

 {

   int ByteRead;
    //Serial.println("12test");
   while(Serial1.available()){
    //Serial.println("test");
     ByteRead = Serial1.read();
   }
  //Serial.println(ByteRead);
   return ByteRead;

 }

 boolean approxeq(int a,int b)
{
  int approximation=threshold;
  if(a>=b-approximation && a<=b+approximation)
  {
    Serial.print("yeee");
    return true;
  }
  else
    return false;
}

void mouseToggle()
{
  if(mouseState==true)
    mouseState=false;
  else
    mouseState=true;
}

float setMoveSensitivityY(int m){ //takes mouse move b/w -128 to 128
  m=abs(m);
  if(m<3){
    return 0.3;
  }else if(m<5){
    return 0.5;
  }else if(m>=5 && m<10){
    return 0.6;
  }else if(m>=10){
    return 1;
  }
}

float setMoveSensitivityX(int m){
  m=abs(m);
  if(m<3){
    return 0.5;
  }else if(m<5){
    return 0.5;
  }else if(m>=5 && m<10){
    return 0.6;
  }else if(m>=10){
    return 1;
  }
}

 void loop()                     // Main Function

 {

   if(Serial.available()>0){
    String message="";
    while(Serial.available()>0){
      //Serial.println("yo"); 
      message+=char(Serial.read());
      delay(50);
    }
    MouseSensitivity=message.toFloat();
    //Serial.println(message);
  }
   //DO NOT REMOVE DELAYS IT MAY CAUSE THE COMPUTER TO HANG!
  // put your main code here, to run repeatedly:
  analogReference(EXTERNAL);
  //mouseState=true;
  
  x=analogRead(xout); //
  xMap=map(x,0,1023,-512,512); // map from range 0 - 1023 to -512 to 512
  //if(xMap>threshold || xMap<-(threshold))
  //{
    xMove=map(xMap,-512,512,-128,128); // map from -512 - 512 to range supported by mouseMove()
    xMove*=(setMoveSensitivityX(xMove)*MouseSensitivity);
  //}
  //else
    //xMove=0;
  
  y=analogRead(yout);
  yMap=map(y,0,1023,-512,512);
//  if(yMap>threshold || yMap<-(threshold))
//  {
    yMove=map(yMap,-512,512,-128,128); //invert y
    yMove*=(invertY*setMoveSensitivityY(yMove)*MouseSensitivity);
//  }
//  else
//    yMove=0;
  
//  z=analogRead(zout);
//  zMap=map(x,0,1023,-512,512);
//  if(zMap>5 || zMap<-5)
//  {
//    wheelMove=map(xMap,-512,512,-100,100);
//    if(wheelMove>30 || wheelMove<-30) // used to turn mouse on or off (the jerking)
//    {
//      Serial.println("ending!!!!");
//      Serial.println(wheelMove>20);
//      Serial.println(wheelMove<-20);
//      mouseToggle();
//      wheelMove=0;
//      delay(500);
//    }
//  }

if(mouseState==true)
  {
    Mouse.begin();
    Mouse.move((int)xMove,(int)yMove,0);
  }
//  Serial.print("mouse state");
//  Serial.print(mouseState);
//  Serial.print("\tx=");
//  Serial.print((int)xMove);
//  Serial.print("\ty=");
//  Serial.print(yMove);
//  Serial.print("\tz=");
//  Serial.println(wheelMove);
  
  //delay(5);
  
  
  //Serial.println("test");

   if(ReadOneByte() == 170)        // AA 1 st Sync data

   {

     if(ReadOneByte() == 170)      // AA 2 st Sync data

     {

       Plength = ReadOneByte();

       if(Plength == 4)   // Small Packet

       {
        //Serial.println("sp");
         Small_Packet ();

       }

       else if(Plength == 32)   // Big Packet

       {
          //Serial.println("BP");
         Big_Packet ();

       }

     }

   }        

 }

 

 void Small_Packet ()

 {

   generatedchecksum = 0;

   for(int i = 0; i < Plength; i++)

   { 

     payloadDataS[i]     = ReadOneByte();      //Read payload into memory

     generatedchecksum  += payloadDataS[i] ;

   }

   generatedchecksum = 255 - generatedchecksum;

   checksum  = ReadOneByte();

   if(checksum == generatedchecksum)        // Varify Checksum

   { 

     if (j<512)

     {

       Raw_data  = ((payloadDataS[2] <<8)| payloadDataS[3]);

       if(Raw_data&0xF000)

       {

         Raw_data = (((~Raw_data)&0xFFF)+1);

       }

       else

       {

         Raw_data = (Raw_data&0xFFF);

       }

       Temp += Raw_data;

       j++;

     }

     else

     {

       Onesec_Rawval_Fun ();

     }

   }

 }

 

 void Big_Packet()

 {

   generatedchecksum = 0;
   //Serial.println("test");
   for(int i = 0; i < Plength; i++)

   { 

     payloadDataB[i]     = ReadOneByte();      //Read payload into memory

     generatedchecksum  += payloadDataB[i] ;

   }

   generatedchecksum = 255 - generatedchecksum;

   checksum  = ReadOneByte();

   if(checksum == generatedchecksum)        // Varify Checksum

   {

     Poorquality = payloadDataB[1];
     Serial.println(Poorquality);

     if (Poorquality==0 )

     {

       Eye_Enable = 1;

     }

     else

     {

       Eye_Enable = 0;

     }

   }

 }

 

 void Onesec_Rawval_Fun ()

 {

   Avg_Raw = Temp/512;

   if (On_Flag==0 && Off_Flag==1)

   {

     if (n<3)

     {

       Temp_Avg += Avg_Raw;

       n++;

     }

     else

     {

       Temp_Avg = Temp_Avg/3;

       if (Temp_Avg<EEG_AVG)

       {

         On_Flag=1;Off_Flag=0;

       }

       n=0;Temp_Avg=0;

     } 

   }             

   Eye_Blink ();

   j=0;

   Temp=0;

 }

 

 void Eye_Blink ()

 {

   if (Eye_Enable)         

   {

     if (On_Flag==1 && Off_Flag==0)

     {
       Serial.println(Avg_Raw);
       if ((Avg_Raw>Theshold_Eyeblink) && (Avg_Raw<550))

       {

         digitalWrite(LED,HIGH);
         //Serial.println("Initiating click");
         Mouse.click(MOUSE_LEFT);
         //digitalWrite(8,HIGH);

       }

       else

       {

         if (Avg_Raw>350)

         {

           On_Flag==0;Off_Flag==1;

         }

         digitalWrite(LED,LOW);

       }

     }

     else

     {

       digitalWrite(LED,LOW);

     }

   }       

   else

   {

     digitalWrite(LED,LOW);

   }

 }
