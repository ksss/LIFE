#! /usr/bin/env io

life := Object clone do(
  live := ""
  dead := ""
  world := nil
  set := method(l, d,
    self live = l
    self dead = d
    self world = list()
    while(input := File standardInput readLine,
      self world push(input split(" ") map (_, if(_ == "1", live, dead)));
    )
  )
  next := method(
    size := world at(0) size

    next_world := List clone setSize(size) map(
      List clone setSize(size) map(0)
    )
    world foreach(y, line,
      line foreach(x, cell,
        if(cell == live,
          ys := if(y == 0, 0, y - 1)
          ye := if(y == (size - 1), size - 1, y + 1)
          xs := if(x == 0, 0, x - 1)
          xe := if(x == (size - 1), size - 1, x + 1)
          for (yy, ys, ye,
            for (xx, xs, xe,
              next_world at(yy) atPut(xx, next_world at(yy) at(xx) + 1)
            )
          )
        )
      )
    )
    next_world foreach(y, line,
      line foreach(x, i,
        if(i == 3,
          world at(y) atPut(x, live)
        , if(i != 4,
          world at(y) atPut(x, dead)
        ))
      )
      world at(y) join(" ") println
    )
  )
)

live := "■"
dead := "□"
life set(live, dead)
i := 0
while(1,
  System system("clear")
  t := Date cpuSecondsToRun(
    life next
  ) println
  (i = i + 1) println
  System sleep(0.1 - t)
)
