module Tetris exposing (..)

import Time exposing (Time, millisecond)
import Keyboard.Keys as Keys exposing (arrowUp, arrowDown, arrowLeft, arrowRight)

import Char exposing (KeyCode)
import Matrix exposing (repeat)

import Block exposing (..)
import Board exposing (BoardState, CellContent(..))
import Stats exposing (Stats)
import BoardOperations exposing (..)
import GameStatus exposing (GameStatus(..))
import Config exposing (minStep)

type PauseStatus = Paused | Running
type alias Status = {game: GameStatus, pause: PauseStatus}

type alias Game = {
  gameBoardState: BoardState,
  hintBoardState: BoardState,
  stats: Stats,
  status: Status,
  fastModeOn: Bool
  }

type alias Model = Game

initialModel : Model
initialModel = {
  gameBoardState= { size={width=15, height=30},
    id="board", defaultCellClass="cell", cells=repeat 15 30 Free,
    activeBlock={block=OBlock,orientation=E,basePoint={x=7,y=0}}},
  hintBoardState={ size={width=5, height=5},
    id="next-block", defaultCellClass="invisible-cell", cells=repeat 5 5 Free,
    activeBlock={block=ZBlock,orientation=E,basePoint={x=2,y=1}}},
  stats={points=0,lines=0,level=1,stepDelay=400 * Time.millisecond },
  status={game=NotStarted,pause=Running}, fastModeOn=False
  }

getDelay : Model -> Time
getDelay model = if model.fastModeOn then minStep else model.stats.stepDelay

handleKeyDown : KeyCode -> Model -> Model
handleKeyDown key model =
  if key == 80 then
    togglePause model
  else if key == arrowDown.keyCode then
    { model | fastModeOn=True}
  else
    { model | gameBoardState = moveBlock key model.gameBoardState }

togglePause : Model -> Model
togglePause m = case m.status.pause of
  Paused ->  {m | status={game=m.status.game, pause=Running}}
  Running -> {m | status={game=m.status.game, pause=Paused}}
