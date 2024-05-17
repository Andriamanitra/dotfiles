#!/usr/bin/env ruby
class Db
  def self.[](*args)
    Db.new(args)
  end

  def initialize(paths)
    @paths = paths.to_a
  end

  def add(path)
    @paths.push(path)
  end

  def find_fuzzy(args)
    @paths.find do |path|
      args.all?{ |arg| path.include?(arg) }
    end
  end

  def find(arg)
    @paths.find do |path|
      File.basename(path).include?(arg)
    end
  end
end

PATHS = DATA.read.split.map do |path|
  File.expand_path(path)
end
@db = Db[*PATHS, $0]

def go(args)
  case args
  in ["--add", *paths]
    File.open($0, "a") do |f|
      f.puts(paths)
    end
    abort("wrote to db")
  in []
    abort("usage: g.rb ARG..")
  in [arg]
    if File.exist?(arg)
      arg
    else
      @db.find(arg) || abort("'#{arg}' not found")
    end
  else
    @db.find_fuzzy(args) || abort("no path in db matches #{args}")
  end
end

puts go(ARGV)

__END__
~/.config/fish
