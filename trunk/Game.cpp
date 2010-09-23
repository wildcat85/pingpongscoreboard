#include "WProgram.h"
#include "Game.h"
//#include <Wire.h>

Game::Game() {
  Serial.println("Creating game...");
}

void Game::start(boolean bTeam) {
  Serial.println(__func__);
  iGamePoints = 0;
  iScore_Left = 0;
  iScore_Right = 0;
  set_direction(bTeam);
  bScore_Left_Changed=true;
  bScore_Right_Changed=true;
  GameOn = true;
}

void Game::reset() {
  Serial.println(__func__);
}

int Game::get_score(boolean bTeam) {
  Serial.println(__func__);
  if (bTeam) { return iScore_Left; } else { return iScore_Right; } 
}

int Game::get_points() {
  Serial.println(__func__);
  return iGamePoints;
}

int Game::get_direction() {
  Serial.println(__func__);
  return iDirection;
}

void Game::set_direction(boolean bTeam) {
  Serial.println(__func__);
  iDirection = bTeam;
}

boolean Game::score_changed(boolean bTeam) {
  if (bTeam) { return bScore_Left_Changed; } else { return bScore_Right_Changed; } 
}

void Game::add_points(boolean bTeam, int iPoints) {
  Serial.println(__func__);
  if (bTeam) { iScore_Left++; bScore_Left_Changed=true; } else { iScore_Right++; bScore_Right_Changed=true; } 
  iGamePoints++;
}

void Game::take_points(boolean bTeam, int iPoints) {
  Serial.println(__func__);
  if (bTeam) { iScore_Left--; bScore_Left_Changed=true; } else { iScore_Right--; bScore_Right_Changed=true; } 
  iGamePoints--;
}

