module Messages exposing (..)

import Block exposing (Block, Orientation)
import Char exposing (KeyCode)

type Msg = TickMove |
  KeyDown KeyCode |
  KeyUp KeyCode |
  Restart |
  RequestPause |
  SkipBlock (Block, Orientation) |
  NextBlock (Block, Orientation)
