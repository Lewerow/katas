module App exposing (..)

import Tetris
import Rendering
import Html.App as App
import Routing

import PageVisibility
import Keyboard as Keyboard exposing (ups, downs)
import Messages exposing (Msg(..))

main: Program Never
main = App.program {
  init = init,
  view = Rendering.view,
  update = Routing.update,
  subscriptions = subscriptions
  }

subscriptions : Tetris.Model -> Sub Msg
subscriptions model = Sub.batch
  [
    Keyboard.downs KeyDown,
    Keyboard.ups KeyUp,
    PageVisibility.visibilityChanges (\_ -> RequestPause)
  ]

init : (Tetris.Model, Cmd Msg)
init = (Tetris.initialModel, Cmd.none)
