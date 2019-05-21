// TODO: Clean this up. Refactor unnecessary functions, etc.
import {
    init,
    last,
    pipe,
    sort,
    sum,
    tail
} from "ramda";
import {firstBy} from "thenby";
import t from "tcomb";
import {
    BLACK,
    DUMMY_ID,
    Match,
    ScoreCalulator,
    WHITE
} from "../data-types";
import {
    getMatchesByPlayer,
    getMatchDetailsForPlayer,
    isNotBye,
    isNotDummy,
    getPlayerScoreList,
    getPlayerScoreListNoByes
} from "./helpers";

/**
 * @returns {typeof WHITE | typeof BLACK?}
 */

export function getDueColor(playerId, matchList) {
    t.Number(playerId);
    t.list(Match)(matchList);
    const lastMatch = last(getMatchesByPlayer(playerId, matchList));
    if (!lastMatch) {
        return null;
    }
    const {color} = getMatchDetailsForPlayer(playerId, lastMatch);
    return (color === WHITE) ? BLACK : WHITE;
}

/**
 * @returns {boolean}
 */
function hasHadBye(playerId, matchList) {
    t.Number(playerId);
    t.list(Match)(matchList);
    return getMatchesByPlayer(
        playerId,
        matchList
    ).reduce(
        (acc, match) => acc.concat(match.players),
        []
    ).includes(DUMMY_ID);
}
export {hasHadBye};

/**
 * @returns {number[]}
 */
export function getPlayersByOpponent(opponentId, matchList) {
    t.Number(opponentId);
    t.list(Match)(matchList);
    return getMatchesByPlayer(
        opponentId,
        matchList
    ).reduce(
        (acc, match) => acc.concat(match.players),
        []
    ).filter(
        (playerId) => playerId !== opponentId
    );
}

/**
 * Used for `modifiedMedian` and `solkoff`.
 * @returns {number[]}
 */
function getOpponentScores(playerId, matchList) {
    t.Number(playerId);
    t.list(Match)(matchList);
    const scores = getPlayersByOpponent(
        playerId,
        matchList
    ).filter(
        isNotDummy
    ).map(
        (opponent) => getPlayerScore(opponent, matchList)
    );
    return scores;
}

/*******************************************************************************
 * The main scoring methods
 ******************************************************************************/
/**
 * @returns {number}
 */
const getPlayerScore = ScoreCalulator.of(
    function (playerId, matchList) {
        const scoreList = getPlayerScoreList(playerId, matchList);
        return sum(scoreList);
    }
);
export {getPlayerScore};

/**
 * The player's cumulative score.
 * @returns {number}
 */
const getCumulativeScore = ScoreCalulator.of(
    function (playerId, matchList) {
        const scoreList = getPlayerScoreListNoByes(
            playerId,
            matchList
        ).reduce( // turn the regular score list into a "running" score list
            (acc, score) => acc.concat([last(acc) + score]),
            [0]
        );
        return sum(scoreList);
    }
);

/**
 * Get the cumulative scores of a player's opponents.
 * @returns {number}
 */
const getCumulativeOfOpponentScore = ScoreCalulator.of(
    function (playerId, matchList) {
        const oppScores = getPlayersByOpponent(
            playerId,
            matchList
        ).filter(
            isNotDummy
        ).map(
            (id) => getCumulativeScore(id, matchList)
        );
        return sum(oppScores);
    }
);

/**
 * Calculate a player's color balance. A negative number means they played as
 * white more. A positive number means they played as black more.
 * @returns {number}
 */
const getColorBalanceScore = ScoreCalulator.of(
    function (playerId, matchList) {
        const colorList = getMatchesByPlayer(
            playerId,
            matchList
        ).filter(
            isNotBye
        ).reduce(
            (acc, match) => (
                (match.players[WHITE] === playerId)
                ? acc.concat(-1) // White = -1
                : acc.concat(1) // Black = +1
            ),
            [0]
        );
        return sum(colorList);
    }
);
export {getColorBalanceScore};

/**
 * Gets the modified median factor defined in USCF § 34E1
 * @returns {number}
 */
const getModifiedMedianScore = ScoreCalulator.of(
    function (playerId, matchList) {
        const scores = getOpponentScores(playerId, matchList);
        return pipe(
            sort((a, b) => a - b),
            init,
            tail,
            sum
        )(scores);
    }
);

/**
 * @returns {number}
 */
const getSolkoffScore = ScoreCalulator.of(
    function (playerId, matchList) {
        const scoreList = getOpponentScores(playerId, matchList);
        return sum(scoreList);
    }
);

const tieBreakMethods = [
    {
        name: "Modified median",
        func: getModifiedMedianScore
    },
    {
        name: "Solkoff",
        func: getSolkoffScore
    },
    {
        name: "Cumulative score",
        func: getCumulativeScore
    },
    {
        name: "Cumulative of opposition",
        func: getCumulativeOfOpponentScore
    },
    {
        name: "Most black",
        func: getColorBalanceScore
    }
];
Object.freeze(tieBreakMethods);
export {tieBreakMethods};

/**
 * Create a function to sort the standings. This dynamically creates a `thenBy`
 * function based on the desired tiebreak sort methods.
 * @returns A function to be used with a list of standings and `sort()`.
 */
export function createTieBreakSorter(tieBreaks) {
    return tieBreaks.reduce(
        (acc, ignore, index) => (
            acc.thenBy(
                (standing1, standing2) => (
                    standing2.tieBreaks[index] - standing1.tieBreaks[index]
                )
            )
        ),
        firstBy((standing1, standing2) => standing2.score - standing1.score)
    );
}
