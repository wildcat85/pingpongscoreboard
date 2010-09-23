#include <stdio.h>
//#include <MsTimer2.h>
#include <Wire.h>
#include "Display.h"
#include "Game.h"

// Initialise constants - These babies won't change
const String VERSION = "0.1a";
const int P1_BUTTON = 36;         // the number of the pushbutton pin
const int P2_BUTTON = 48;         // the number of the pushbutton pin
const int P3_BUTTON = 44;         // the number of the pushbutton pin
const int P4_BUTTON = 40;         // the number of the pushbutton pin
const int HISTORY_LENGTH = 8;     // the history length
const long DEBOUNCE_DELAY = 20;   // the debounce time; increase if the output flickers
const int POINTS_BEFORE_CHANGE = 5;

// Initialise variables - These babies will change
String sHistory = "";
String sButtons = "0000";
char cChar[0];
Display myDisplay = Display();
Game myGame = Game();

/* ---------------------------------- */
// void setup()
// setup all the good stuff
/* ---------------------------------- */
void setup() {
  Wire.begin();                                    // join I2C bus (address optional for master)
  Serial.begin(57600);                             // config serial as 57600 for some sweet serial monitor action
  Serial.println("PingPong v" + (String)VERSION);
  Serial.println("--------------");
  pinMode(P1_BUTTON, INPUT);                       // set P1_BUTTON as an INPUT
  pinMode(P2_BUTTON, INPUT);                       // set P2_BUTTON as an INPUT
  pinMode(P3_BUTTON, INPUT);                       // set P3_BUTTON as an INPUT
  pinMode(P4_BUTTON, INPUT);                       // set P4_BUTTON as an INPUT
  pinMode(13, OUTPUT);
//  MsTimer2::set(500, flash); // 500ms period
//  MsTimer2::start();
  myDisplay.set_ink(15,0,0);
  myDisplay.set_paper(0,0,0);
  myDisplay.show_word("READY");
}

/* ---------------------------------- */
// void loop()
// loop all the good stuff
/* ---------------------------------- */
void loop() {
  if (get_button_states()) {
    process_button_presses();                                  // process button presses
    update_score_board();
  }
}

void draw_arrow(int _iDirection) {
  char Arrow[2][8] = {{0x00, 0x04, 0x02, 0xFF, 0xFF, 0x02, 0x04, 0x00},
                      {0x00, 0x20, 0x40, 0xFF, 0xFF, 0x40, 0x20, 0x00}};

  myDisplay.set_ink(0,15,0);
  myDisplay.sendCMD(0x12, CMD_CLEAR_PAPER);
  for (int row=7; row>=0; row--) {      
      myDisplay.draw_row_mask(0x12, row, 0, Arrow[_iDirection][row]);
  }
  myDisplay.set_ink(15,0,0);
}

/* ---------------------------------- */
// void update_score_board(int* score)
// formats score for score board and displays it
/* ---------------------------------- */
void update_score_board() {
  double dFract, dInt;
  String sNum;
  static int iArrow = -1;
  int iPoints, iScoreLeft, iScoreRight, iDirection;

  iScoreLeft = myGame.get_score(TEAM_LEFT);
  iScoreRight = myGame.get_score(TEAM_RIGHT);
  iDirection = myGame.get_direction();
  iPoints = myGame.get_points();

  if (iScoreLeft < 10) sNum = "0" + (String)iScoreLeft; else sNum = (String)iScoreLeft;
  if (myGame.score_changed(TEAM_LEFT)) {
    myDisplay.character(0x10, 0, 0, sNum[0], true);
    myDisplay.character(0x11, 0, 0, sNum[1], true);
  }
  
  if (iScoreRight < 10) sNum = "0" + (String)iScoreRight; else sNum = (String)iScoreRight;
  if (myGame.score_changed(TEAM_RIGHT)) {
    myDisplay.character(0x13, 1, 0, sNum[0], true);
    myDisplay.character(0x14, 1, 0, sNum[1], true);
  }
  
  if (floor(iPoints/POINTS_BEFORE_CHANGE) != iArrow) {
    myGame.set_direction(!iDirection);
    draw_arrow(!iDirection);
    iArrow = floor(iPoints/POINTS_BEFORE_CHANGE);
  }

  myDisplay.swap_buffers();
  
  Serial.println((String)myGame.get_score(TEAM_LEFT) + " - " + (String)myGame.get_score(TEAM_RIGHT) + " [" + (String)sHistory + "]");
}


/* ---------------------------------- */
// void process_scores()
// calculate scores and update score board
/* ---------------------------------- */
void process_button_presses() {
  if (myGame.GameOn) {
    // Players 1 and 2
    if (sButtons == "1000" || sButtons == "0100") {
      if (myGame.get_score(TEAM_LEFT) < 21) {
        myGame.add_points(TEAM_LEFT, 1);
      }
    }
    
    if (sButtons == "1100") {
      if (myGame.get_score(TEAM_LEFT) > 0) {
        myGame.take_points(TEAM_LEFT, 1);
      }
    }

    // Players 3 and 4
    if (sButtons == "0010" || sButtons == "0001") {
      if (myGame.get_score(TEAM_RIGHT) < 21) {
        myGame.add_points(TEAM_RIGHT, 1);
      }
    }
    
    if (sButtons == "0011") {
      if (myGame.get_score(TEAM_RIGHT) > 0) {
        myGame.take_points(TEAM_RIGHT, 1);
      }
    }
    
    // Functions
    if (sButtons == "1111") {
      myGame.reset();
    }
  } else {
    if (sButtons == "1000" || sButtons == "0100") { myGame.start(0); }
    if (sButtons == "0010" || sButtons == "0001") { myGame.start(1); }
  }
}

/* ---------------------------------- */
// void get_button_states()
// get current button states
/* ---------------------------------- */
boolean get_button_states() {
  static int button_states[] = {LOW,LOW,LOW,LOW};
  static int button_state;
  boolean result = false;
  static long lastDebounceTime = 0;  // the last time the output pin was toggled

  sButtons = "";
  for (int iCount = 0; iCount < 4; iCount++) {
    switch (iCount) {
      case 0:
        button_state = digitalRead(P1_BUTTON);
        break;
      case 1:
        button_state = digitalRead(P2_BUTTON);
        break;
      case 2:
        button_state = digitalRead(P3_BUTTON);
        break;
      case 3:
        button_state = digitalRead(P4_BUTTON);
        break;
    }

    if (button_state == HIGH && button_states[iCount] == LOW) {
      button_states[iCount] = button_state;
      if ((millis() - lastDebounceTime) > DEBOUNCE_DELAY) {
        button_states[iCount] = button_state;
        result = true;
        sHistory = (iCount+1) + sHistory;
      }
    } else if (button_state == LOW && button_states[iCount] == HIGH) {
      lastDebounceTime = millis();
      button_states[iCount] = button_state;
    }
  sButtons= sButtons + (int)button_state;
  }
  sHistory = sHistory.substring(0,HISTORY_LENGTH); // force history to only hold HISTORY_LENGTH previous button presses
  return result;
}
