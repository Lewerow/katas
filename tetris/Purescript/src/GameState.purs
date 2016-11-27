module GameState where

import Prelude (class Eq)

data GameState = NotYetStarted | Ongoing | Finished
derive instance eqGameState :: Eq GameState
