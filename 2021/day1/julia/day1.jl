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

single_increments = incremented(get_windows(process(get_input("../lib/input.txt")), 2, 1))
trio_increments = incremented(get_windows(process(get_input("../lib/input.txt")), 4, 1))

println(length(single_increments))
println(length(trio_increments))
