module Routing exposing (update)

import Tetris exposing (..)
import Messages exposing (..)
import Keyboard.Keys as Keys exposing (arrowDown)

import GameStatus exposing (GameStatus(..))
import Stats exposing (appendStats)

import Utilities exposing (delayMessage)
import BoardOperations exposing (..)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  TickMove ->
    if model.status.game == Finished then (model, Cmd.none)
    else if model.status.pause == Paused  then (model, delayMessage TickMove (getDelay model))
    else executeTurn model
  KeyDown key -> (handleKeyDown key model, Cmd.none)
  KeyUp key -> ( if key == arrowDown.keyCode then { model | fastModeOn=False} else model, Cmd.none)
  RequestPause -> (if model.status.game == Ongoing then {model | status={game=model.status.game, pause=Paused}} else model,
      Cmd.none)
  Restart -> let
    (commands, gameBoard) = fetchNextBlock initialModel.hintBoardState initialModel.gameBoardState in
    ({initialModel | status={pause=Running, game=Ongoing}, gameBoardState=gameBoard},
      Cmd.batch [generateNewBlock SkipBlock, commands])
  SkipBlock block -> let
    (commands, gameBoard) = fetchNextBlock model.hintBoardState model.gameBoardState
    hintedBoard = hintNextBlock model.hintBoardState block
    in
      ({ model | hintBoardState=hintedBoard, gameBoardState=gameBoard },
      delayMessage TickMove (getDelay initialModel))
  NextBlock block -> ({model | hintBoardState=hintNextBlock model.hintBoardState block}, Cmd.none)


executeTurn : Model -> (Model, Cmd Msg)
executeTurn model =
  if isMovable Down model.gameBoardState then
    ({model | gameBoardState = moveBlockInDirection Down model.gameBoardState}, delayMessage TickMove (getDelay model))
  else let
    (clearedLines, gameBoard) = fixBlock model.gameBoardState
    (command, newGameBoardState) = fetchNextBlock model.hintBoardState gameBoard
    in
  if isValidActiveBlock newGameBoardState.activeBlock newGameBoardState.cells then
    ({ model | gameBoardState=newGameBoardState,
      stats = appendStats model.stats clearedLines }, Cmd.batch [command, delayMessage TickMove (getDelay model)])
  else
    ({model | gameBoardState=newGameBoardState,
        stats = appendStats model.stats clearedLines,
        status = { pause= model.status.pause, game=Finished }
    }, Cmd.none)
