module GameStats where

import Prelude (class Eq, show)

import Halogen.HTML as H
import Halogen.HTML.Properties as P

data GameStats = GameStats {
  level :: Int
  , points :: Int
  , lines :: Int
}

derive instance eqGameStats :: Eq GameStats

initial :: GameStats
initial = GameStats {
  level: 1,
  points: 0,
  lines: 0
}

render :: forall p i. GameStats -> H.HTML p i
render (GameStats { level, points, lines }) = H.div [P.id_ "game-stats"] [
  H.div [P.id_ "points-container"] [
    H.text "Punkty: ", H.span [P.id_ "points"] [ H.text (show points) ]
  ],
  H.div [P.id_ "line-container"] [
    H.text "Linie: ", H.span [P.id_ "lines"] [ H.text (show lines) ]
  ],
  H.div [P.id_ "level-container"] [
    H.text "Poziom: ", H.span [P.id_ "level"] [ H.text (show level) ]
  ]
]
