// Generated by BUCKLESCRIPT VERSION 5.0.6, PLEASE EDIT WITH CARE

import * as Curry from "bs-platform/lib/es6/curry.js";
import * as React from "react";
import * as Data$Coronate from "../../Data.bs.js";
import * as Belt_MapString from "bs-platform/lib/es6/belt_MapString.js";
import * as DemoData$Coronate from "../../DemoData.bs.js";
import * as TestData$Coronate from "../../TestData.bs.js";
import * as TournamentDataReducers$Coronate from "../TournamentDataReducers.bs.js";

function log2(num) {
  return Math.log(num) / Math.log(2.0);
}

var configData_000 = /* avoidPairs */TestData$Coronate.config[/* avoidPairs */0].concat(DemoData$Coronate.config[/* avoidPairs */0]);

var configData_001 = /* byeValue */TestData$Coronate.config[/* byeValue */1];

var configData_002 = /* lastBackup */TestData$Coronate.config[/* lastBackup */2];

var configData = /* record */[
  configData_000,
  configData_001,
  configData_002
];

var tournamentData = Belt_MapString.merge(TestData$Coronate.tournaments, DemoData$Coronate.tournaments, (function (param, param$1, a) {
        return a;
      }));

var playerData = Belt_MapString.merge(TestData$Coronate.players, DemoData$Coronate.players, (function (param, param$1, a) {
        return a;
      }));

function calcNumOfRounds(playerCount) {
  var roundCount = Math.ceil(log2(playerCount));
  var match = roundCount !== Number.NEGATIVE_INFINITY;
  if (match) {
    return roundCount | 0;
  } else {
    return 0;
  }
}

function TournamentData_Mock(Props) {
  var children = Props.children;
  var tourneyId = Props.tourneyId;
  var match = React.useReducer(TournamentDataReducers$Coronate.tournamentReducer, Belt_MapString.getExn(tournamentData, tourneyId));
  var tourney = match[0];
  var roundList = tourney[/* roundList */5];
  var match$1 = React.useReducer(TournamentDataReducers$Coronate.playersReducer, Belt_MapString.keep(playerData, (function (id, param) {
              return tourney[/* playerIds */4].includes(id);
            })));
  var players = match$1[0];
  var partial_arg = Data$Coronate.Player[/* getPlayerMaybeMap */6];
  var getPlayer = function (param) {
    return partial_arg(players, param);
  };
  var activePlayers = Belt_MapString.reduce(players, Belt_MapString.empty, (function (acc, key, player) {
          if (tourney[/* playerIds */4].includes(key)) {
            return Belt_MapString.set(acc, key, player);
          } else {
            return acc;
          }
        }));
  var roundCount = calcNumOfRounds(Belt_MapString.size(activePlayers));
  var isItOver = roundList.length >= roundCount;
  var match$2 = roundList.length === 0;
  var isNewRoundReady = match$2 ? true : Data$Coronate.isRoundComplete(roundList, activePlayers, roundList.length - 1 | 0);
  return Curry._1(children, /* record */[
              /* activePlayers */activePlayers,
              /* getPlayer */getPlayer,
              /* isItOver */isItOver,
              /* isNewRoundReady */isNewRoundReady,
              /* players */players,
              /* playersDispatch */match$1[1],
              /* roundCount */roundCount,
              /* tourney */tourney,
              /* tourneyDispatch */match[1]
            ]);
}

var make = TournamentData_Mock;

export {
  log2 ,
  configData ,
  tournamentData ,
  playerData ,
  calcNumOfRounds ,
  make ,
  
}
/* configData Not a pure module */
