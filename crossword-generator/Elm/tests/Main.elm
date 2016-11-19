port module Main exposing (..)

import AnalysisTests
import Test.Runner.Node exposing (run, TestProgram)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit AnalysisTests.all


port emit : ( String, Value ) -> Cmd msg
