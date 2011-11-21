#include <TVout.h>
#include <fontALL.h>
#include <EEPROM.h>
#include "schematic.h"
#include "TVOlogo.h"
#include "wiring_private.h"
#include "pins_arduino.h"
#undef round

TVout TV;

int zOff = 150;
int xOff = 0;
int yOff = 0;
int cSize = 50;
int view_plane = 64;
float angle = PI/60;

float cube3d[8][3] = {
  {xOff - cSize,yOff + cSize,zOff - cSize},
  {xOff + cSize,yOff + cSize,zOff - cSize},
  {xOff - cSize,yOff - cSize,zOff - cSize},
  {xOff + cSize,yOff - cSize,zOff - cSize},
  {xOff - cSize,yOff + cSize,zOff + cSize},
  {xOff + cSize,yOff + cSize,zOff + cSize},
  {xOff - cSize,yOff - cSize,zOff + cSize},
  {xOff + cSize,yOff - cSize,zOff + cSize}
};
unsigned char cube2d[8][2];

int t = 0;
int i = 0;

const int MARIPOSA_SIZE = 131;
char mariposa[MARIPOSA_SIZE];
char *sample_pointer = mariposa;

void our_hbi_hook() {
  return; 
  
  if (++i != 2) return;
  i = 0;
  t++;
  
  //  analogWrite(11, );
  //   analogWrite(11, 255);
  //OCR2A = 255-((1<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | -t >> 10); // t & t >> 8; // set pwm duty
  OCR2A = *sample_pointer++;
  if (sample_pointer == mariposa + MARIPOSA_SIZE) {
    sample_pointer = mariposa;
  }
}

