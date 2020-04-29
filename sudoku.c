#include <stdio.h>
#include <unistd.h>
#define ANSI_COLOR_RESET "\x1b[0m"
#define ANSI_COLOR_RED "\x1b[31m"

int board[][9] ={{0, 0, 0, 9, 0, 4, 0, 0, 1},
                 {0, 2, 0, 3, 0, 0, 0, 5, 0},
                 {9, 0, 6, 0, 0, 0, 0, 0, 0},
                 {8, 0, 0, 0, 4, 6, 0, 0, 0},
                 {4, 0, 0, 0, 1, 0, 0, 0, 3},
                 {0, 0, 0, 2, 7, 0, 0, 0, 5},
                 {0, 0, 0, 0, 0, 0, 9, 0, 7},
                 {0, 7, 0, 0, 0, 5, 0, 1, 0},
                 {3, 0, 0, 4, 0, 7, 0, 0, 0},};


void print_highlight(int xarg, int yarg) {
  printf("board: \n");
  for ( int x = 0; x < 9; x++ ) {
    if ( x % 3 == 0 ) printf("\n");
    for ( int y = 0; y < 9; y++ ) {
      if ( y % 3 == 0 ) printf(" ");
      if ( x == xarg && y == yarg ) printf(ANSI_COLOR_RED "%d" ANSI_COLOR_RESET, board[x][y]);
      else printf("%d",board[x][y]);
    } printf("\n"); }
  printf("\n");
  usleep(5000);
}
void print() {
  printf("board: \n");
  for ( int x = 0; x < 9; x++ ) {
    for ( int y = 0; y < 9; y++ ) {
      printf("%d",board[x][y]);
    } printf("\n"); }
  printf("\n");
}

int possible(int x, int y, int n) {
  for ( int i = 0; i < 9; i++ ) {
    if ( board[y][i] == n ) { return 0; }
    if ( board[i][x] == n ) { return 0; }
    int x0 = (x/3)*3;
    int y0 = (y/3)*3;
    for ( int xi = 0; xi < 3; xi++) {
      for ( int yi = 0 ; yi < 3 ; yi++ ) {
        if ( board[y0 + yi][x0 + xi] == n ) { return 0; }
      }
    }
  }

    return 1;
}

int solve() {

  for ( int x = 0; x < 9; x++ ) {
    for ( int y = 0; y < 9; y++ ) {
      if ( board[y][x] == 0 ) {
        for ( int i = 1; i < 10; i++) {
          if ( possible(x, y, i) == 1) {
            board[y][x] = i;
            print_highlight(y,x);
            if(solve()) {return 1;}
            else {
              board[y][x] = 0;
              print_highlight(y,x);
            }
          }
        }
        return 0;
      }
    }
  }
}


int main() {
  print();
  solve();
  print();
}
