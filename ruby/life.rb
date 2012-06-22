#! /usr/bin/env ruby
# -*- encoding: utf-8 -*-

class LIFE
  def initialize (value)
    @live = value['live']
    @dead = value['dead']
    @world = value['world']
  end

  def next
    size = @world.size
    next_world = []
    @world.each_with_index do |line, y|
      next_world[y] = []
      line.each_index do |x|
        ys = y == 0 ? 0 : y - 1
        ye = y == size - 1 ? size - 1 : y + 1
        xs = x == 0 ? 0 : x - 1
        xe = x == size - 1 ? size - 1 : x + 1
        count = 0
        (ys..ye).each do |yy|
          (xs..xe).each do |xx|
            count += 1 if @world[yy][xx] == @live
          end
        end
        next_world[y][x] = count == 3 ? @live
          : count == 4 ? @world[y][x]
          : @dead
      end
      puts next_world[y].join ' '
    end
    @world = next_world
  end
end

live = '■'
dead = '□'
time = (ARGV.shift || 0.1).to_f
world = STDIN.read.split(/\n/).map { |i|
  i.gsub(/1/, live).gsub(/0/, dead).split(/\s/)
}

life = LIFE.new('live' => live, 'dead' => dead, 'world' => world)

n = 0

loop do
  system('clear')
  t = Time.new
  life.next
  diff = Time.new - t
  n = n.succ
  puts "#{n}:#{diff}"
  raise "Error: input time is too short => '$time'" if (time - diff < 0)
  sleep time - diff
end
