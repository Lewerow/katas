module App where

import DOM.HTML.HTMLElement (offsetHeight)
import Data.Maybe (Maybe(..))
import Halogen (ParentComponentSpec)

import Prelude

import Halogen
import Halogen.HTML.Events.Indexed as E
import Halogen.HTML as H
import Halogen.HTML.Properties as P

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)

import GameStats as GameStats
import RestartButton as RestartButton
import GameState as GameState
import Help as Help

type State = { on :: Boolean
  , gameState :: GameState.GameState
  , gameStats :: GameStats.GameStats
}
data Query a = ToggleState a | GetState (Boolean -> a)

app :: forall g. Component State Query g
app = component { render, eval }
  where
  render :: State -> ComponentHTML Query
  render state =
    H.div [P.id_ "app"] [
        H.div [P.id_ "logo"] [],
        H.div [P.id_ "game-area"] [
          H.div [P.id_ "playground"] [
            H.div [P.id_ "message-container"] [
              H.div [P.id_ "message"] []
            ],
            H.div [P.id_ "board"] (renderBoard state),
            H.div [P.id_ "game-menu"] [
              H.div [P.id_ "metadata"] [
                H.div [P.id_ "next-block"] (renderNextBlock state),
                H.div [P.id_ "restart-container"] [
                  RestartButton.render state.gameState
                ],
                GameStats.render state.gameStats
              ],
              Help.render
            ]
          ]
        ]
      ]

  eval :: Query ~> ComponentDSL State Query g
  eval (ToggleState n) = do
    modify (\s -> s { on = not s.on })
    pure n
  eval (GetState f) = do
    value <- gets _.on
    pure (f value)

renderBoard state = [H.div [P.class_ (H.className "cell")] [] ]
renderNextBlock state = [H.div [P.class_ (H.className "cell")] [] ]