void setup() {

  //  mariposa[0] = 0;
//   mariposa[1] = 0;
//   mariposa[2] = 0;
//   mariposa[3] = 0;
//   mariposa[4] = 0;
//   mariposa[5] = 0;
//   mariposa[6] = 0;
//   mariposa[7] = 0;
//   mariposa[8] = 0;
//   mariposa[9] = 0;
//   mariposa[10] = 0;
//   mariposa[11] = 0;
//   mariposa[12] = 0;
//   mariposa[13] = 0;
//   mariposa[14] = 0;
//   mariposa[15] = 0;
//   mariposa[16] = 0;
//   mariposa[17] = 0;
//   mariposa[18] = 0;
//   mariposa[19] = 0;
//   mariposa[20] = 0;
//   mariposa[21] = 0;
//   mariposa[22] = 0;
//   mariposa[23] = 0;
//   mariposa[24] = 0;
//   mariposa[25] = 0;
//   mariposa[26] = 0;
//   mariposa[27] = 0;
//   mariposa[28] = 0;
//   mariposa[29] = 0;
//   mariposa[30] = 0;
//   mariposa[31] = 0;
//   mariposa[32] = 0;
//   mariposa[33] = 0;
//   mariposa[34] = 0;
//   mariposa[35] = 0;
//   mariposa[36] = 0;
//   mariposa[37] = 0;
//   mariposa[38] = 0;
//   mariposa[39] = 0;
//   mariposa[40] = 0;
//   mariposa[41] = 0;
//   mariposa[42] = 0;
//   mariposa[43] = 0;
//   mariposa[44] = 0;
//   mariposa[45] = 0;
//   mariposa[46] = 0;
//   mariposa[47] = 0;
//   mariposa[48] = 0;
//   mariposa[49] = 0;
//   mariposa[50] = 0;
//   mariposa[51] = 0;
//   mariposa[52] = 0;
//   mariposa[53] = 0;
//   mariposa[54] = 0;
//   mariposa[55] = 0;
//   mariposa[56] = 0;
//   mariposa[57] = 0;
//   mariposa[58] = 0;
//   mariposa[59] = 0;
//   mariposa[60] = 0;
//   mariposa[61] = 0;
//   mariposa[62] = 0;
//   mariposa[63] = 0;
//   mariposa[64] = 0;
//   mariposa[65] = 0;
//   mariposa[66] = 0;
//   mariposa[67] = 0;
//   mariposa[68] = 0;
//   mariposa[69] = 0;
//   mariposa[70] = 0;
//   mariposa[71] = 0;
//   mariposa[72] = 0;
//   mariposa[73] = 0;
//   mariposa[74] = 0;
//   mariposa[75] = 0;
//   mariposa[76] = 0;
//   mariposa[77] = 0;
//   mariposa[78] = 0;
//   mariposa[79] = 0;
//   mariposa[80] = 0;
//   mariposa[81] = 0;
//   mariposa[82] = 0;
//   mariposa[83] = 0;
//   mariposa[84] = 0;
//   mariposa[85] = 0;
//   mariposa[86] = 0;
//   mariposa[87] = 0;
//   mariposa[88] = 0;
//   mariposa[89] = 0;
//   mariposa[90] = 0;
//   mariposa[91] = 0;
//   mariposa[92] = 0;
//   mariposa[93] = 0;
//   mariposa[94] = 0;
//   mariposa[95] = 0;
//   mariposa[96] = 0;
//   mariposa[97] = 0;
//   mariposa[98] = 0;
//   mariposa[99] = 0;
//   mariposa[100] = 0;
//   mariposa[101] = 0;
//   mariposa[102] = 0;
//   mariposa[103] = 0;
//   mariposa[104] = 0;
//   mariposa[105] = 0;
//   mariposa[106] = 0;
//   mariposa[107] = 0;
//   mariposa[108] = 0;
//   mariposa[109] = 0;
//   mariposa[110] = 0;
//   mariposa[111] = 0;
//   mariposa[112] = 0;
//   mariposa[113] = 0;
//   mariposa[114] = 0;
//   mariposa[115] = 0;
//   mariposa[116] = 0;
//   mariposa[117] = 0;
//   mariposa[118] = 0;
//   mariposa[119] = 0;
//   mariposa[120] = 0;
//   mariposa[121] = 0;
//   mariposa[122] = 0;
//   mariposa[123] = 0;
//   mariposa[124] = 0;
//   mariposa[125] = 0;
//   mariposa[126] = 0;
//   mariposa[127] = 0;
//   mariposa[128] = 0;
//   mariposa[129] = 0;
//   mariposa[130] = 0;

  for (int t = 0; t < MARIPOSA_SIZE; t++) {
    // mariposa[t] = 0;
    //mariposa[t] = 255-((1<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | t >> 10);
  }
  
  // audio insert
  pinMode(11, OUTPUT);
  TV.set_hbi_hook(&our_hbi_hook);
  
  // connect pwm to pin on timer 2
  sbi(TCCR2A, COM2A1);
  TCCR2B = TCCR2B & 0xf8 | 0x01; // no prescaling on clock select

  
  /////////////////////////
  TV.begin(NTSC,120,96);
  TV.select_font(font6x8);
  intro();
  TV.println("I am the TVout\nlibrary running on a freeduino\n");
  TV.delay(2500);
  TV.println("I generate a PAL\nor NTSC composite  video using\ninterrupts\n");
  TV.delay(2500);
  TV.println("My schematic:");
  TV.delay(1500);
  TV.bitmap(0,0,schematic);
  TV.delay(10000);
  TV.clear_screen();
  TV.println("Lets see what\nwhat I can do");
  TV.delay(2000);
  
  //fonts
  TV.clear_screen();
  TV.print(0,0,"Multiple fonts:\r\n");
  TV.select_font(font4x6);
  TV.println("4x6 font FONT");
  TV.select_font(font6x8);
  TV.println("6x8 font FONT");
  TV.select_font(font8x8);
  TV.println("8x8 font FONT");
  TV.select_font(font6x8);
  TV.delay(2000);
  
  TV.clear_screen();
  TV.print(9,44,"Draw Basic Shapes");
  TV.delay(2000);
  
  //circles
  TV.clear_screen();
  TV.draw_circle(TV.hres()/2,TV.vres()/2,TV.vres()/3,WHITE);
  TV.delay(500);
  TV.draw_circle(TV.hres()/2,TV.vres()/2,TV.vres()/2,WHITE,INVERT);
  TV.delay(2000);
  
  //rectangles and lines
  TV.clear_screen();
  TV.draw_rect(20,20,80,56,WHITE);
  TV.delay(500);
  TV.draw_rect(10,10,100,76,WHITE,INVERT);
  TV.delay(500);
  TV.draw_line(60,20,60,76,INVERT);
  TV.draw_line(20,48,100,48,INVERT);
  TV.delay(500);
  TV.draw_line(10,10,110,86,INVERT);
  TV.draw_line(10,86,110,10,INVERT);
  TV.delay(2000);
  
  //random cube forever.
  TV.clear_screen();
  TV.print(16,40,"Random Cube");
  TV.print(28,48,"Rotation");
  TV.delay(2000);
  
  randomSeed(analogRead(0));
  

}

