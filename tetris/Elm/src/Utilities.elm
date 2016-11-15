module Utilities exposing (delayMessage, asString)

import String exposing (fromChar)
import Char exposing (KeyCode, fromCode)

import Task
import Process
import Time exposing (Time)

delayMessage : a -> Time -> Cmd a
delayMessage msg time = let f = \_ -> msg in
  Task.perform f f (Process.sleep time)

asString : KeyCode -> String
asString key = key |> Char.fromCode |> String.fromChar
