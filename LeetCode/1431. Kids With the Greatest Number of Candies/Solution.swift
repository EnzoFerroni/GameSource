class Solution {
    func kidsWithCandies(_ candies: [Int], _ extraCandies: Int) -> [Bool] {
        let maximoDeDoces = candies.max()!
        var resultado: [Bool] = []

        for docesDaCrianca in candies {
            if docesDaCrianca + extraCandies >= maximoDeDoces {
                resultado.append(true)
            } else {
                resultado.append(false)
            }
        }

        return resultado
    }
}