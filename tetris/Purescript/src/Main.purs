module Main where

import App (app)

import Prelude (Unit, bind)
import Halogen (HalogenEffects, runUI)
import Control.Monad.Eff (Eff)

import Halogen.Util (awaitBody, runHalogenAff)
import GameState
import GameStats (initial) as GameStats

initialState = {
  on: false
  , gameState: NotYetStarted
  , gameStats: GameStats.initial
}

main :: Eff (HalogenEffects ()) Unit
main = runHalogenAff do
  body <- awaitBody
  runUI app initialState body
