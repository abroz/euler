----------------------------------
-- Project Euler problems 11-20 --
----------------------------------

import Control.Monad
import Data.List
import System.IO
import Data.Char

----------------------------------
-- problem 11:


solution11 = getResult "11.txt"
-- 70600674


getResult :: FilePath -> IO Int
getResult fileName = do
    contents <- readFile fileName
    return . hvdMax' $ toGrid contents

toGrid :: String -> [[Int]]
toGrid = map (map read . words) . lines


-- first solution
hvdMax :: [[Int]] -> Int
hvdMax grid = maximum [ h, v, d ]
    where h = hMax 0 grid
          v = vMax 0 grid
          d = dMax 0 grid

hMax, vMax, dMax :: Int -> [[Int]] -> Int
hMax p [] = p
hMax p ( xs : xss )
    | p < p'    = hMax p' xss
    | otherwise = hMax p  xss
    where p'    = gp4 0 xs
vMax p ( as : bs : cs : [] ) = p
vMax p ( as : bs : cs : ds : nss )
    | p < p'    = vMax p' ( bs : cs : ds : nss )
    | otherwise = vMax p  ( bs : cs : ds : nss )
    where p'    = vMaxH 0  [ as, bs, cs, ds ]
dMax p ( as : bs : cs : [] ) = p
dMax p ( as : bs : cs : ds : nss )
    | p < p'    = dMax p' (bs:cs:ds:nss)
    | otherwise = dMax p  ( bs : cs : ds : nss )
    where p'    = dMaxH 0  [ as, bs, cs, ds ]


gp4 :: Int -> [Int] -> Int
gp4 p ( x1 : x2 : x3 : [] ) = p
gp4 p ( x1 : x2 : x3 : x4 : xs )
    | p < p'    = gp4 p' ( x2 : x3 : x4 : xs )
    | otherwise = gp4 p  ( x2 : x3 : x4 : xs )
    where p'    = x1 * x2 * x3 * x4

vMaxH, dMaxH :: Int -> [[Int]] -> Int
vMaxH p [ [], [] , [], [] ] = p
vMaxH p [ a:as, b:bs, c:cs, d:ds ]
    | p < p'    = vMaxH p' [ as, bs, cs, ds ]
    | otherwise = vMaxH p  [ as, bs, cs, ds ]
    where p'    = a * b * c * d
dMaxH p [ a1 : a2 : a3 : []
        , b1 : b2 : b3 : []
        , c1 : c2 : c3 : []
        , d1 : d2 : d3 : []
        ] = p
dMaxH p [ a1 : a2 : a3 : a4 : as
        , b1 : b2 : b3 : b4 : bs
        , c1 : c2 : c3 : c4 : cs
        , d1 : d2 : d3 : d4 : ds
        ]
    | p < p'    = dMaxH p' [ a2 : a3 : a4 : as
                           , b2 : b3 : b4 : bs
                           , c2 : c3 : c4 : cs
                           , d2 : d3 : d4 : ds
                           ]
    | otherwise = dMaxH p  [ a2 : a3 : a4 : as
                           , b2 : b3 : b4 : bs
                           , c2 : c3 : c4 : cs
                           , d2 : d3 : d4 : ds
                           ]
    where p'    = max ( a1 * b2 * c3 * d4 ) ( a4 * b3 * c2 * d1 )


-- a much cleaner solution using transpose, zipWith and drop
myMaximum :: [Int] -> Int
myMaximum [] = 0
myMaximum xs = maximum xs

takeBy :: Int -> [Int] -> [[Int]]
takeBy n = filter ((n==) . length) . map (take n) . tails

maxBy :: Int -> [Int] -> Int
maxBy n = myMaximum . map product . takeBy n

hMax', vMax', ldMax, rdMax :: Int -> [[Int]] -> Int
hMax' n = maximum . map (maxBy n)
vMax' n = hMax' n . transpose
ldMax n = hMax' n . transpose . zipWith drop [0..]
rdMax n = ldMax n . map reverse

hvdMax' :: [[Int]] -> Int
hvdMax' grid = maximum $ map (flip ($ 4) grid) [hMax',vMax',ldMax,rdMax]


----------------------------------
-- problem 12: What is the value of the first triangle number
-- to have over five hundred divisors?


solution12 = triFun 500
-- 76576500


