#include <TVout.h>
#include <fontALL.h>
#include "schematic.h"
#include "TVOlogo.h"
#include "wiring_private.h"
#undef round

TVout TV;

long t = 0;
char i = 0;

const int BUFFER_SIZE = 131;
char buffer[BUFFER_SIZE];
char *sample_pointer = buffer;

// a place to stick a number to debug with
char samples_spat_out_by_asm;

#if 0

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

#else

// The assembly routine that we execute before each video line to spit out
// a sample.
// You'd think you'd want to make this __attribute__(bare) or whatever.
// But it turns out that the only stupidity added is an extra RET at the end.
void our_hbi_hook()
{
  asm volatile(
  "OCR2A = 179\n\t"
  "BUFFER_SIZE = 131\n\t"
  "\n\t"
  "       ;; segun\n\t"
  "       ;; http://www.nongnu.org/avr-libc/user-manual/FAQ.html#faq_reg_usage\n\t"
  "       ;; r18-r27 y r30-r31 estan disponibles, y r0.\n\t"
  "       lds r24,i               ; r24 := i\n\t"
  "       subi r24,lo8(-(1))      ; r24++\n\t"
  "\n\t"
  "       lds r30,sample_pointer  ; Z := sample_pointer\n\t"
  "       lds r31,sample_pointer+1\n\t"
  "       ld r25,Z+               ; r25 := *sample_pointer\n\t"
  "\n\t"
  "       ldi r26,lo8(buffer)     ; r27:r26 := buffer\n\t"
  "       ldi r27,hi8(buffer)\n\t"
  "\n\t"
  "       ;; Aca tenemos todos los valores que podemos necesitar:\n\t"
  "       ;; i (incrementado) en r24\n\t"
  "       ;; sample_pointer (incrementado) en Z\n\t"
  "       ;; *sample_pointer en r25\n\t"
  "       ;; buffer en r27:r26\n\t"
  "\n\t"
  "       cpi r24,lo8(2)          ; i == 2?\n\t"
  "       brne 1f                 ; si i == 2, seguimos. 1 ciclo\n\t"
  "       sts i,__zero_reg__      ; 1 ciclo   total 2\n\t"
  "       sts OCR2A,r25           ; 1 ciclo   total 3\n\t"
  // one line and two cycles of debug code
  // "       sts samples_spat_out_by_asm, r25\n\t"
  "       ;; BORRAMOS la copia de i en r24 para reutilizarlo:\n\t"
  "       ldi r24,hi8(buffer+BUFFER_SIZE)\n\t"
  "                               ; 1 ciclo   total 4\n\t"
  "       cpi r30,lo8(buffer+BUFFER_SIZE)\n\t"
  "                               ; 1 ciclo   total 5\n\t"
  "       cpc r31,r24             ; Z == buffer+BUFFER_SIZE?\n\t"
  "                               ; 1 ciclo   total 6\n\t"
  "       breq 2f                 ; si Z != buffer+BUFFER_SIZE, seguimos\n\t"
  "                               ; 1 ciclo   total 7\n\t"
  "       sts sample_pointer+1,r31 ; 2 ciclos total 9\n\t"
  "       sts sample_pointer,r30  ; 2 ciclos  total 11\n\t"
  "       nop                     ; 1 ciclo   total 12\n\t"
  "       ret\n\t"
  "\n\t"
  "       ;; Caso en que reseteamos sample_pointer:\n\t"
  "2:                             ; 2 ciclos por haber saltado  total 8\n\t"
  "       sts sample_pointer+1,r27; 2 ciclos  total 10\n\t"
  "       sts sample_pointer,r26  ; 2 ciclos  total 12\n\t"
  "       ret\n\t"
  "\n\t"
  "       ;; Caso en que no emitimos ninguna muestra:\n\t"
  "1:                             ; 2 ciclos por haber saltado  total 2\n\t"
  "       sts i,r24               ; 2 ciclos  total 4\n\t"
  "       rjmp .+0                ; 2 ciclos  total 6\n\t"
  "       rjmp .+0                ; 2 ciclos  total 8\n\t"
  "       rjmp .+0                ; 2 ciclos  total 10\n\t"
  "       rjmp .+0                ; 2 ciclos  total 12\n\t"
  // two cycles of debug code
  // "       rjmp .+0\n\t"
  "       ret\n\t"
  : :);
}

