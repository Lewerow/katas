module RestartButton where

import Prelude ((/=))

import Halogen.HTML as H
import Halogen.HTML.Properties as P

import GameState

render :: forall p i. GameState -> H.HTML p i
render gs = H.button [P.id_ "restart", P.disabled (gs /= NotYetStarted)]
 [H.text "Start"]
