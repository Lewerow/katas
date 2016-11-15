module Stats exposing (Stats, appendStats)

import Config exposing (minStep, maxLevel)

import Time exposing (Time)

type alias Stats = {
  points: Int,
  lines: Int,
  level: Int,
  stepDelay: Time
}

appendStats : Stats -> Int -> Stats
appendStats s1 clearedLines = let
  newLevel = (s1.lines + clearedLines) // maxLevel in
  {
  points=s1.points+clearedLines^2,
  lines=s1.lines+clearedLines,
  level= newLevel,
  stepDelay= if newLevel /= s1.level then calcDelay s1.stepDelay newLevel else s1.stepDelay
  }

calcDelay : Time -> Int -> Time
calcDelay step level =
  if level > maxLevel then 3 * minStep
  else  step * ((3*minStep / step) ^ (1.0 / (toFloat (maxLevel - level + 1))))
