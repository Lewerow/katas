module Config exposing (minStep, maxLevel)

import Time exposing (Time, millisecond)

minStep : Time
minStep = 25 * Time.millisecond

maxLevel : Int
maxLevel = 10
