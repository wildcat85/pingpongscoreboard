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
const String VERSION = "0.1";

// Initialise variables - These babies will change
String sButtons;
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
  myGame.ChangeServeOnPoints = 5;
  myButtons.assignPlayers(36, 48, 44, 40);
  myDisplay.set_ink(15,0,0);
  myDisplay.set_paper(0,0,0);
}

/* ---------------------------------- */
// void loop()
// loop all the good stuff
/* ---------------------------------- */
void loop() {
  
  if (!myGame.GameOn) {
    myDisplay.screen_saver(sScreenSaver, SCROLL_R2L);
  } 

  if (myButtons.get_button_states(sButtons)) {
    process_button_presses(sButtons);
    if (myGame.GameOn) { update_score_board(); }
  }

  if (myGame.GameOn) {
    myGame.FivePointsClaimAllowed = (myButtons.MultiButtons || myGame.get_winner() != -1) ? false : true;
    if (myButtons.buttonHeld && !myGame.FivePointsClaimed && myGame.FivePointsClaimAllowed) {
      if (millis() - myButtons.buttonHeldTime > 1000) {
        myDisplay.show_word("FIVE?");
        myGame.FivePointsClaimed = myButtons.buttonHeld;
        myButtons.wait_for_zero = true;
      }
    }
  }
}

/* ---------------------------------- */
// void update_score_board(int* score)
// formats score for score board and displays it
/* ---------------------------------- */
void update_score_board() {
  String sNum;
  int iPoints, iScore, iDirection;

  iDirection = myGame.get_direction();
  iPoints = myGame.get_points();
  
  myGame.check_scores();

  iScore = myGame.get_score(TEAM_LEFT);
  if (myGame.get_winner() == TEAM_LEFT) { myDisplay.set_ink(15,15,15); }
  if (iScore < 10) sNum = "0" + (String)iScore; else sNum = (String)iScore;
  myDisplay.character(0x10, 0, 0, sNum[0], true);
  myDisplay.character(0x11, 0, 0, sNum[1], true);
  if (myGame.get_winner() == TEAM_LEFT) { myDisplay.set_ink(15,0,0); }

  iScore = myGame.get_score(TEAM_RIGHT);
  if (myGame.get_winner() == TEAM_RIGHT) { myDisplay.set_ink(15,15,15); }
  if (iScore < 10) sNum = "0" + (String)iScore; else sNum = (String)iScore;
  myDisplay.character(0x13, 1, 0, sNum[0], true);
  myDisplay.character(0x14, 1, 0, sNum[1], true);
  if (myGame.get_winner() == TEAM_RIGHT) { myDisplay.set_ink(10,0,0); }

  myDisplay.draw_arrow(myGame.get_direction());
  myDisplay.swap_buffers();
  Serial.println((String)myGame.get_score(TEAM_LEFT) + " - " + (String)myGame.get_score(TEAM_RIGHT) + " [" + (String)myButtons.sHistory + "]");
}


/* ---------------------------------- */
// void process_scores()
// calculate scores and update score board
/* ---------------------------------- */
void process_button_presses(String sButtons) {
  if (myGame.GameOn) {
    if (myGame.FivePointsClaimed) {
      if (myGame.FivePointsClaimed == 1 || myGame.FivePointsClaimed == 2) {
        if (sButtons == "0010" || sButtons == "0001") {
          myGame.adjust_serve();
          myGame.adjust_points(TEAM_LEFT, 5);
          myGame.adjust_points(TEAM_RIGHT, 0);
        } else {
          myGame.adjust_points(TEAM_LEFT, 0);
          myGame.adjust_points(TEAM_RIGHT, 0);
        }
      } else {
        if (sButtons == "1000" || sButtons == "0100") {
          myGame.adjust_serve();
          myGame.adjust_points(TEAM_RIGHT, 5);
          myGame.adjust_points(TEAM_LEFT, 0);
        } else {
          myGame.adjust_points(TEAM_RIGHT, 0);
          myGame.adjust_points(TEAM_LEFT, 0);
        }
      }
      myDisplay.draw_arrow(myGame.get_direction());
      myGame.FivePointsClaimed = false;
    } else
    // Players 1 and 2
    if (sButtons == "1000" || sButtons == "0100") {
      myGame.adjust_points(TEAM_LEFT, 1);
    } else if (sButtons == "1100") {
      if (myGame.get_score(TEAM_LEFT) > 0) {
        myGame.adjust_points(TEAM_LEFT, -1);
      }
    } else if (sButtons == "0010" || sButtons == "0001") {     // Players 3 and 4
      myGame.adjust_points(TEAM_RIGHT, 1);
    } else if (sButtons == "0011") {
      if (myGame.get_score(TEAM_RIGHT) > 0) {
        myGame.adjust_points(TEAM_RIGHT, -1);
      }
    } else if (sButtons == "1111") { // Functions
      myButtons.wait_for_zero = true;
      myGame.reset();
    }
  } else {
    if (sButtons == "1000" || sButtons == "0100") { myGame.start(TEAM_LEFT); }
    if (sButtons == "0010" || sButtons == "0001") { myGame.start(TEAM_RIGHT); }
  }
}