-- pretty good solution
numFactors :: Int -> Int
numFactors n = if m * m == n then 2 * l - 1 else 2 * l
    where m  = floor . sqrt $ fromIntegral n
          l  = length $ [ x | x <- [1..m], rem n x == 0]

triNum :: Int -> Int
triNum n = ((n+1) * n) `div` 2

numTriFacs :: Int -> Int
numTriFacs n
    | even n = (numFactors $ div n 2) * (numFactors (n+1))
    | odd  n = (numFactors $ div (n+1) 2) * (numFactors n)

triFun :: Int -> Int
triFun m = triNum . head $ filter (\n -> m < numTriFacs n) [1..]


----------------------------------
-- problem 13: Get the first ten digits of the sum
-- of fifty 50 digit integers.


solution13 = getFirst10 "13.txt"
-- 2658544435


getFirst10 :: FilePath -> IO Int
getFirst10 fileName = do
    contents <- readFile fileName
    return . (10 `firstDigits`) . sum $ toIntegers contents

firstDigits :: Int -> Integer -> Int
firstDigits n = read . take n . show

toIntegers :: String -> [Integer]
toIntegers = map read . lines


----------------------------------
-- problem 14: Which starting number, under one million,
-- produces the longest Collatz sequence?


solution14 = ronJeremy 1000000 1 (1,1)
-- 837799


ronJeremy :: Int -> Int -> (Int,Int) -> Int
ronJeremy m count (n,l)
    | count >= m = n
    | l < l'     = ronJeremy m (count+1) (count,l')
    | otherwise  = ronJeremy m (count+1) (n,l)
    where l'     = collatzLength count

collatzLength :: Int -> Int
collatzLength = collatzLength' 0

collatzLength' :: Int -> Int -> Int
collatzLength' counter n
    | n < 1  = 0
    | n == 1 = counter + 1
    | even n = collatzLength' (counter + 1) (div n 2)
    | odd  n = collatzLength' (counter + 1) (3*n + 1)


----------------------------------
-- problem 15: How many down-right paths exist through a 20x20 grid?


solution15 = div (fac 40) $ fac 20 * fac 20
    where fac n = product [1..n]
-- 137846528820


----------------------------------
-- problem 16: What is the sum of the digits of the number 2^1000?


solution16 = sum . map digitToInt . show $ 2^1000
-- 1366


----------------------------------
-- problem 17:


solution17 = sum $ map lengthFind [1..1000]
-- 21274


to19 =
    map length ["","one","two","three","four","five"
               ,"six","seven","eight","nine","ten","eleven"
               ,"twelve","thirteen","fourteen","fifteen"
               ,"sixteen","seventeen","eighteen","nineteen"
               ]

tens =
    map length ["","","twenty","thirty","forty","fifty"
               ,"sixty","seventy","eighty","ninety"
               ]

lengthFind :: Int -> Int
lengthFind n
    | n == 1000 = 11
    | n < 20    = to19 !! n
    | n < 100   = tens !! t + to19 !! o
    | test      = to19 !! h + 7
    | n < 1000  = to19 !! h + 10 + lengthFind (n `mod` 100)
    | otherwise = 0
    where o     = n `mod` 10
          t     = (n - o) `mod` 100 `div` 10
          h     = (n - t - o) `mod` 1000 `div` 100
          test  = mod n 100 == 0


----------------------------------
-- problem 18: Find the maximum total from top to bottom of the triangle.


solution18 = getMaxSum "18.txt"


getMaxSum :: FilePath -> IO Int
getMaxSum fileName = do
    contents <- readFile fileName
    return . myMax . triVals . reverse $ toGrid contents

myMax :: [[Int]] -> Int
myMax [ns] = maximum ns
myMax _    = 0

-- takes an upside-down triangle as input
triVals :: [[Int]] -> [[Int]]
triVals [ns]        = [ns]
triVals (as:bs:nss) = triVals $ collapse as bs : nss

collapse :: [Int] -> [Int] -> [Int]
collapse _ []              = []
collapse (x1:x2:xs) (y:ys) = max (x1+y) (x2+y) : collapse (x2:xs) ys


----------------------------------
-- problem 19: How many Sundays fell on the first of the month
-- during the twentieth century (1 Jan 1901 to 31 Dec 2000)?

-- TODO: Ugh.
          

----------------------------------
-- problem 20: Find the sum of the digits in the number 100!


solution20 = sum . map digitToInt . show $ product [1..100]
-- 648


----------------------------------
