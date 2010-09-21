#include <stdio.h>
#include <MsTimer2.h>
#include <Wire.h>
#include "Display.h"

// Initialise constants - These babies won't change
const String VERSION = "v01g";
const int P1_BUTTON = 38;         // the number of the pushbutton pin
const int P2_BUTTON = 39;         // the number of the pushbutton pin
const int P3_BUTTON = 40;         // the number of the pushbutton pin
const int P4_BUTTON = 41;         // the number of the pushbutton pin
const int HISTORY_LENGTH = 8;     // the history length
const long DEBOUNCE_DELAY = 20;   // the debounce time; increase if the output flickers
const int POINTS_BEFORE_CHANGE = 5;

// Initialise variables - These babies will change
boolean button_pressed = false;
boolean score_update = false;
String sHistory = "";
String sButtons = "0000";
char cChar[0];
int iPoints = 5;
int score_board[] = {0,0};
boolean iDirection = true;
Display myDisplay = Display();

/* ---------------------------------- */
// void setup()
// setup all the good stuff
/* ---------------------------------- */
void setup() {
  Wire.begin();    // join I2C bus (address optional for master)
  Serial.begin(57600); 
  // config serial as 9600 for some sweet serial monitor action
  debug("PingPong v" + (String)VERSION);
  debug("--------------");
  pinMode(P1_BUTTON, INPUT);     // set P1_BUTTON as an INPUT
  pinMode(P2_BUTTON, INPUT);     // set P2_BUTTON as an INPUT
  pinMode(P3_BUTTON, INPUT);     // set P3_BUTTON as an INPUT
  pinMode(P4_BUTTON, INPUT);     // set P4_BUTTON as an INPUT
  pinMode(13, OUTPUT);
  MsTimer2::set(500, flash); // 500ms period
  MsTimer2::start();
  myDisplay.set_ink(10,0,0);
  myDisplay.set_paper(0,0,0);
//  myDisplay.show_word("PONG");
}

/* ---------------------------------- */
// void loop()
// loop all the good stuff
/* ---------------------------------- */
void loop() {
  screen_saver("PING PONG ROCKS MY JOCKS     :)");

  get_button_states();                               // see whats going on with the buttons
  if (button_pressed) {
    process_button_presses();                                  // process button presses
  }
  if (score_update) {
    update_score_board(score_board);
  }
}

void screen_saver(String sScrollText) {
  static long previousMillis = 0;        // will store last time LED was updated
  static int iScroll = 60;
  long interval = 100;           // interval at which to blink (milliseconds)
  unsigned long currentMillis = millis();
  int iTextLen = sScrollText.length()*8*-1;

  if(currentMillis - previousMillis > interval) {
    previousMillis = currentMillis;
    myDisplay.show_word(sScrollText, iScroll, true);
    iScroll--;
    if (iScroll < iTextLen) {
      iScroll = 60;
      myDisplay.set_ink(random(0,15),random(0,15),random(0,15));
    }
  }
}

void flash() {
  static boolean output = HIGH;
  
  digitalWrite(13, output);
  output = !output;
}

void draw_arrow(int _iDirection) {
//  myDisplay.clear_buffers(true);
  myDisplay.set_ink(0,10,0);
//  sendCMD(0x12, CMD_CLEAR_PAPER);
  if (_iDirection) {
    myDisplay.draw_pixel(0x12, 1, 2);
    myDisplay.draw_pixel(0x12, 2, 1);
    myDisplay.draw_pixel(0x12, 1, 5);
    myDisplay.draw_pixel(0x12, 2, 6);
  } else {
    myDisplay.draw_pixel(0x12, 6, 2);
    myDisplay.draw_pixel(0x12, 5, 1);
    myDisplay.draw_pixel(0x12, 6, 5);
    myDisplay.draw_pixel(0x12, 5, 6);
  }
  myDisplay.draw_square(0x12, 0, 3, 7, 4);
  myDisplay.set_ink(10,0,0);
}

/* ---------------------------------- */
// void display_word()
// display a word on the scoreboard
/* ---------------------------------- */

/* ---------------------------------- */
// void update_score_board(int* score)
// formats score for score board and displays it
/* ---------------------------------- */
void update_score_board(int* score) {
  double dFract, dInt;
  String sNum;
  static int score_board_old[] = {-1,-1};

  debug("refreshing score board");

  if (score[0] < 10) sNum = "0" + (String)score[0]; else sNum = (String)score[0];
  if (score[0] != score_board_old[0]) {
    myDisplay.character(0x10, 0, 0, sNum[0], true);
    myDisplay.character(0x11, 0, 0, sNum[1], true);
  }
  
  if (score[1] < 10) sNum = "0" + (String)score[1]; else sNum = (String)score[1];
  if (score[1] != score_board_old[1]) {
    myDisplay.character(0x13, 1, 0, sNum[0], true);
    myDisplay.character(0x14, 1, 0, sNum[1], true);
  }
  
  if (iPoints == 5) {
    iPoints = 0;
    iDirection = !iDirection;
    draw_arrow(iDirection);
  }
  

  myDisplay.swap_buffers();
  
  score_board_old[0] = score[0];
  score_board_old[1] = score[1];
  
  debug((String)score_board[0] + " - " + (String)score_board[1] + " [" + (String)sHistory + "]");
  score_update = false;
}


/* ---------------------------------- */
// void process_scores()
// calculate scores and update score board
/* ---------------------------------- */
void process_button_presses() {
  static boolean bGameOn = false;

  if (bGameOn) {
    // Players 1 and 2
    if (sButtons == "1000" || sButtons == "0100") { score_board[0] += 1; score_update = true; iPoints++; }
    if (sButtons == "1100") { if (score_board[0] > 0) { score_board[0] -= 1; score_update = true;  iPoints--; } }

    // Players 3 and 4
    if (sButtons == "0010" || sButtons == "0001") { score_board[1] += 1; score_update = true;  iPoints++; }
    if (sButtons == "0011") { if (score_board[1] > 0) { score_board[1] -= 1; score_update = true;  iPoints--; } }
    
    // Functions
    if (sButtons == "1111") {
      score_board[0] = 0;
      score_board[1] = 0;
      sHistory = "";
      score_update = true;
    }
  } else {
    if (sButtons == "1000" || sButtons == "0100") { iDirection = 1; score_update = true; bGameOn = true; }
    if (sButtons == "0010" || sButtons == "0001") { iDirection = 0; score_update = true; bGameOn = true; }
  }
  button_pressed = false;
}

void update_score_board() {
  if (score_update) {
    debug((String)score_board[0] + " - " + (String)score_board[1] + " [" + (String)sHistory + "]");
    score_update = false;
  }
}

/* ---------------------------------- */
// void get_button_states()
// get current button states
/* ---------------------------------- */
void get_button_states() {
  static int button_states[] = {LOW,LOW,LOW,LOW};
  static int button_state;
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
        button_pressed = true;
        sHistory = (iCount+1) + sHistory;
      }
    } else if (button_state == LOW && button_states[iCount] == HIGH) {
      lastDebounceTime = millis();
      button_states[iCount] = button_state;
    }
  sButtons= sButtons + (int)button_state;
  }
  sHistory = sHistory.substring(0,HISTORY_LENGTH); // force history to only hold HISTORY_LENGTH previous button presses
}

/* ---------------------------------- */
// void debug()
// print debug messages to the seri
/* ---------------------------------- */
void debug(String msg) {
  Serial.println(msg);
}
