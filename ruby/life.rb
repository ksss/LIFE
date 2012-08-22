#! /usr/bin/env ruby
# -*- encoding: utf-8 -*-

class LIFE
  def initialize (value)
    @world = value['world'] || value
    @live = value['live'] || '■'
    @dead = value['dead'] || '□'
  end

  def drow
    @world.each do |line|
      puts line.join ' '
    end
  end

  def add
  end

  def next
    size = @world.size

    next_world = Array.new(size) do
      Array.new(size, 0)
    end

    @world.each_with_index do |line, y|
      line.each_with_index do |cell, x|
        if cell == @live
          ys = y == 0 ? 0 : y - 1
          ye = y == size - 1 ? size - 1 : y + 1
          xs = x == 0 ? 0 : x - 1
          xe = x == size - 1 ? size - 1 : x + 1
          (ys..ye).each do |yy|
            (xs..xe).each do |xx|
              next_world[yy][xx] += 1
            end
          end
        end
      end
    end

    next_world.each_with_index do |line, y|
      line.each_with_index do |i, x|
        if i == 3
          @world[y][x] = @live
        elsif i != 4
          @world[y][x] = @dead
        end
      end
      puts @world[y].join ' '
    end
  end
end

live = '■'
dead = '□'
time = (ARGV.shift || 0.1).to_f
world = STDIN.read.split(/\n/).map { |i|
  i.gsub(/1/, live).gsub(/0/, dead).split(/\s/)
}

life = LIFE.new(
  'live' => live,
  'dead' => dead,
  'world' => world
)
system('clear')
life.drow
sleep time
n = 0
loop do
  system('clear')
  t = Time.new
  life.next
  diff = Time.new - t
  n = n.succ
  puts "#{n}:#{diff}"
  raise "Error: input time is too short => '#{time}'" if (time - diff < 0)
  sleep time - diff
end
