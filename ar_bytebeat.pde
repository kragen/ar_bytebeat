#include <TVout.h>
#include <fontALL.h>
#include "schematic.h"
#include "TVOlogo.h"
#include "wiring_private.h"
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

long t = 0;
char i = 0;

const int BUFFER_SIZE = 131;
char buffer[BUFFER_SIZE];
char *sample_pointer = buffer;

void our_hbi_hook() {
  if (++i != 2) return;
  i = 0;
  
  // OCR2A = t & (t >> 8); // works with long
  // OCR2A = t*(((t>>12)|(t>>8))&(63&(t>>4))); // works with int but not long
  // OCR2A = t ^ t % 255;		// doesn't even work with int. 
  // OCR2A = (t*5&t>>7)|(t*3&t>>10); // works with int but not long.
  // Nice and rhythmic and interesting, but doesn't even work with int:
  // OCR2A = (t>>6|t<<1)+(t>>5|t<<3|t>>3)|t>>2|t<<1;
  // OCR2A = 255-((1<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | -t >> 10); // t & t >> 8; // set pwm duty
  OCR2A = *sample_pointer++;
  if (sample_pointer == buffer + BUFFER_SIZE) {
    sample_pointer = buffer;
  }
}

// This stays interesting for ten minutes or so at least:
static inline char phase_rhythm() {
  unsigned ut = unsigned(t);
  char t1 = char(ut) << 1;
  unsigned t7 = ut >> 7;
  long t12 = t >> 12;
  return (t1 ^ (t1 + t7 & t12)) | ut >> (4 - (1 ^ 7 & char(t12 >> 7))) | t7;
}

void our_vbi_hook() {
  for (int j = 0; j < BUFFER_SIZE; j++) {
    buffer[j] = //t*(((t>>12)|(t>>8))&(63&(t>>4)));
      // this works okay and has an interesting rhythm, but I
      // wonder if it may be better off without the second line
      // and corresponding mixing:
      // (((((t>>6|t<<1)+(t>>5|t<<3|t>>3)|t>>2|t<<1) & t>>12) ^ t>>16) & 255)
      // >> 1 | ((t<<1&t>>9|t+1023>>9) & 255) >> 1
      // ;
      // This innocent-looking formula screwed up the vertical hold
      // something terrible sometimes!  I added char() hoping
      // it would help, and I think it finally did.  Should repeat
      // after about 4 hours.  Too bad it sounds terrible.
      // char(char(t)<<(7&(t>>12)))+(t<<1)&t>>9|t+(t>>10)>>9;
      // This is a microcontroller-friendly way to do t^t%255:
      // t ^ (char(t) + char(int(t) >> 8));
      // phase_rhythm();
      // one of these two branches is too slow with longs:
      // ((t&4096)?((t*(t^t%255)|(t>>4))>>1):(t>>3)|((t&8192)?t<<2:t));
      // this one is still too slow:
      //255-((1L<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | -t >> 10);
      // This one works with the new version of Arduino on the NAML
      // machine, but not the old version on inexorable.
      // 255-((1<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | -t >> 10);
      // Explore the space of all possible 8-beat rhythms in less than an hour.
      // It has some minor vsync problems.
      // (t<<1 ^ (t + (t >> 8))) | t >> 2 | (char(t>>15^t>>16^0x75)>>(7&t>>10)&1?0:-1);
      // The same rhythm generator, with Ryg's Chaos Theory melody instead:
      t*2*(char((t>>10)^(t>>10)-2)%11) | t >> 2 | (char(t>>15^t>>16^0x75)>>(7&t>>10)&1?0:-1);
    t++;
  }
  if (BUFFER_SIZE < 128) t += 128 - BUFFER_SIZE;
}

void setup() {
  // audio setup
  pinMode(11, OUTPUT);
  TV.set_hbi_hook(&our_hbi_hook);
  TV.set_vbi_hook(&our_vbi_hook);
  
  // connect pwm to pin on timer 2
  sbi(TCCR2A, COM2A1);
  TCCR2B = TCCR2B & 0xf8 | 0x01; // no prescaling on clock select

  /////////////////////////
  TV.begin(NTSC,120,86);
  TV.select_font(font6x8);
  intro();
  TV.println("I am the TVout\nlibrary running on a Duemilanove\n");
  TV.delay(2500);

  for (int t = 0; t < BUFFER_SIZE; t++) {
    TV.print(((unsigned char*)buffer)[t], 16);
    TV.print(' ');
    TV.print(buffer);
  }
  TV.delay(10000);

  TV.println("I generate a PAL\nor NTSC composite  video using\ninterrupts\n");
  TV.delay(2500);
  TV.println("My schematic:");
  TV.delay(1500);
  TV.bitmap(0,0,schematic);
  TV.delay(10000);
  TV.clear_screen();
  TV.println("Lets see\nwhat I can do");
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
  TV.print(buffer);
}
