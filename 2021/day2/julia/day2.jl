function process(input)
  collect(Iterators.map(l -> Base.split(l) |> a -> (a[1], parse(Int,a[2])), readlines(input)))
end

mutable struct Sub
  x::Int 
  d::Int 
  a::Int 
end 

function travel1(command, sub::Sub ) 
  c = command[1]
  n = command[2]

  if c == "forward" 
    Sub(x: sub.x + n, d: sub.d, a: sub.a)
  elseif c == "down"
    Sub(x: sub.x, d: sub.d + n, a: sub.a)
  elseif c == "up"
    Sub(x: sub.x, d: sub.d - n, a: sub.a)
  else 
    sub
  end
end 

lines = "../input.txt" |> process |> println
# foldl(c -> travel1(c, Sub(0, 0, 0)), lines) |> println
