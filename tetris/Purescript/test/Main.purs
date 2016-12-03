module Test.Main where

import Test.Unit.Main (runTest)
import MersenneTwisterTests as MTT

main = runTest do
  MTT.all
