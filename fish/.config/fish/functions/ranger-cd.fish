function ranger-cd --wraps=ranger
  set tmpfile (mktemp)
  ranger --choosedir=$tmpfile $argv
  set rpwd (cat $tmpfile)
  rm $tmpfile
  if test "$PWD" != $rpwd
      cd $rpwd
  end
  commandline -f repaint
end
