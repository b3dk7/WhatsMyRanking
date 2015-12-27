def find_root(x)
  if !x[8..-1].index("/").nil?
    x[0..x[8..-1].index("/")+7]
  else
    x
  end
end


def url_extention(x)
  if !x[8..-1].index("/").nil?
    x[x[8..-1].index("/")+8..-1]
  else
    x
  end
end



p url_extention("https://macdonals.com/tommy")