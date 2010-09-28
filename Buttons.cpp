/*

  Buttons.cpp - Buttons class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#include "WProgram.h"
#include "Buttons.h"

Buttons::Buttons() {
  Serial.println("Initialising Buttons class");
}

void Buttons::assignPlayers(byte i1, byte i2, byte i3, byte i4) {
  Serial.println(__func__);
  playerButtons[0] = i1;
  pinMode(playerButtons[0], INPUT);
  playerButtons[1] = i2;
  pinMode(playerButtons[1], INPUT);
  playerButtons[2] = i3;
  pinMode(playerButtons[2], INPUT);
  playerButtons[3] = i4;
  pinMode(playerButtons[3], INPUT);
}

boolean Buttons::getState(byte iPlayer) {
  return digitalRead(playerButtons[iPlayer]);
}
