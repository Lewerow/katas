module Main where

import App

import Control.Monad.Eff.Random as Random
import Prelude (Unit, bind, (>>=), ($), pure)
import Halogen (HalogenEffects, runUI)
import Control.Monad.Eff (Eff)

import Control.Monad.Eff.Console as Console
import Control.Monad.Eff.Class (liftEff)

import Halogen.Util (awaitBody, runHalogenAff)
import GameState (GameState(..))
import GameStats (initial) as GameStats
import Data.List.Lazy as LL
import Board as Board
import Matrix as Matrix
import Cell as Cell

initialState = {
  on: false
  , gameState: NotYetStarted
  , gameStats: GameStats.initial
  , blocks: LL.nil
  , gameBoard: Board.Board { cells: Matrix.repeat 10 20 Cell.Free }
  , hintBoard: Board.Board { cells: Matrix.repeat 5 5 Cell.Fixed }
}

main :: Eff (HalogenEffects (console :: Console.CONSOLE, random :: Random.RANDOM)) Unit
main = do
  n <- LL.replicateM  (Random.randomInt 1 50)
  runHalogenAff do
    body <- awaitBody
    runUI app initialState body
