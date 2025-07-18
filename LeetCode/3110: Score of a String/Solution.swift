class Solution {
    func scoreOfString(_ s: String) -> Int {
        let characters = Array(s)
        var score = 0

        for i in 0..<characters.count - 1 {
            let valorAtual = Int(characters[i].asciiValue!)
            let valorProximo = Int(characters[i+1].asciiValue!)
            
            let diferenca = valorAtual - valorProximo
            
            score += abs(diferenca)
        }

        return score
    }
}