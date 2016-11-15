module BlockData exposing (getMask, nextOrientation)

import Block exposing (..)

getMask : Block -> Orientation -> List Point
getMask block orientation = let pt x y = {x=x,y=y} in
  case block of
  OBlock -> [{x=0,y=0},{x=1,y=0},{x=1,y=1},{x=0,y=1}]
  IBlock -> let
    vertical = [pt -1 0, pt 0 0, pt 1 0, pt 2 0]
    horizontal = [pt 0 -1, pt 0 0, pt 0 1, pt 0 2] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
  LBlock -> case orientation of
    N -> [pt 0 0, pt -1 0, pt -1 1, pt -1 2]
    E -> [pt -2 0, pt -2 1, pt -1 1, pt 0 1]
    S -> [pt 0 0, pt 0 1, pt 0 2, pt -1 2]
    W -> [pt -2 0, pt -1 0, pt 0 0, pt 0 1]
  FBlock -> case orientation of
    N -> [pt -1 0, pt 0 0, pt 0 1, pt 0 2]
    E -> [pt 0 0, pt -1 0, pt -2 0, pt -2 1]
    S -> [pt -1 0, pt -1 1, pt -1 2, pt 0 2]
    W -> [pt 0 0, pt 0 1, pt -1 1, pt -2 1]
  HBlock -> case orientation of
    N -> [pt -1 0, pt 0 0, pt 1 0, pt 0 1]
    E -> [pt 0 -1, pt 0 0, pt 0 1, pt 1 0]
    S -> [pt -1 0, pt 0 0, pt 1 0, pt 0 -1]
    W -> [pt 0 -1, pt 0 0, pt 0 1, pt -1 0]
  ZBlock -> let
    vertical = [pt 0 0, pt 0 1, pt 1 1, pt 1 2]
    horizontal = [pt 1 0, pt 0 0, pt 0 1, pt -1 1] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal
  SBlock -> let
    vertical = [pt 1 0, pt 1 1, pt 0 1, pt 0 2]
    horizontal = [pt -1 0, pt 0 0, pt 0 1, pt 1 1] in
    case orientation of
      N -> vertical
      S -> vertical
      E -> horizontal
      W -> horizontal

nextOrientation : Orientation -> Orientation
nextOrientation o = case o of
  W -> S
  N -> W
  E -> N
  S -> E
