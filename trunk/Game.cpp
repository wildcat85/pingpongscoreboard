/*

  Game.cpp - Game class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#include "WProgram.h"
#include "Game.h"

Game::Game() {
  Serial.println("Initialising Game class");
  GameOn = false;
  iWinner = -1;
}

void Game::start(boolean bTeam) {
//  Serial.println(__func__);
  iGamePoints = 0;
  iScore_Left = 0;
  iScore_Right = 0;
  iServeChanges = 0;
  set_direction(bTeam);
  bScore_Left_Changed=true;
  bScore_Right_Changed=true;
  iWinner = -1;
  FivePointsClaimed = false;
  GameOn = true;
}

void Game::reset() {
//  Serial.println(__func__);
  Serial.println("resetting game");
  GameOn = false;
}

int Game::get_score(boolean bTeam) {
//  Serial.println(__func__);
  if (bTeam) { return iScore_Left; } else { return iScore_Right; } 
//  return (bTeam) ? iScore_Left : iScore_Right;
}

int Game::get_points() {
//  Serial.println(__func__);
  return iGamePoints;
}

int Game::get_direction() {
//  Serial.println(__func__);
  return iDirection;
}

void Game::set_direction(boolean bTeam) {
//  Serial.println(__func__);
  iDirection = bTeam;
}

boolean Game::score_changed(boolean bTeam, boolean reset) {
  boolean result;  
//  Serial.println(__func__);
  if (bTeam) {
    result = bScore_Left_Changed;
    if (reset) { bScore_Left_Changed = false; }
  } else {
    result = bScore_Right_Changed;
    if (reset) { bScore_Right_Changed = false; }
  }
  return result;
}

void Game::adjust_points(boolean bTeam, int iPoints) {
//  Serial.println(__func__);
  int iScore = get_score(bTeam);
  if (iWinner == -1) {
    if (bTeam) {
      iScore_Left += iPoints; bScore_Left_Changed=true;
    } else {
      iScore_Right += iPoints; bScore_Right_Changed=true;
    }
    iGamePoints += iPoints;
    check_scores();
  }
}

void Game::check_scores() {
//  Serial.println(__func__);
  if (iScore_Left >= 21 && (iScore_Left - iScore_Right) >= 2) {
    iWinner = TEAM_LEFT;
  } else if (iScore_Right >= 21 && (iScore_Right - iScore_Left) >= 2) {
    iWinner = TEAM_RIGHT;
  } else {
    iWinner = -1;
  }

  if (floor(iGamePoints/ChangeServeOnPoints) != iServeChanges) {
    set_direction(!iDirection);
    iServeChanges = floor(iGamePoints/ChangeServeOnPoints);
  }

}

int Game::get_winner() {
//  Serial.println(__func__);
  return iWinner;
}

