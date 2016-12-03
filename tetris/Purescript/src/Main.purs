module Main where

import App
import Prelude
import Block as Block
import Board as Board
import Cell as Cell
import Control.Monad.Eff.Console as Console
import Control.Monad.Eff.Random as Random
import Data.List.Lazy as LL
import Matrix as Matrix
import Control.Monad.Aff.Console (infoShow)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import GameState (GameState(..))
import GameStats (initial) as GameStats
import Halogen (HalogenEffects, runUI)
import Halogen.Util (awaitBody, runHalogenAff)
import PRNG.Xorshift128
import PRNG.PRNG

initialState = {
  on: false
  , gameState: NotYetStarted
  , blocks: LL.nil
  , gameStats: GameStats.initial
  , gameBoard: Board.Board { cells: Matrix.repeat 10 20 Cell.Free }
  , hintBoard: Board.Board { cells: Matrix.repeat 5 5 Cell.Free }
}

gen :: { value :: Int, state :: Xorshift128 } -> { value :: Int, state :: Xorshift128 }
gen { value, state } = generate state

getAllBlocks :: Eff
  (HalogenEffects(random :: Random.RANDOM, console :: Console.CONSOLE))
  (LL.List Int)
getAllBlocks = do
  seeds <- LL.replicateM 4 (Random.randomInt (-10000000) 100000000)
  pure $ LL.drop 1 $ map (\x -> x.value) $ LL.iterate gen { state: (initialize seeds), value: 0 }

main :: Eff (HalogenEffects (console :: Console.CONSOLE, random :: Random.RANDOM)) Unit
main = do
  blocks <- getAllBlocks
  runHalogenAff do
    body <- awaitBody
    runUI app (initialState {blocks= (map Block.arbitraryBlock blocks)}) body
