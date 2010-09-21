#include "WProgram.h"
#include "Display.h"
#include <Wire.h>

const int Display::CMD_totalArgs[] = {
//  0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - A - B - C - D - E - F 
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,    // 0 - 0x00 -> 0x0F
    0,  2,  1,  2,  1,  0,  0,  0,  0,  1,  0,  0,  0,  0,  0,  0,    // 1 - 0x10 -> 0x1F
    3,  3,  3,  0,  0,  0,  2,  4,  4,  0,  3,  3,  0,  0,  0,  0,    // 2 - 0x00 -> 0x2F
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,    // 3 - 0x00 -> 0x3F
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,    // 4 - 0x00 -> 0x4F
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,    // 5 - 0x50 -> 0x5F
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,    // 6 - 0x60 -> 0x6F
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0     // 7 - 0x70 -> 0x7F
//  0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 - A - B - C - D - E - F 
};

const int Display::iPanel[] = {0x10, 0x11, 0x12, 0x13, 0x14};
boolean Display::changed[] = {0,0,0,0,0};

Display::Display() {
  RainbowCMD[0] = 'r';
}

void Display::swap_buffers(boolean bAll) {
  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    if (changed[iCount-16] || bAll) {
      sendCMD(iCount, CMD_SWAP_BUF);
      changed[iCount-16] = false;
    }
  }
}

void Display::clear_buffers(boolean bAll) {
  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    if (changed[iCount-16] || bAll) {
      sendCMD(iCount, CMD_CLEAR_PAPER);
      changed[iCount-16] = false;
    }
  }
}

void Display::draw_pixel(int iAddr, int iX, int iY) {
  Serial.println(__func__);
  this->changed[iAddr-16] = true;
  sendCMD(iAddr, CMD_DRAW_PIXEL, toByte(iX), toByte(iY));
}

void Display::draw_square(int iAddr, int iX1, int iY1, int iX2, int iY2) {
  Serial.println(__func__);
  this->changed[iAddr-16] = true;
  sendCMD(iAddr, CMD_DRAW_SQUARE, toByte(iX1), toByte(iY1), toByte(iX2), toByte(iY2));
}

void Display::set_ink(int iR, int iG, int iB) {
  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    sendCMD(iCount, CMD_SET_INK, iR, iG, iB);
  }
}

void Display::set_paper(int iR, int iG, int iB) {
  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    sendCMD(iCount, CMD_SET_PAPER, iR, iG, iB);
  }
}

void Display::character(int iAddr, int iX, int iY, char cChar, boolean bClearBuffer) {
  char ascii[100];
//  Serial.println(__func__);
//  sprintf(ascii,"char: %c = 0x%x - %i - %i", cChar, iAddr, iX, iY);
//  Serial.println(ascii);
  this->changed[iAddr-16] = true;
  if (bClearBuffer) sendCMD(iAddr, CMD_CLEAR_PAPER);
  sendCMD(iAddr, CMD_PRINT_CHAR, toByte(iX), toByte(iY), cChar);
}

void Display::show_word(String sWord, int iPosition, boolean bForce) {
  Serial.println(__func__);
  char ascii[100];

  int iDisplay;
  int iDot;
  int iDotDeduct = 0;
  int iLetterWidth = 7;
  char* foo = "Iil"; 
 
  this->clear_buffers(true);
  
  if (!bForce) {
    iPosition = (40/2) - ((sWord.length()*iLetterWidth)/2)-1;// + (sWord.length()-1);
  }
  
  for (int iCount = 0; iCount < sWord.length(); iCount++) {

    if (strchr(foo, sWord[iCount]) != NULL) 
    { 
      iPosition--;
      iPosition--;
      iDotDeduct = 1;
    } else {
      iDotDeduct = 0;
    }

    iDisplay = floor((iPosition+(iCount*(iLetterWidth+1)))/8);
    if (((iPosition+(iCount*(iLetterWidth+1)))%8) == 0) {
      iDisplay--;
    }
    iDot = (iPosition+(iCount*(iLetterWidth+1)));
    iDot -= (8*iDisplay)+1;


//    sprintf(ascii,"iDot %i = %i - %i [%i] (%i)", iDot, iPosition+(iCount*(iLetterWidth+1)), (8*iDisplay)-3, iDisplay, iDotDeduct);
//    Serial.println(ascii);
    
    if (iDisplay > -1 && iDisplay < 5 && iDot < (iLetterWidth+1) && iDot > -7) {
//      Serial.print("1: ");
      this->character(this->iPanel[iDisplay], iDot, 0, sWord[iCount], false);
    }
  
    if (iDisplay > -2 && iDisplay < 4 && iDot > 1) {
//      Serial.print("2: ");
      this->character(this->iPanel[iDisplay+1], iDot-8, 0, sWord[iCount], false);
    }
  iPosition -= iDotDeduct;
  
  }
  this->swap_buffers(true); 
}


unsigned char Display::toByte(int i) {
  return map(i, -128, 127, 0, 255);
}



void Display::sendCMD(byte address, byte CMD, ... ) {
  int i;
  unsigned char v;
  byte t;

  va_list args;                     // Create a variable argument list
  va_start(args, CMD);              // Initialize the list using the pointer of the variable next to CMD;
  
  RainbowCMD[1] = CMD;              // Stores the command name
  t = CMD_totalArgs[CMD]+2;
  for (i=2; i < t; i++) {
    v = va_arg(args, int);          // Retrieve the argument from the va_list    
    RainbowCMD[i] = v;              // Store the argument
  }
  
  sendWireCommand(address, t);      // Transmit the command via I2C
}

void Display::sendWireCommand(int Add, byte len) {
  unsigned char OK=0;
  unsigned char i,temp;
  
  while(!OK)
  {                          
    switch (State)
    { 	

    case 0:                          
      Wire.beginTransmission(Add);
      for (i=0; i<len ;i++) {
        Wire.send(RainbowCMD[i]);
      }
      
      Wire.endTransmission();    
      delay(5);   
      State=2;                      
      break;

    case 1:
      Wire.requestFrom(Add,1);   
      if (Wire.available()>0) 
        temp=Wire.receive();    
      else {
        temp=0xFF;
        timeout++;
      }

      if ((temp==1)||(temp==2)) State=2;
      else if (temp==0) State=0;

      if (timeout>5000) {
        timeout=0;
        State=0;
      }

      delay(5);
      break;

    case 2:
      OK=1;
      State=0;
      break;

    default:
      State=0;
      break;
    }
  }
}

