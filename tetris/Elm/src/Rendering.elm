module Rendering exposing (view)

import Tetris exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)

import Messages exposing (Msg(..))
import Matrix exposing (get)
import GameStatus exposing (GameStatus(..))

import Block exposing (..)
import Board exposing (BoardState, RowId, ColumnId, CellContent(..), ClassName)

import Utilities exposing (asString)

view : Model -> Html Msg
view model = div [] [ logo, renderGameBoard model]

logo : Html Msg
logo = div [] []

renderGameBoard : Model -> Html Msg
renderGameBoard model = div [ id "game-area" ] [
  div [ id "playground" ] [
    renderMessage model.status,
    renderBoard model.gameBoardState,
    renderGameMenu model
    ]
  ]

renderMessage : Status -> Html Msg
renderMessage status = div [ id "message-container" ] [ status |> getStatusText |> text ]

getStatusText : Status -> String
getStatusText s = case s.game of
  Finished -> "Game over"
  NotStarted -> ""
  _ -> case s.pause of
    Paused -> "Pauza"
    _ -> ""

renderBoard : BoardState -> Html Msg
renderBoard boardState = div [ id boardState.id ]
  <| List.map (renderRow boardState) [0..boardState.size.height-1]

renderRow : BoardState -> RowId -> Html Msg
renderRow boardState rowId = div [ class "row" ]
  <| List.map (\colId -> renderCell boardState rowId colId) [0..boardState.size.width-1]

renderCell : BoardState -> RowId -> ColumnId -> Html Msg
renderCell boardState rowId columnId =
  div [ getClasses boardState rowId columnId |> classList ] []

getClasses : BoardState -> RowId -> ColumnId -> List (String, Bool)
getClasses boardState rowId columnId =
  case get columnId rowId boardState.cells of
    Nothing -> [("error", True), (boardState.defaultCellClass, True)]
    Just cellState -> case cellState of
      Free -> [(boardState.defaultCellClass, True)]
      Moving b -> [(boardState.defaultCellClass, True),
        ("block", True),
        (getBlockClass b,True)]
      Fixed b -> [(boardState.defaultCellClass, True),
        ("final", True),
        ("block", True),
        (getBlockClass b,True)]

getBlockClass : Block -> ClassName
getBlockClass b = case b of
  IBlock -> "I-block"
  LBlock -> "L-block"
  FBlock -> "F-block"
  HBlock -> "H-block"
  ZBlock -> "Z-block"
  SBlock -> "S-block"
  OBlock -> "O-block"

renderGameMenu : Model -> Html Msg
renderGameMenu model = div [ id "game-menu" ] [
  renderMetadata model,
  renderHelp model
  ]

renderMetadata : Model -> Html Msg
renderMetadata model = div [ id "metadata" ] [
  renderNextBlock model,
  renderRestartButton model,
  renderStats model
 ]

renderNextBlock : Model -> Html Msg
renderNextBlock model = renderBoard model.hintBoardState

renderRestartButton : Model -> Html Msg
renderRestartButton model = div [ id "restart-container" ]
  [ button [ id "restart", onClick Restart, disabled <| model.status.game == Ongoing ]
    [ text <| if model.status.game == NotStarted then "Start" else "Restart" ]
  ]

renderStats : Model -> Html Msg
renderStats model = div [ id "stats" ] [
  renderItemContainer "points" "Punkty: " model.stats.points,
  renderItemContainer "lines" "Linie: " model.stats.lines,
  renderItemContainer "level" "Poziom: " model.stats.level
  ]

renderItemContainer : String -> String -> Int -> Html Msg
renderItemContainer containee textVal value = div
  [ id (containee ++ "-container")]
  [ text textVal, span [ id containee ] [ value |> toString |> text ] ]

renderHelp : Model -> Html Msg
renderHelp model = div [ id "help" ] [
  h4 [] [text "Sterowanie: ",
    ul [ id "help-items"] [
        li [class "help-item"] [ text <| "p " ++ (asString 8212) ++ " pauza"],
        li [class "help-item"] [ text <| (asString 8594)++ " " ++ (asString 8212)
          ++ " przesunięcie bloku w prawo"],
        li [class "help-item"] [ text <| (asString 8592) ++ " " ++ (asString 8212)
          ++ " przesunięcie bloku w lewo"],
        li [class "help-item"] [ text <|  (asString 8593) ++ " "
          ++ (asString 8212) ++ " obrót bloku o 90" ++ (asString 176)
          ++ " w prawo"],
        li [class "help-item"] [ text <| (asString 8595) ++ " "
          ++ (asString 8212) ++ " przyspiesza spadanie bloku"]
      ]
    ]
  ]
