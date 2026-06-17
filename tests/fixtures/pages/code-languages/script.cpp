// TEST: .cpp entry — exercises the 'code' render mode (highlight.js, language: cpp)

#include <iostream>
#include <vector>

std::vector<int> fibonacci(int n) {
    std::vector<int> seq = {0, 1};
    while (static_cast<int>(seq.size()) < n) {
        seq.push_back(seq[seq.size() - 1] + seq[seq.size() - 2]);
    }
    seq.resize(n);
    return seq;
}

int main() {
    for (int v : fibonacci(10)) {
        std::cout << v << " ";
    }
    std::cout << std::endl;
    return 0;
}
