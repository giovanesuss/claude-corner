-- TEST: .lua entry — exercises the 'code' render mode (highlight.js, language: lua)

local function fibonacci(n)
  local seq = {0, 1}
  while #seq < n do
    table.insert(seq, seq[#seq] + seq[#seq - 1])
  end
  return seq
end

local seq = fibonacci(10)
for i, v in ipairs(seq) do
  io.write(v, " ")
end
io.write("\n")
