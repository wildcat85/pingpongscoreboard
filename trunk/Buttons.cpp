/*

  Buttons.cpp - Buttons class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#include "WProgram.h"
#include "Buttons.h"

const byte DEBOUNCE_DELAY = 20;   // the debounce time; increase if the output flickers
const int HISTORY_LENGTH = 8;     // the history length

Buttons::Buttons() {
  Serial.println("Initialising Buttons class");
}

void Buttons::assignPlayers(byte i1, byte i2, byte i3, byte i4) {
//  Serial.println(__func__);
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
  static int button_states[4] = {LOW,LOW,LOW,LOW};
  static int button_state;
  boolean result = false;
  static long lastDebounceTime = 0;  // the last time the output pin was toggled

//  String sButtons = "";
  for (int iCount = 0; iCount < 4; iCount++) {

    button_state = getState(iCount);

    if (button_state == HIGH && button_states[iCount] == LOW) {
      if (!buttonHeld && !bFiveClaimed) {
        buttonHeld = true;
        buttonHeldOwner = iCount+1;
      }
      buttonHeldTime = millis();
      button_states[iCount] = button_state;
      if ((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
        button_states[iCount] = button_state;
        result = true;
        sHistory = (iCount+1) + sHistory;
      }
    } else if (button_state == LOW && button_states[iCount] == HIGH) {
      lastDebounceTime = millis();
      button_states[iCount] = button_state;
      buttonHeldTime = 0;
      buttonHeld = false;
    }
  sButtons= sButtons + (int)button_state;
  }
  sHistory = sHistory.substring(0,HISTORY_LENGTH); // force history to only hold HISTORY_LENGTH previous button presses
  return result;
}
