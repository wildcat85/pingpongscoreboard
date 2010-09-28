/*

  Buttons.h - Buttons class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#ifndef Buttons_h
#define Buttons_h

#include "WProgram.h"

class Buttons {
  public:
  Buttons();
  void assignPlayers(byte i1, byte i2, byte i3, byte i4);
  boolean getState(byte iPlayer);
  
  private:
    byte playerButtons[4];         // the number of the pushbutton pin

};

#endif
