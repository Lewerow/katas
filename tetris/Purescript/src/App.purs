module App where

import DOM.HTML.HTMLElement (offsetHeight)
import Data.Foreign.Index (class Index)
import Data.Maybe (Maybe(..), fromJust)
import Halogen (ParentComponentSpec)
import Halogen.HTML.Properties.ARIA (orientation)

import Prelude

import Halogen
import Halogen.HTML.Events.Indexed as E
import Halogen.HTML as H
import Halogen.HTML.Properties as P

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)

import Data.List.Infinite as IL
import GameStats as GameStats
import RestartButton as RestartButton
import GameState as GameState
import Help as Help
import Board as Board
import Block as Block

type State = {gameState :: GameState.GameState
  , gameStats :: GameStats.GameStats
  , blocks :: IL.List (Block.Block)
  , gameBoard :: Board.Board
  , hintBoard :: Board.Board
}

data Query a = Tick a

showMessage :: forall p i. GameState.GameState -> Array (H.HTML p i)
showMessage s = let
  text = H.text if s == GameState.Finished then "Game over" else "" in
    [ H.div_ [ text ] ]

app :: forall g. Component State Query g
app = component { render, eval }
  where
  render :: State -> ComponentHTML Query
  render state =
    H.div [P.id_ "app"] [
        H.div [P.id_ "logo"] [],
        H.div [P.id_ "game-area"] [
          H.div [P.id_ "playground"] [
            H.div [P.id_ "message-container"] $ showMessage state.gameState,
            Board.render "board" state.gameBoard (IL.index state.blocks 0),
            H.div [P.id_ "game-menu"] [
              H.div [P.id_ "metadata"] [
                Board.render "next-block" state.hintBoard (IL.index state.blocks 1),
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
  eval (Tick n) = do
    modify stepDownModifier
    pure n

stepDownModifier :: State -> State
stepDownModifier state = let
  fallingBlock = IL.head state.blocks
  movedBlock = Block.moveDown fallingBlock in
    if Board.fitsIn movedBlock state.gameBoard then
      state { blocks = movedBlock `IL.cons` IL.tail state.blocks }
    else let
      newState = state {
        gameBoard = Board.fix fallingBlock (state.gameBoard)
      } in
      if Board.fitsIn (IL.head newState.blocks) state.gameBoard then
        newState { blocks = IL.tail (state.blocks) }
      else
        newState { gameState = GameState.Finished }
