// Generated by BUCKLESCRIPT VERSION 6.0.3, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Belt_MapString from "bs-platform/lib/es6/belt_MapString.js";
import * as DemoData$Coronate from "../DemoData.bs.js";
import * as TestData$Coronate from "../TestData.bs.js";

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

function genericDbReducer(state, action) {
  switch (action.tag | 0) {
    case 0 : 
        return Belt_MapString.remove(state, action[0]);
    case 1 : 
        return Belt_MapString.set(state, action[0], action[1]);
    case 2 : 
        return action[0];
    
  }
}

function configReducer(state, action) {
  switch (action.tag | 0) {
    case 0 : 
        return /* record */[
                /* avoidPairs */state[/* avoidPairs */0].concat(/* array */[action[0]]),
                /* byeValue */state[/* byeValue */1],
                /* lastBackup */state[/* lastBackup */2]
              ];
    case 1 : 
        var match = action[0];
        var user2 = match[1];
        var user1 = match[0];
        return /* record */[
                /* avoidPairs */state[/* avoidPairs */0].filter((function (param) {
                        var p2 = param[1];
                        var p1 = param[0];
                        return !(/* array */[
                                    p1,
                                    p2
                                  ].includes(user1) && /* array */[
                                    p1,
                                    p2
                                  ].includes(user2));
                      })),
                /* byeValue */state[/* byeValue */1],
                /* lastBackup */state[/* lastBackup */2]
              ];
    case 2 : 
        var id = action[0];
        return /* record */[
                /* avoidPairs */state[/* avoidPairs */0].filter((function (param) {
                        return !/* array */[
                                  param[0],
                                  param[1]
                                ].includes(id);
                      })),
                /* byeValue */state[/* byeValue */1],
                /* lastBackup */state[/* lastBackup */2]
              ];
    case 3 : 
        return /* record */[
                /* avoidPairs */action[0],
                /* byeValue */state[/* byeValue */1],
                /* lastBackup */state[/* lastBackup */2]
              ];
    case 4 : 
        return /* record */[
                /* avoidPairs */state[/* avoidPairs */0],
                /* byeValue */action[0],
                /* lastBackup */state[/* lastBackup */2]
              ];
    case 5 : 
        return action[0];
    case 6 : 
        return /* record */[
                /* avoidPairs */state[/* avoidPairs */0],
                /* byeValue */state[/* byeValue */1],
                /* lastBackup */action[0]
              ];
    
  }
}

function useAllItemsFromDb(data) {
  return React.useReducer(genericDbReducer, data);
}

function useAllPlayers(param) {
  return React.useReducer(genericDbReducer, playerData);
}

function useAllTournaments(param) {
  return React.useReducer(genericDbReducer, TestData$Coronate.tournaments);
}

function useConfig(param) {
  return React.useReducer(configReducer, configData);
}

export {
  configData ,
  tournamentData ,
  playerData ,
  genericDbReducer ,
  configReducer ,
  useAllItemsFromDb ,
  useAllPlayers ,
  useAllTournaments ,
  useConfig ,
  
}
/* configData Not a pure module */
