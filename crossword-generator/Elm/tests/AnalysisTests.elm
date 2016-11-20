module AnalysisTests exposing (all)

import Analyzer

import Test exposing (..)
import Expect
import Lazy.List as LL


all : Test
all =
  describe "Analysing words and keyword"
    [ test "yields nothing for empty list" <|
        \() -> Expect.equal Nothing <| LL.head <| Analyzer.generateCrossword ([], "A"),
      test "yields list of words and paddings if crossword can be made" <|
        \() -> Expect.equal (Just [("ALA", 1)]) <| LL.head
          (Analyzer.generateCrossword (["ALA"], "L")),
      test "yields list of words and paddings for bigger valid crossword" <|
        \() -> Expect.equal (Just [("ALA", 1), ("PAN", 0)]) <| LL.head
          (Analyzer.generateCrossword (["ALA", "PAN"], "LP")),
      test "yields list of words and paddings 2" <|
        \() -> Expect.equal (Just [("JA", 0), ("KOZICA", 5), ("BAR", 2)]) <| LL.head
          (Analyzer.generateCrossword (["JA", "KOZICA", "BAR"], "JAR")),
      test "yields nothing if crossword cannot be created" <|
        \() -> Expect.equal Nothing <| LL.head (Analyzer.generateCrossword (["ALA"], "G")),
      test "yields nothing if there are less words than keyword length" <|
        \() -> Expect.equal Nothing <| LL.head (Analyzer.generateCrossword (["ALA"], "AS"))
    ]
