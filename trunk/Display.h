#ifndef Display_h
#define Display_h

#define MAX_WIRE_CMD          0x80

#define CMD_NOP               0x00

#define CMD_SWAP_BUF          0x10
#define CMD_COPY_FRONT_BUF    0x11
#define CMD_SHOW_AUX_BUF      0x12

#define CMD_CLEAR_BUF         0x20
#define CMD_SET_PAPER         0x21
#define CMD_SET_INK           0x22
#define CMD_CLEAR_PAPER       0x25
#define CMD_DRAW_PIXEL        0x26
#define CMD_DRAW_LINE         0x27
#define CMD_DRAW_SQUARE       0x28
#define CMD_PRINT_CHAR        0x2A
#define CMD_DRAW_ROW_MASK     0x2B

#include "WProgram.h"
//#include <avr/pgmspace.h>
#include <Wire.h>

class Display {
  public:
  Display();
  void sendCMD(byte address, byte CMD, ... );
  void sendWireCommand(int Add, byte len);
  void swap_buffers(boolean bAll = false);
  void clear_buffers(boolean bAll = false);
  void draw_pixel(int iAddr, int iX, int iY);
  void draw_square(int iAddr, int iX1, int iY1, int iX2, int iY2);
  void set_ink(int iR, int iG, int iB);
  void set_paper(int iR, int iG, int iB);
  void character(int iAddr, int iX, int iY, char cChar, boolean bClearBuffer);
  void draw_row_mask(int iAddr, int iRow, int iXoffset, byte bBitmask);
  void show_word(String sWord, int iPosition = 1, boolean bForce = false);
  static const int CMD_totalArgs[];
  static const int iPanel[];
  
  private:
  unsigned char toByte(int i);
  unsigned char RainbowCMD[20];
  unsigned char State;  
  unsigned long timeout;
  static boolean changed[];
  
};

#endif
