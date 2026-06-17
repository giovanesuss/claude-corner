# TEST: .r entry — exercises the 'code' render mode (highlight.js, language: r)

fibonacci <- function(n) {
  seq <- c(0, 1)
  while (length(seq) < n) {
    seq <- c(seq, seq[length(seq)] + seq[length(seq) - 1])
  }
  seq[1:n]
}

result <- fibonacci(10)
print(result)
cat("Mean:", mean(result), "\n")
