{-# LANGUAGE RankNTypes #-}
module Lib where

import Data.Maybe (catMaybes)
import Control.Lens.Lens
import Control.Lens.Combinators
import Control.Applicative (Const(..))

someFunc :: IO ()
someFunc = putStrLn "someFunc"

type Puzzle = [[Maybe Int]]

solved :: Puzzle
solved = grouped 4 $ map Just [1..15] ++ [Nothing]

grouped :: Int -> [a] -> [[a]]
grouped _ [] = []
grouped i xs = take i xs : grouped i (drop i xs)

moves :: Puzzle -> [Puzzle]
moves p = catMaybes [left p, right p, up p, down p]

left :: Puzzle -> Maybe Puzzle
left [] = Nothing 
left (row: rows) = 
  case (swap row) of
    Nothing -> fmap (row:) $ left rows 
    Just swapped -> Just (swapped: rows) 
  where
    swap [a] = Nothing
    swap (a: Nothing: as) = Just $ Nothing : a : as
    swap (a: as)  = fmap (a:) $ swap as

right :: Puzzle -> Maybe Puzzle
right (row: rows) = 
  case (swap row) of
    Nothing -> fmap (row:) $ left rows 
    Just swapped -> Just (swapped: rows) 
  where
    swap [a] = Nothing
    swap (Nothing: a: as) = Just $ a : Nothing : as
    swap (a: as)  = fmap (a:) $ swap as

up :: Puzzle -> Maybe Puzzle
up = fmap cols . left . cols

down :: Puzzle -> Maybe Puzzle
down = fmap cols . right . cols

cols [xs] = map (:[]) xs
cols (xs:xss) = zipWith (:) xs (cols xss)

swap :: Lens' s a -> GetterSetter a s s a a -> s -> s
swap l m = set' l . getAndSet' m . view' l where 
  view' l  s = (s, view l s)
  getAndSet' l (s, a) = getAndSet l a s
  set' l (a, s) = set l a s

-- (a -> (c, b)) -> s -> (c, t)
type GetterSetter c s t a b = LensLike ((,) c) s t a b

getAndSet :: GetterSetter a s t a b -> b -> s -> (a,t)
getAndSet l b = l f where
 f a = (a,b)

foldGS :: GetterSetter m s s a a -> Fold s a
foldGS l f = h . l g where
  g a = (unConst (f a), a)
  h f s = i $ f s
  i (m, s) = Const m
    

