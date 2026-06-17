# TEST: .py entry — exercises the 'code' render mode (highlight.js, language: python)

def fibonacci(n):
    """Return the first n Fibonacci numbers."""
    seq = [0, 1]
    while len(seq) < n:
        seq.append(seq[-1] + seq[-2])
    return seq[:n]


class Greeter:
    def __init__(self, name):
        self.name = name

    def greet(self):
        return f"Hello, {self.name}! 2 + 2 = {2 + 2}"


if __name__ == "__main__":
    print(fibonacci(10))
    print(Greeter("corner").greet())
