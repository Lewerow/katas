module App exposing (..)

import Html as Html

type Model = M ()
type Msg = Msg

main: Program Never Model Msg
main = Html.program {
  init = init,
  view = view,
  update = update,
  subscriptions = subscriptions
  }

subscriptions : Model -> Sub Msg
subscriptions model = Sub.batch
  []

init : (Model, Cmd Msg)
init = (M (), Cmd.none)

update _ _ = (M (), Cmd.none)

view _ = Html.div [] []
