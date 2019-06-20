import "./side-effects";
import {
    LocationProvider,
    Router,
    createHistory
} from "@reach/router";
import TournamentIndex, {
    Tournament,
    TournamentList
} from "./pages/tournament";
import NotFound from "./components/404";
import Options from "./pages/options";
import Players from "./pages/players";
import React from "react";
import Splash from "./pages/splash";
import {Window} from "./components/window";
import createHashSource from "hash-source";

// These are needed for deploying to GitHub pages.
const source = createHashSource();
const history = createHistory(source);

function App() {
    return (
        <LocationProvider history={history}>
            <Window className="app">
                <main className="app__main">
                    <Router>
                        <Splash path="/" />
                        <TournamentIndex path="tourneys">
                            <TournamentList path="/" />
                            <Tournament path=":tourneyId/*" />
                        </TournamentIndex>
                        <Players path="players/*" />
                        <Options path="options" />
                        <NotFound default />
                    </Router>
                </main>
            </Window>
        </LocationProvider>
    );
}

export default App;
