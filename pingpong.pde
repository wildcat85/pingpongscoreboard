/*

  pingpong.pde - Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>
  
  Test board pins and colours
  48 = Red
  44 = Green
  40 = White
  36 = Black
  GND = Yellow
  5v  = White

*/

#include <stdio.h>
#include <Wire.h>
#include "Buttons.h"
#include "Display.h"
#include "Game.h"

// Initialise constants - These babies won't change
const String VERSION = "0.1a";
const int POINTS_BEFORE_CHANGE = 5;

// Initialise variables - These babies will change
String sButtons;
boolean bFiveClaimedDirection = false;
String sScreenSaver[] = {"PING PONG"};
Buttons myButtons;
Display myDisplay;
Game myGame;

/* ---------------------------------- */
// void setup()
// setup all the good stuff
/* ---------------------------------- */
void setup() {
  Wire.begin();                                    // join I2C bus (address optional for master)
  Serial.begin(57600);                             // config serial as 57600 for some sweet serial monitor action
  Serial.println("PingPong v" + (String)VERSION);
  Serial.println("--------------");
  myButtons.assignPlayers(36, 48, 44, 40);
  myDisplay.set_ink(15,0,0);
  myDisplay.set_paper(0,0,0);
}

/* ---------------------------------- */
// void loop()
// loop all the good stuff
/* ---------------------------------- */
void loop() {
  
  if (!myGame.GameOn) {myDisplay.screen_saver(sScreenSaver, SCROLL_R2L); }

  if (myButtons.buttonHeld) {
    if (millis() - myButtons.buttonHeldTime > 1000) {
//      Serial.print("5 points claimed by player ");
//      Serial.println(myButtons.buttonHeldOwner);
//      myDisplay.show_word("FIVE?");
      myButtons.buttonHeld = false;
//      myButtons.bFiveClaimed = true;
//      bFiveClaimedDirection = true;
    }
  }
  if (myButtons.get_button_states(sButtons)) {
    process_button_presses(sButtons);                                  // process button presses
    update_score_board();
    if (myGame.get_winner() != -1) {
      Serial.print("WINNER IS - ");
      Serial.println(myGame.get_winner());
    }
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
  String sNum;
  static int iArrow = -1;
  int iPoints, iScore, iDirection;

  iDirection = myGame.get_direction();
  iPoints = myGame.get_points();

  if (myGame.score_changed(TEAM_LEFT, true)) {
    iScore = myGame.get_score(TEAM_LEFT);
    if (myGame.get_winner() == TEAM_LEFT) { myDisplay.set_ink(15,15,15); }
    if (iScore < 10) sNum = "0" + (String)iScore; else sNum = (String)iScore;
    myDisplay.character(0x10, 0, 0, sNum[0], true);
    myDisplay.character(0x11, 0, 0, sNum[1], true);
    if (myGame.get_winner() == TEAM_LEFT) { myDisplay.set_ink(15,0,0); }
  }
  
  if (myGame.score_changed(TEAM_RIGHT, true)) {
    iScore = myGame.get_score(TEAM_RIGHT);
    if (myGame.get_winner() == TEAM_RIGHT) { myDisplay.set_ink(15,15,15); }
    if (iScore < 10) sNum = "0" + (String)iScore; else sNum = (String)iScore;
    myDisplay.character(0x13, 1, 0, sNum[0], true);
    myDisplay.character(0x14, 1, 0, sNum[1], true);
    if (myGame.get_winner() == TEAM_RIGHT) { myDisplay.set_ink(15,0,0); }
  }
  
  if (bFiveClaimedDirection) {
    iArrow = !iArrow;
    bFiveClaimedDirection = false;
  }
  
  if (floor(iPoints/POINTS_BEFORE_CHANGE) != iArrow) {
    myGame.set_direction(!iDirection);
    draw_arrow(!iDirection);
    iArrow = floor(iPoints/POINTS_BEFORE_CHANGE);
  }

  myDisplay.swap_buffers();
  
  Serial.println((String)myGame.get_score(TEAM_LEFT) + " - " + (String)myGame.get_score(TEAM_RIGHT) + " [" + (String)myButtons.sHistory + "]");
}


/* ---------------------------------- */
// void process_scores()
// calculate scores and update score board
/* ---------------------------------- */
void process_button_presses(String sButtons) {
  int iTeam;
  
  if (myGame.GameOn) {
    if (myButtons.bFiveClaimed) {
      if (myButtons.buttonHeldOwner == 1 || myButtons.buttonHeldOwner == 2) {
        iTeam = TEAM_LEFT;
        if (sButtons == "0010" || sButtons == "0001") {
          Serial.println("5 points PASSED");
          myGame.adjust_points(iTeam, 4);
        } else {
          Serial.println("5 points FAILED");
          myGame.adjust_points(iTeam, -1);
        }
      } else {
        iTeam = TEAM_RIGHT;
        if (sButtons == "1000" || sButtons == "0100") {
          Serial.println("5 points PASSED");
          myGame.adjust_points(iTeam, 4);
        } else {
          Serial.println("5 points FAILED");
          myGame.adjust_points(iTeam, -1);
        }
      }
      draw_arrow(myGame.get_direction());
      myButtons.bFiveClaimed = false;
    } else
    // Players 1 and 2
    if (sButtons == "1000" || sButtons == "0100") {
      iTeam = TEAM_LEFT;
      myGame.adjust_points(iTeam, 1);
    } else if (sButtons == "1100") {
      iTeam = TEAM_LEFT;
      if (myGame.get_score(iTeam) > 0) {
        myGame.adjust_points(iTeam, -1);
      }
    } else if (sButtons == "0010" || sButtons == "0001") {     // Players 3 and 4
      iTeam = TEAM_RIGHT;
      myGame.adjust_points(iTeam, 1);
    } else if (sButtons == "0011") {
      iTeam = TEAM_RIGHT;
      if (myGame.get_score(iTeam) > 0) {
        myGame.adjust_points(iTeam, -1);
      }
    } else if (sButtons == "1111") { // Functions
      myButtons.wait_for_zero = true;
      myGame.reset();
    }
  } else {
    if (sButtons == "1000" || sButtons == "0100") { myGame.start(0); }
    if (sButtons == "0010" || sButtons == "0001") { myGame.start(1); }
  }
}


