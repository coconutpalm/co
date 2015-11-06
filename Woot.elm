module Woot where

import Dict exposing (..)
import Model exposing (..)
import Constants exposing (..)
import String exposing (fromChar)

-- - - - - - - - - - U T I L I T I E S - - - - - - - - - -


wIdOrder : WChar -> WChar -> Order
wIdOrder wA wB =
    let
        (wASite, wAClock) = wA.id
        (wBSite, wBClock) = wB.id
    in
        if 
            |wASite > wBSite -> GT
            |wASite < wBSite -> LT 
            |otherwise -> if wAClock > wBClock then GT else LT


wToString : WString -> String
wToString wStr = 
    case wStr of
        [] -> ""
        x :: xs -> if x.vis > 0 
                    then  String.cons x.ch (wToString xs)
                    else wToString xs


subSeq : WString -> WChar -> WChar -> WString
subSeq wStr start end =
    case wStr of
        [] -> []
        x :: xs -> if x.id == start.id 
                    then subSeqGrab xs end 
                    else subSeq xs start end


subSeqGrab : WString -> WChar -> WString
subSeqGrab wStr end =
    case wStr of
        [] -> []
        x :: xs -> if x.id == end.id 
                    then [] 
                    else x :: subSeqGrab xs end


ithVisible : WString -> Int -> WChar
ithVisible wStr i =
    if i == -1 then startChar else 
        case wStr of
            [] -> endChar
-- error case!
            x :: xs -> if i == 0 then x else ithVisible xs (i - 1)

setInvisible : WString -> WId -> WString
setInvisible wStr id =
    case wStr of
        [] -> []
        x :: xs -> if x.id == id 
                    then {x | vis <- -1} :: xs 
                    else x :: (setInvisible xs id)

pos : WString -> WChar -> Int
pos wStr wCh =
    case wStr of 
        [] -> 0
        x :: xs -> if x.id == wCh.id then 0 else 1 + (pos xs wCh)


    
isVisible : WChar -> Bool
isVisible wCh = wCh.vis > 0 || wCh.id == startId || wCh.id == endId


grabNext : WChar -> WString  -> WChar
grabNext wCh wStr =
    case wStr of
        x :: xs -> if x.id == wCh.next then x else grabNext wCh xs
        [] -> endChar

grabPrev : WChar -> WString -> WChar
grabPrev wCh wStr =
    case wStr of
        x :: xs -> if x.id == wCh.prev then x else grabNext wCh xs
        [] -> startChar


contains : WChar -> Dict WId WChar -> Bool
contains wCh dict = Dict.member wCh.id dict



integratePool : Model -> Model
integratePool model = model

canIns : WChar -> Dict WId WChar -> Bool
canIns wCh dict = Dict.member wCh.next dict && Dict.member wCh.prev dict

canDel : WChar -> Dict WId WChar -> Bool
canDel wCh dict = contains wCh dict

canIntegrate : WUpdate -> Dict WId WChar -> Bool
canIntegrate wUpdate dict =
    case wUpdate of
        Insert wCh -> canIns wCh dict
        Delete wCh -> canDel wCh dict



