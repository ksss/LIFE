#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <stdarg.h>
#include <string.h>

struct life {
  char **world;
  int width;
  int height;
};

void
fatal(const char *format)
{
  printf("%s\n", format);
  exit(1);
}

struct life *
life_parse(int fd)
{
  struct life *life;
  char check_buf[512];
  ssize_t read_n = 1; // start
  int i, w = 0, h = 0, max_w = 0;
  char tmp_world[128][128];
  char **world;

  while (read_n != 0) {
    read_n = read(fd, check_buf, 512);

    if (read_n <= -1)
      fatal("faild read");

    for(i = 0; i < read_n; i++) {
      tmp_world[h][w] = 0;

      switch (check_buf[i]) {
        case '0':
          tmp_world[h][w] = '0';
          w++;
          break;
        case '1':
          tmp_world[h][w] = '1';
          w++;
          break;
        case '\n':
          h++;
          if (max_w < w)
            max_w = w;
          w = 0;
          break;
        case ' ':
          break;
        default:
          printf("'%d'\n", check_buf[i]);
          fatal("invalid char");
      }
    }
  }

  world = (char **) malloc(h * sizeof(char *));
  for (i = 0; i < h; i++) {
    world[i] = (char *) calloc(max_w, sizeof(char));
    memcpy(world[i], tmp_world[i], max_w * sizeof(char));
  }

  life = (struct life *) malloc(sizeof(struct life));
  life->world = world;
  life->width = max_w;
  life->height = h;
  return life;
}

void
life_run(struct life *life, void (*func)(struct life *))
{
  while(1) {
    func(life);
    usleep(100000);
  }
}

void
life_put(struct life *life)
{
  int x, y, i, j;
  int ys, ye, xs, xe;
  int live_size = strlen("■"), dead_size = strlen("□");
  char **next_world = (char **) alloca(life->height * sizeof(char *));
  char *line = (char *) alloca(life->width * sizeof(char) * 4);
  char *p = line;

  for (i = 0; i < life->height; i++) {
    next_world[i] = (char *) alloca(life->width * sizeof(char));
    memset(next_world[i], 0, life->width * sizeof(char));
  }

  for (y = 0; y < life->height; y++) {
    for (x = 0; x < life->width; x++) {
      if (life->world[y][x] == '1') {
        ys = y == 0 ? 0 : y - 1;
        ye = y == life->height - 1 ? life->height - 1 : y + 1;
        xs = x == 0 ? 0 : x - 1;
        xe = x == life->width - 1 ? life->width - 1 : x + 1;
        for (j = ys; j <= ye; j++) {
          for (i = xs; i <= xe; i++) {
            next_world[j][i] += 1;
          }
        }
      }
    }
  }

  system("clear");
  for (y = 0; y < life->height; y++) {
    memset(line, 0, life->width * sizeof(char) * 4);
    p = line;
    for (x = 0; x < life->width; x++) {
      if (next_world[y][x] == 3) {
        life->world[y][x] = '1';
        memcpy(p, "■", live_size);
        p += live_size;
      } else if (next_world[y][x] != 4) {
        life->world[y][x] = '0';
        memcpy(p, "□", dead_size);
        p += dead_size;
      } else {
        if (life->world[y][x] == '1') {
          memcpy(p, "■", live_size);
          p += live_size;
        } else {
          memcpy(p, "□", dead_size);
          p += dead_size;
        }
      }

      if (x == life->width - 1) {
        *p = '\n';
      } else {
        *p = ' ';
      }
      p++;
    }
    printf("%s", line);
  }
}

int main (int argc, char **argv)
{
  struct life *life = life_parse(STDIN_FILENO);
  life_run(life, life_put);
  return 0;
}
