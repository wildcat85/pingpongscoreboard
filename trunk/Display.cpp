/*

  Display.cpp - Display class for custom Rainbowduino setup
  Daniel Mackie <eikcam@gmail.com>

*/

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
  Serial.println("Initialising Display class");
  RainbowCMD[0] = 'r';
}

void Display::swap_buffers(boolean bAll) {
//  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    if (changed[iCount-16] || bAll) {
      sendCMD(iCount, CMD_SWAP_BUF);
      changed[iCount-16] = false;
    }
  }
}

void Display::clear_buffers(boolean bAll) {
//  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    if (changed[iCount-16] || bAll) {
      sendCMD(iCount, CMD_CLEAR_PAPER);
      changed[iCount-16] = false;
    }
  }
}

void Display::draw_pixel(int iAddr, int iX, int iY) {
//  Serial.println(__func__);
  this->changed[iAddr-16] = true;
  sendCMD(iAddr, CMD_DRAW_PIXEL, toByte(iX), toByte(iY));
}

void Display::draw_square(int iAddr, int iX1, int iY1, int iX2, int iY2) {
//  Serial.println(__func__);
  this->changed[iAddr-16] = true;
  sendCMD(iAddr, CMD_DRAW_SQUARE, toByte(iX1), toByte(iY1), toByte(iX2), toByte(iY2));
}

void Display::set_ink(int iR, int iG, int iB) {
//  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    sendCMD(iCount, CMD_SET_INK, iR, iG, iB);
  }
}

void Display::set_paper(int iR, int iG, int iB) {
//  Serial.println(__func__);
  for (int iCount=0x10; iCount <= 0x14; iCount++) {
    sendCMD(iCount, CMD_SET_PAPER, iR, iG, iB);
  }
}

void Display::draw_row_mask(int iAddr, int iRow, int iXoffset, byte bBitmask) {
//  Serial.println(__func__);
  sendCMD(iAddr, CMD_DRAW_ROW_MASK, toByte(iRow), toByte(iXoffset), bBitmask);
  this->changed[iAddr-16] = true;
}

void Display::character(int iAddr, int iX, int iY, char cChar, boolean bClearBuffer) {
//  Serial.println(__func__);
  char ascii[100];
  this->changed[iAddr-16] = true;
  if (bClearBuffer) sendCMD(iAddr, CMD_CLEAR_PAPER);
  sendCMD(iAddr, CMD_PRINT_CHAR, toByte(iX), toByte(iY), cChar);
}

void Display::screen_saver(String sScrollText) {
//  Serial.println(__func__);
  static long previousMillis = 0;        // will store last time LED was updated
  static int iScroll = 60;
  long interval = 50;           // interval at which to blink (milliseconds)
  unsigned long currentMillis = millis();
  int iTextLen = sScrollText.length()*8*-1;

  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;
    show_word(sScrollText, iScroll, true);
    iScroll--;
    if (iScroll < iTextLen) {
      iScroll = 60;
      set_ink(random(0,15),random(0,15),random(0,15));
    }
  }
}

void Display::getCharGaps(int aGaps[], char cChar) {
//  Serial.println(__func__);
  aGaps[0] = 0; aGaps[1] = 0;
  
    if (strchr("!ITil ", cChar) != NULL) {       // 2 front 2 back
      aGaps[0] = 2;
      aGaps[1] = 1;
    } else if (strchr("Y1", cChar) != NULL) {  // 1 front 1 back
      aGaps[0] = 1;
      aGaps[1] = 0;
    } else if (strchr("jtyz", cChar) != NULL) {  // 0 front 2 back
      aGaps[0] = 0;
      aGaps[1] = 1;
    } else if (strchr(":", cChar) != NULL) {  // 2 front 4 back
      aGaps[0] = 2;
      aGaps[1] = 3;
    }
//  Serial.println(aGaps[0]);
}

void Display::show_word(String sWord, int iPosition, boolean bForce) {
//  Serial.println(__func__);
  char ascii[100];

  int iDisplay;
  int iDot;
  int iDotDeduct = 0;
  int iLetterWidth = 7;
  int iWordAdjust = 0;
  int aGaps[2];
 
  this->clear_buffers(true);
  
  if (!bForce) {
    for (int iCount = 0; iCount < sWord.length(); iCount++) {
      getCharGaps(aGaps, sWord[iCount]);
      iWordAdjust += aGaps[0];
      iWordAdjust += aGaps[1];
      iWordAdjust = iWordAdjust;
    }
    iPosition = (40/2) - ((sWord.length()*iLetterWidth/2))-1;
    iPosition += floor(iWordAdjust/2);
  }
  
  for (int iCount = 0; iCount < sWord.length(); iCount++) {
    iDotDeduct = 0;
    
    getCharGaps(aGaps, sWord[iCount]);
    
    iPosition -= aGaps[0];
    iDotDeduct = aGaps[1];

    iDisplay = floor((iPosition+(iCount*(iLetterWidth+1)))/8);
    if (((iPosition+(iCount*(iLetterWidth+1)))%8) == 0) {
      iDisplay--;
    }
    iDot = (iPosition+(iCount*(iLetterWidth+1)));
    iDot -= (8*iDisplay)+1;


    if (iDisplay > -1 && iDisplay < 5 && iDot < (iLetterWidth+1) && iDot > -7) {
      this->character(this->iPanel[iDisplay], iDot, 0, sWord[iCount], false);
    }
  
    if (iDisplay > -2 && iDisplay < 4 && iDot > 1) {
      this->character(this->iPanel[iDisplay+1], iDot-8, 0, sWord[iCount], false);
    }
  iPosition -= iDotDeduct;
  
  }
  this->swap_buffers(true); 
}


unsigned char Display::toByte(int i) {
  return map(i, -128, 127, 0, 255);
}

char *replace_str(char *str, char *orig, char *rep)
{
  static char buffer[4096];
  char *p;

  if(!(p = strstr(str, orig)))  // Is 'orig' even in 'str'?
    return str;

  strncpy(buffer, str, p-str); // Copy characters from 'str' start to 'orig' st$
  buffer[p-str] = '\0';

  sprintf(buffer+(p-str), "%s%s", rep, p+strlen(orig));

  return buffer;
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

