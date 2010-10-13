/*

  Game.h - Game class for custom Ping Pong Score Board
  Daniel Mackie <eikcam@gmail.com>

*/
#ifndef Game_h
#define Game_h

#include "WProgram.h"

#define TEAM_LEFT          1
#define TEAM_RIGHT         0

class Game {
  public:
  Game();
  void start(boolean bTeam);
  void reset();
  void adjust_points(boolean bTeam, int iPoints);
  int get_score(boolean bTeam);
  int get_points();
  int get_direction();
  void set_direction(boolean bTeam);
  int get_winner();
  void adjust_serve();
  boolean score_changed(boolean bTeam, boolean reset = false);
  boolean GameOn;
  int FivePointsClaimed;
  int ChangeServeOnPoints;
  boolean FivePointsClaimAllowed;
  
  
  private:
  int iGamePoints;
  int iScore_Left;
  int iScore_Right;
  int iDirection;
  int iWinner;
  int iServeChanges;
  boolean bServeChangeSkip;
  boolean bScore_Left_Changed;
  boolean bScore_Right_Changed;
  void check_scores();
  
};

#endif