#endif

// This stays interesting for ten minutes or so at least,
// and repeats about every twenty:
static inline char crowd() {
  // unoptimized formula:
  // ((t<<1)^((t<<1)+(t>>7)&t>>12))|t>>(4-(1^7&(t>>19)))|t>>7
  unsigned ut = unsigned(t);
  char t1 = char(ut) << 1;
  unsigned t7 = ut >> 7;
  long t12 = t >> 12;
  return (t1 ^ (t1 + t7 & t12)) | ut >> (4 - (1 ^ 7 & char(t12 >> 7))) | t7;
}

static inline char triangle_bells() {
  char f = (unsigned char)((unsigned char)(t >> 11) % 63 ^ (0x15 + t >> 12)) %10*2%13*4;
  // unoptimized formula:
  // return (f = ((t >> 11) % 63 ^ (0x15 + t >> 12)) %10*2%13*4, ((((t * f & 256) == 0) - 1 ^ t * f) & 255) >> ((t >> 7 + (t >> 13 & 1)) & 7));
  unsigned short ust = t;
  return (((((ust * f & 256) == 0) - 1 ^ ust * f) & 255) >> ((ust >> 7 + (ust >> 13 & 1)) & 7));
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
      // crowd();
      // one of these two branches is too slow with longs:
      // ((t&4096)?((t*(t^t%255)|(t>>4))>>1):(t>>3)|((t&8192)?t<<2:t));
      // this one is still too slow:
      //255-((1L<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | -t >> 10);
      // This one works with the new version of Arduino on the NAML
      // machine, but not the old version on inexorable; too slow!
      // 255-((1<<28)/(1+(t^0x5800)%0x8000) ^ t | t >> 4 | -t >> 10);
      // Explore the space of all possible 8-beat rhythms in less than an hour.
      // It has some minor vsync problems.
      // (t<<1 ^ (t + (t >> 8))) | t >> 2 | (char(t>>15^t>>16^0x75)>>(7&t>>10)&1?0:-1);
      // The same rhythm generator, with Ryg's Chaos Theory melody instead:
      // t*2*(char((t>>10)^(t>>10)-2)%11) | t >> 2 | (char(t>>15^t>>16^0x75)>>(7&t>>10)&1?0:-1);
      // a sort of salsa beat; this one has some kind of incompatibility with JS:
      // (t*t>>(4-((t>>14)&7)))*t|(t&t-(2047&~(t>>7)))>>5|t>>3;
      // A triangle wave!
      // 8*t & 0x100 ? -8*t-1 : 8*t;
      triangle_bells();
    t++;
  }
  if (BUFFER_SIZE < 128) t += 128 - BUFFER_SIZE;
}

const int height = 86;
const int width = 120;

void setup() {
  // audio setup
  pinMode(11, OUTPUT);
  TV.set_hbi_hook(&our_hbi_hook);
  TV.set_vbi_hook(&our_vbi_hook);
  
  // connect pwm to pin on timer 2
  sbi(TCCR2A, COM2A1);
  TCCR2B = TCCR2B & 0xf8 | 0x01; // no prescaling on clock select

  /////////////////////////
  TV.begin(NTSC, width, height);
  TV.select_font(font6x8);
  intro();
  
}

void loop() {
  //TV.clear_screen();

  //TV.print(int((unsigned char)buffer[0]), 16);
  //TV.print(' ');

  for (unsigned char i = 10; i < height; i++) {
    TV.fill_line(i, 0, width-1, 0);
    TV.fill_line(i, 
		 width/2 - buffer[i]/4, 
		 width/2 + buffer[i]/4, 
		 2);
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
