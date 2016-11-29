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

import Data.List.Lazy as LL
import GameStats as GameStats
import RestartButton as RestartButton
import GameState as GameState
import Help as Help
import Board as Board
import Block as Block

type State = {on :: Boolean
  , gameState :: GameState.GameState
  , gameStats :: GameStats.GameStats
  , blocks :: LL.List Block.Block
  , gameBoard :: Board.Board
  , hintBoard :: Board.Board
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
            Board.render "board" state.gameBoard (LL.index state.blocks 1),
            H.div [P.id_ "game-menu"] [
              H.div [P.id_ "metadata"] [
                Board.render "next-block" state.hintBoard (LL.head state.blocks),
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
    modify (\s -> s)
    pure n
  eval (GetState f) = do
    value <- gets _.on
    pure (f value)