void loop() {
  int rsteps = random(10,60);
  switch(random(6)) {
    case 0:
      for (int i = 0; i < rsteps; i++) {
        zrotate(angle);
        printcube();
      }
      break;
    case 1:
      for (int i = 0; i < rsteps; i++) {
        zrotate(2*PI - angle);
        printcube();
      }
      break;
    case 2:
      for (int i = 0; i < rsteps; i++) {
        xrotate(angle);
        printcube();
      }
      break;
    case 3:
      for (int i = 0; i < rsteps; i++) {
        xrotate(2*PI - angle);
        printcube();
      }
      break;
    case 4:
      for (int i = 0; i < rsteps; i++) {
        yrotate(angle);
        printcube();
      }
      break;
    case 5:
      for (int i = 0; i < rsteps; i++) {
        yrotate(2*PI - angle);
        printcube();
      }
      break;
  }
}

void intro() {
unsigned char w,l,wb;
  int index;
  w = pgm_read_byte(TVOlogo);
  l = pgm_read_byte(TVOlogo+1);
  if (w&7)
    wb = w/8 + 1;
  else
    wb = w/8;
  index = wb*(l-1) + 2;
  for ( unsigned char i = 1; i < l; i++ ) {
    TV.bitmap((TV.hres() - w)/2,0,TVOlogo,index,w,i);
    index-= wb;
    TV.delay(50);
  }
  for (unsigned char i = 0; i < (TV.vres() - l)/2; i++) {
    TV.bitmap((TV.hres() - w)/2,i,TVOlogo);
    TV.delay(50);
  }
  TV.delay(3000);
  TV.clear_screen();
}

void printcube() {
  //calculate 2d points
  for(byte i = 0; i < 8; i++) {
    cube2d[i][0] = (unsigned char)((cube3d[i][0] * view_plane / cube3d[i][2]) + (TV.hres()/2));
    cube2d[i][1] = (unsigned char)((cube3d[i][1] * view_plane / cube3d[i][2]) + (TV.vres()/2));
  }
  TV.delay_frame(1);
  TV.clear_screen();
  draw_cube();
}

void zrotate(float q) {
  float tx,ty,temp;
  for(byte i = 0; i < 8; i++) {
    tx = cube3d[i][0] - xOff;
    ty = cube3d[i][1] - yOff;
    temp = tx * cos(q) - ty * sin(q);
    ty = tx * sin(q) + ty * cos(q);
    tx = temp;
    cube3d[i][0] = tx + xOff;
    cube3d[i][1] = ty + yOff;
  }
}

void yrotate(float q) {
  float tx,tz,temp;
  for(byte i = 0; i < 8; i++) {
    tx = cube3d[i][0] - xOff;
    tz = cube3d[i][2] - zOff;
    temp = tz * cos(q) - tx * sin(q);
    tx = tz * sin(q) + tx * cos(q);
    tz = temp;
    cube3d[i][0] = tx + xOff;
    cube3d[i][2] = tz + zOff;
  }
}

void xrotate(float q) {
  float ty,tz,temp;
  for(byte i = 0; i < 8; i++) {
    ty = cube3d[i][1] - yOff;
    tz = cube3d[i][2] - zOff;
    temp = ty * cos(q) - tz * sin(q);
    tz = ty * sin(q) + tz * cos(q);
    ty = temp;
    cube3d[i][1] = ty + yOff;
    cube3d[i][2] = tz + zOff;
  }
}

void draw_cube() {
  TV.draw_line(cube2d[0][0],cube2d[0][1],cube2d[1][0],cube2d[1][1],WHITE);
  TV.draw_line(cube2d[0][0],cube2d[0][1],cube2d[2][0],cube2d[2][1],WHITE);
  TV.draw_line(cube2d[0][0],cube2d[0][1],cube2d[4][0],cube2d[4][1],WHITE);
  TV.draw_line(cube2d[1][0],cube2d[1][1],cube2d[5][0],cube2d[5][1],WHITE);
  TV.draw_line(cube2d[1][0],cube2d[1][1],cube2d[3][0],cube2d[3][1],WHITE);
  TV.draw_line(cube2d[2][0],cube2d[2][1],cube2d[6][0],cube2d[6][1],WHITE);
  TV.draw_line(cube2d[2][0],cube2d[2][1],cube2d[3][0],cube2d[3][1],WHITE);
  TV.draw_line(cube2d[4][0],cube2d[4][1],cube2d[6][0],cube2d[6][1],WHITE);
  TV.draw_line(cube2d[4][0],cube2d[4][1],cube2d[5][0],cube2d[5][1],WHITE);
  TV.draw_line(cube2d[7][0],cube2d[7][1],cube2d[6][0],cube2d[6][1],WHITE);
  TV.draw_line(cube2d[7][0],cube2d[7][1],cube2d[3][0],cube2d[3][1],WHITE);
  TV.draw_line(cube2d[7][0],cube2d[7][1],cube2d[5][0],cube2d[5][1],WHITE);
}
