// TEST: .rs entry — exercises the 'code' render mode (highlight.js, language: rust)

fn fibonacci(n: u32) -> Vec<u64> {
    let mut seq = vec![0u64, 1u64];
    while seq.len() < n as usize {
        let next = seq[seq.len() - 1] + seq[seq.len() - 2];
        seq.push(next);
    }
    seq.truncate(n as usize);
    seq
}

fn main() {
    let seq = fibonacci(10);
    println!("{:?}", seq);
}
