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
  
  if (!myGame.GameOn) {myDisplay.screen_saver(sScreenSaver, SCROLL_R2L); }

  if (myButtons.get_button_states(sButtons)) {
    myGame.FivePointsClaimAllowed = (myButtons.MultiButtons) ? false : true;
    process_button_presses(sButtons);                                  // process button presses
    update_score_board();
    if (myGame.get_winner() != -1) {
      Serial.print("WINNER IS - ");
      Serial.println(myGame.get_winner());
    }
  }

  if (myButtons.buttonHeld && !myGame.FivePointsClaimed && myGame.FivePointsClaimAllowed) {
    if (millis() - myButtons.buttonHeldTime > 1000) {
      Serial.print("5 points claimed by player ");
      Serial.println(myButtons.buttonHeld);
      myDisplay.show_word("FIVE?");
      myGame.FivePointsClaimed = myButtons.buttonHeld;
      myButtons.wait_for_zero = true;
    }
  }

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
//      Serial.println(sButtons);
      if (myGame.FivePointsClaimed == 1 || myGame.FivePointsClaimed == 2) {
        if (sButtons == "0010" || sButtons == "0001") {
          Serial.println("5 points PASSED");
          myGame.adjust_points(TEAM_LEFT, 5);
          myGame.adjust_points(TEAM_RIGHT, 0);
        } else {
          Serial.println("5 points FAILED");
          myGame.adjust_points(TEAM_LEFT, 0);
          myGame.adjust_points(TEAM_RIGHT, 0);
        }
      } else {
        if (sButtons == "1000" || sButtons == "0100") {
          Serial.println("5 points PASSED");
          myGame.adjust_points(TEAM_RIGHT, 5);
          myGame.adjust_points(TEAM_LEFT, 0);
        } else {
          Serial.println("5 points FAILED");
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


