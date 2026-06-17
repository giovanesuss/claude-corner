// TEST: .go entry — exercises the 'code' render mode (highlight.js, language: go)

package main

import "fmt"

func fibonacci(n int) []int {
	seq := []int{0, 1}
	for len(seq) < n {
		seq = append(seq, seq[len(seq)-1]+seq[len(seq)-2])
	}
	return seq[:n]
}

func main() {
	fmt.Println(fibonacci(10))
}
