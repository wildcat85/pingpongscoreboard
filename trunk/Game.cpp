/*

  Game.cpp - Game class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#include "WProgram.h"
#include "Game.h"

Game::Game() {
  Serial.println("Initialising Game class");
}

void Game::start(boolean bTeam) {
//  Serial.println(__func__);
  iGamePoints = 0;
  iScore_Left = 0;
  iScore_Right = 0;
  set_direction(bTeam);
  bScore_Left_Changed=true;
  bScore_Right_Changed=true;
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

boolean Game::score_changed(boolean bTeam) {
//  Serial.println(__func__);
  if (bTeam) { return bScore_Left_Changed; } else { return bScore_Right_Changed; } 
}

void Game::adjust_points(boolean bTeam, int iPoints) {
//  Serial.println(__func__);
  int iScore = get_score(bTeam);
//  if (iScore+iPoints >= 0 && iScore+iPoints <= 21) {
    if (bTeam) {
      iScore_Left += iPoints; bScore_Left_Changed=true;
    } else {
      iScore_Right += iPoints; bScore_Right_Changed=true;
    }
    iGamePoints += iPoints;
//  }
}

