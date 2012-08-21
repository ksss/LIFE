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
    next_world := List clone setSize(size) map(List clone setSize(size))
    for(y, 0, size - 1,
      ys := if(y == 0, 0, y - 1)
      ye := if(y == (size - 1), size - 1, y + 1)
      for(x, 0, size - 1,
        xs := if(x == 0, 0, x - 1)
        xe := if(x == (size - 1), size - 1, x + 1)
        count := 0
        for (i, ys, ye,
          w := world at(i)
          for (j, xs, xe,
            if(w at(j) == live, count = count + 1)
          )
        )
        if(count == 3, next_world at(y) atPut(x, live),
        if(count == 4, next_world at(y) atPut(x, world at(y) at(x)),
                       next_world at(y) atPut(x, dead)
        ))
      )
      next_world at(y) join(" ") println
    )
    self world = next_world
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
