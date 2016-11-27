module Help where

import Prelude ((<>))

import Halogen.HTML as H
import Halogen.HTML.Properties as P

helpItemClass :: H.ClassName
helpItemClass = H.className "help-item"

separator :: String
separator = " \8212 "

helpItem :: forall a p. String -> String -> H.HTML a p
helpItem symbol explaination =
  H.li
    [ P.class_ helpItemClass ]
    [ H.text (symbol <> separator <> explaination) ]

render :: forall a p. H.HTML a p
render = H.div [P.id_ "help"] [
    H.h4_ [H.text "Sterowanie: "],
    H.ul [P.id_ "help-items"] [
      helpItem "p" "pauza",
      helpItem "\8594" "przesunięcie bloku w prawo",
      helpItem "\8592" "przesunięcie bloku w lewo",
      helpItem "\8593" "obrót bloku o 90\176 w prawo",
      helpItem "\8595" "przyspiesza spadanie bloku"
    ]
  ]
