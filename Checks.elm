module Checks where
import Graphics.Element exposing (..)
import Check exposing (..)
import Check.Investigator exposing (..)
import DraftTests exposing (makeEmptySite)
import Woot exposing (wToString)
import Editor exposing (insertString, processEdits)
import String exposing (toList, length)
import Char exposing (toCode)
import Html exposing (Html, Attribute, div, text, ul, ol, li)

first_index = 0 
generatePseudoRandomIndex : String -> String -> Int
generatePseudoRandomIndex origStr insertStr =
  case toList insertStr of
    ch :: chars -> if length origStr == 0 then 0 else (toCode ch) % (length origStr)
    [] -> 0



claim_insert_string = 
  claim
  "Can insert a string and get same string"
  `that`
    (\ str -> 
        let
          (model, edit) =  insertString str first_index (makeEmptySite 1)
        in 
            wToString model.wString)
  `is`
      (identity)
  `for`
      string

insert_order_irrelevant =
    claim
      "remote site gets same as local"
    `that`
      (\ str ->
        let
            (localModel, lEdits) = insertString str first_index (makeEmptySite 1)
            (remoteModel, rEdits) = processEdits (lEdits) (makeEmptySite 1)
        in
            wToString remoteModel.wString 
        )
    `is`
        (identity)
    `for`
        string


concurrent_insert_consistent' = (\ origStr localStr remoteStr  ->
        let
          (localModel1, lEdits1) = insertString origStr first_index (makeEmptySite 1)
          (remoteModel1, rEdits1) = processEdits lEdits1 (makeEmptySite 2)
          rIndex = generatePseudoRandomIndex origStr remoteStr
          lIndex = generatePseudoRandomIndex origStr localStr
          (localModel2, lEdits2) = insertString localStr lIndex localModel1
          (remoteModel2, rEdits2) = insertString remoteStr rIndex remoteModel1
          (localModel3, lEdits3) = processEdits rEdits2 localModel2
          (remoteModel3, rEdits3) = processEdits lEdits2 remoteModel2
        in
          (wToString remoteModel3.wString, wToString localModel3.wString))



concurrent_insert_consistent =
  claim 
    "two people write at same time, same result"
    `that`
        (\ (origStr, (localStr, remoteStr)) ->
            fst (concurrent_insert_consistent' origStr localStr remoteStr)
          )
      `is`
        (\ (origStr, (localStr, remoteStr)) ->
            snd (concurrent_insert_consistent' origStr localStr remoteStr)
          )
        `for`
          tuple (string, (tuple (string, string)))


suite_co = 
  suite "Collab Editing Suite"
  [claim_insert_string
  , insert_order_irrelevant
 , concurrent_insert_consistent
    ]



tripleStrings = [("footbol", "how", "are"), ("what", "is", "love"), ("home", "cake", "twelve")]


runTests = List.map (\ (origStr, localStr, remoteStr) -> 
          concurrent_insert_consistent' origStr localStr remoteStr)
           tripleStrings


result = quickCheck suite_co

main =  show result

