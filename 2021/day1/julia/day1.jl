function get_input(path)
  Base.readlines(path)
end

function process(input)
  collect(Base.Iterators.map(n -> parse(Int64, n), input))
end 

function get_windows(processed, window_size, step)
  ((@view processed[i:i+window_size-1]) for i in 1:step:length(processed) - window_size + step)
end

function incremented(windows)
  collect(Base.Iterators.filter(n -> first(n) < last(n), windows))
end

single_increments = "../lib/input.txt" |> get_input |> process |> p -> get_windows(p, 2, 1) |> incremented

trio_increments = "../lib/input.txt" |> get_input |> process |> p -> get_windows(p, 4, 1) |> incremented

println(length(single_increments))
println(length(trio_increments))

∑Δ(i) = i |> diff .|> >(0) |> sum |> println

input = parse.(Int, readlines("../lib/input.txt"))

windows = [ sum(input[i:i+2]) for i=1:length(input)-2 ]

return [∑Δ(input), ∑Δ(windows)]
