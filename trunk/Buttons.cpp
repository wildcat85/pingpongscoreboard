/*

  Buttons.cpp - Buttons class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#include "WProgram.h"
#include "Buttons.h"

const byte DEBOUNCE_DELAY = 20;   // the debounce time; increase if the output flickers
const int HISTORY_LENGTH = 8;     // the history length

Buttons::Buttons() {
  bFiveClaimed = false;
  buttonHeld = false;
}

void Buttons::assignPlayers(byte i1, byte i2, byte i3, byte i4) {
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

/* ---------------------------------- */
// void get_button_states()
// get current button states
/* ---------------------------------- */
boolean Buttons::get_button_states(String &sButtons) {
  static byte button_states[4] = {LOW,LOW,LOW,LOW};
  static byte button_state;
  static int buttons_down = 0;
  static long lastDebounceTime = 0;  // the last time the output pin was toggled
  boolean result = false;
  
  sButtons = "";

  for (int iCount = 0; iCount < 4; iCount++) {
    sButtons = sButtons + (int)button_states[iCount];
    button_state = getState(iCount);

    if (button_state == HIGH && button_states[iCount] == LOW) {
      if (!buttonHeld) {
        buttonHeld = iCount+1;
        buttonHeldTime = millis();
      }
      buttons_down++;
      if (buttons_down > 1 && MultiButtons != true) { MultiButtons = true; }
      button_states[iCount] = button_state;
      if ((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
        button_states[iCount] = button_state;
        sHistory = (iCount+1) + sHistory;
      }
    } else if (button_state == LOW && button_states[iCount] == HIGH) {
      buttons_down--;
      lastDebounceTime = millis();
      button_states[iCount] = button_state;
      if (buttons_down == 0) {
        buttonHeld = 0;
        buttonHeldTime = 0;
      }
      result = true;
    }
  }
  sHistory = sHistory.substring(0,HISTORY_LENGTH); // force history to only hold HISTORY_LENGTH previous button presses
  if (buttons_down == 0 && MultiButtons == true) { MultiButtons = false; result = false; }
  if (wait_for_zero) { wait_for_zero = (buttons_down > 0) ? true : false; result = false; }
  return result;
}
