/*
  Copyright (c) 2022 John Jackson.

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/
open Data
open Belt
module Id = Data.Id

let sortFirstName = Hooks.GetString((. p) => p.Player.firstName)
let sortLastName = Hooks.GetString((. p) => p.Player.lastName)

module Selecting = {
  @react.component
  let make = (~tourney: Tournament.t, ~setTourney, ~players, ~playersDispatch) => {
    let {playerIds, _} = tourney
    let (table, tableDispatch) = Hooks.useSortedTable(
      ~table=Map.valuesToArray(players),
      ~column=sortFirstName,
      ~isDescending=false,
    )
    let togglePlayer = event => {
      let id = ReactEvent.Form.target(event)["value"]
      if ReactEvent.Form.target(event)["checked"] {
        setTourney({...tourney, playerIds: Set.add(playerIds, id)})
      } else {
        setTourney({
          ...tourney,
          playerIds: Set.keep(playerIds, pId => !Id.eq(pId, id)),
        })
      }
    }

    <div>
      <div className="toolbar">
        <button
          className="button-micro"
          onClick={_ =>
            setTourney({
              ...tourney,
              playerIds: players->Map.keysToArray->Set.fromArray(~id=Id.id),
            })}>
          {React.string("Select all")}
        </button>
        <button
          className="button-micro"
          onClick={_ => setTourney({...tourney, playerIds: Set.make(~id=Id.id)})}>
          {React.string("Select none")}
        </button>
      </div>
      <table>
        <caption> {React.string("Select players")} </caption>
        <thead>
          <tr>
            <th>
              <Hooks.SortButton sortColumn=sortFirstName data=table dispatch=tableDispatch>
                {React.string("First name")}
              </Hooks.SortButton>
            </th>
            <th>
              <Hooks.SortButton sortColumn=sortLastName data=table dispatch=tableDispatch>
                {React.string("Last name")}
              </Hooks.SortButton>
            </th>
            <th> {React.string("Select")} </th>
          </tr>
        </thead>
        <tbody>
          {table.table
          ->Array.map(({Player.id: id, firstName, lastName, _}) =>
            <tr key={id->Data.Id.toString}>
              <td> {React.string(firstName)} </td>
              <td> {React.string(lastName)} </td>
              <td>
                <Externals.VisuallyHidden>
                  <label htmlFor={"select-" ++ id->Data.Id.toString}>
                    {`Select ${firstName} ${lastName}`->React.string}
                  </label>
                </Externals.VisuallyHidden>
                <input
                  checked={Set.has(playerIds, id)}
                  type_="checkbox"
                  value={id->Data.Id.toString}
                  id={"select-" ++ id->Data.Id.toString}
                  onChange=togglePlayer
                />
              </td>
            </tr>
          )
          ->React.array}
        </tbody>
      </table>
      <PagePlayers.NewPlayerForm
        dispatch=playersDispatch
        addPlayerCallback={id => setTourney({...tourney, playerIds: Set.add(playerIds, id)})}
      />
    </div>
  }
}

let hasHadBye = (matches, playerId) =>
  matches
  ->MutableQueue.toArray
  ->Array.keep((match: Match.t) => Id.eq(match.whiteId, playerId) || Id.eq(match.blackId, playerId))
  ->Array.some(match => Id.isDummy(match.whiteId) || Id.isDummy(match.blackId))

module OptionsForm = {
  let errorNotification = x =>
    switch x {
    | Some(Error(e)) => <Utils.Notification kind=Error> {e->React.string} </Utils.Notification>
    | Some(Ok(_))
    | None => React.null
    }

  /**
   * This module is a heavily-modified version of code that was generated by the
   * re-formality PPX. Much of the original code has been removed or edited, but
   * the basic outline and the types are mostly the same.
   *
   * It probably needs to be replaced by something better.
   */
  module Form = {
    module FormHelper = Utils.FormHelper
    module Input = {
      type t = {scoreAdjustment: string}
    }
    module Output = {
      type t = {scoreAdjustment: float}
    }
    module FieldStatuses = {
      type t = {scoreAdjustment: FormHelper.fieldStatus<float>}
      let initial = {scoreAdjustment: Pristine}
    }
    module Validators = {
      let scoreAdjustment = scoreAdjustment =>
        switch Float.fromString(scoreAdjustment) {
        | None => Error("Score adjustment must be a number.")
        | Some(x) => Ok(x)
        }
    }
    type action =
      | UpdateScoreAdjustmentField(string)
      | BlurScoreAdjustmentField
      | Submit(Output.t => unit)
      | Reset

    let initialState = input => {
      FormHelper.input,
      fieldStatuses: FieldStatuses.initial,
      formStatus: Editing,
    }

    let validateForm = ({FormHelper.input: input, fieldStatuses, _}) => {
      let scoreAdjustmentResult = switch fieldStatuses.FieldStatuses.scoreAdjustment {
      | Pristine => Validators.scoreAdjustment(input.Input.scoreAdjustment)
      | Dirty(result) => result
      }
      switch scoreAdjustmentResult {
      | Ok(scoreAdjustment) =>
        FormHelper.Valid({
          output: {Output.scoreAdjustment: scoreAdjustment},
          fieldStatuses: {FieldStatuses.scoreAdjustment: Dirty(scoreAdjustmentResult)},
        })
      | Error(_) =>
        Invalid({
          fieldStatuses: {scoreAdjustment: Dirty(scoreAdjustmentResult)},
        })
      }
    }

    type t = {state: FormHelper.state<Input.t, Output.t, FieldStatuses.t>, dispatch: action => unit}

    let useForm = initialInput => {
      let memoizedInitialState = React.useMemo1(() => initialState(initialInput), [initialInput])
      let (state, dispatch) = React.useReducer((state, action) =>
        switch action {
        | UpdateScoreAdjustmentField(nextValue) => {
            ...state,
            FormHelper.input: {Input.scoreAdjustment: nextValue},
            fieldStatuses: {
              FieldStatuses.scoreAdjustment: Dirty(Validators.scoreAdjustment(nextValue)),
            },
          }
        | BlurScoreAdjustmentField =>
          let result = FormHelper.validateFieldOnBlurWithValidator(
            ~input=state.input.scoreAdjustment,
            ~fieldStatus=state.fieldStatuses.scoreAdjustment,
            ~validator=Validators.scoreAdjustment,
          )
          switch result {
          | Some(scoreAdjustment) => {...state, fieldStatuses: {scoreAdjustment: scoreAdjustment}}
          | None => state
          }
        | Submit(onSubmit) =>
          switch state.formStatus {
          | Submitting(_) => state
          | Editing =>
            switch validateForm(state) {
            | Valid({output, fieldStatuses}) => {
                ...state,
                fieldStatuses,
                formStatus: Submitting(output, onSubmit),
              }
            | Invalid({fieldStatuses}) => {...state, fieldStatuses, formStatus: Editing}
            }
          }
        | Reset => initialState(initialInput)
        }
      , memoizedInitialState)
      React.useEffect1(() => {
        switch state.formStatus {
        | Submitting(output, onSubmit) =>
          onSubmit(output)
          dispatch(Reset)
        | Editing => ()
        }
        None
      }, [state.formStatus])
      {state, dispatch}
    }

    let updateScoreAdjustment = ({dispatch, _}, nextValue) =>
      UpdateScoreAdjustmentField(nextValue)->dispatch
    let blurScoreAdjustment = ({dispatch, _}) => BlurScoreAdjustmentField->dispatch
    let scoreAdjustmentResult = ({state, _}) =>
      FormHelper.exposeFieldResult(state.fieldStatuses.scoreAdjustment)
    let input = ({state, _}) => state.input
    let valid = ({state, _}) =>
      switch validateForm(state) {
      | Valid(_) => true
      | Invalid(_) => false
      }
    let submitting = ({state, _}) =>
      switch state.formStatus {
      | Submitting(_) => true
      | Editing => false
      }
    let submit = ({dispatch, _}, fn) => Submit(fn)->dispatch
  }

  module More = {
    @react.component
    let make = (
      ~setTourney,
      ~dialog: Hooks.boolState,
      ~tourney: Data.Tournament.t,
      ~p: Data.Player.t,
    ) => {
      let scoreAdjustment =
        Map.get(tourney.scoreAdjustments, p.id)->Option.mapWithDefault("0", Float.toString)
      let form = Form.useForm({scoreAdjustment: scoreAdjustment})
      <>
        <button className="button-micro button-primary" onClick={_ => dialog.setFalse()}>
          {React.string("close")}
        </button>
        <h2> {`Options for ${Player.fullName(p)}`->React.string} </h2>
        <form
          onSubmit={event => {
            ReactEvent.Form.preventDefault(event)
            Form.submit(form, output => {
              switch output {
              | {scoreAdjustment: 0.} =>
                setTourney({
                  ...tourney,
                  scoreAdjustments: Map.remove(tourney.scoreAdjustments, p.id),
                })
              | {scoreAdjustment} =>
                setTourney({
                  ...tourney,
                  scoreAdjustments: Map.set(tourney.scoreAdjustments, p.id, scoreAdjustment),
                })
              }
              dialog.setFalse()
            })
          }}>
          <h3>
            <label className="title-30" htmlFor={Data.Id.toString(p.id) ++ "-scoreAdjustment"}>
              {"Score adjustment"->React.string}
            </label>
          </h3>
          <p className="caption-30" id={Data.Id.toString(p.id) ++ "-scoreAdjustment-description"}>
            {`Score adjustment will be added to this player's actual score.
              It can be negative.`->React.string}
          </p>
          <p>
            <input
              type_="number"
              size=3
              step=0.5
              id={Data.Id.toString(p.id) ++ "-scoreAdjustment"}
              ariaDescribedby={Data.Id.toString(p.id) ++ "-scoreAdjustment-description"}
              value=Form.input(form).scoreAdjustment
              disabled={Form.submitting(form)}
              onBlur={_ => Form.blurScoreAdjustment(form)}
              onChange={event =>
                Form.updateScoreAdjustment(form, (event->ReactEvent.Form.target)["value"])}
            />
            {" "->React.string}
            <button
              className="button-micro"
              onClick={event => {
                ReactEvent.Mouse.preventDefault(event)
                Form.updateScoreAdjustment(form, "0")
              }}>
              {"Reset"->React.string}
            </button>
          </p>
          {errorNotification(Form.scoreAdjustmentResult(form))}
          <p>
            <input
              type_="submit" value="Save" disabled={Form.submitting(form) || !Form.valid(form)}
            />
          </p>
        </form>
      </>
    }
  }

  @react.component
  let make = (~setTourney, ~tourney: Tournament.t, ~byeQueue, ~p: Player.t) => {
    let dialog = Hooks.useBool(false)
    <>
      <button
        className="button-micro"
        disabled={Js.Array2.includes(byeQueue, p.id)}
        onClick={_ =>
          setTourney({
            ...tourney,
            byeQueue: Array.concat(byeQueue, [p.id]),
          })}>
        {"Bye signup"->React.string}
      </button>
      {" "->React.string}
      <button className="button-micro" onClick={_ => dialog.setTrue()}>
        <span ariaHidden=true>
          <Icons.More />
        </span>
        <Externals.VisuallyHidden>
          {`More options for ${Player.fullName(p)}`->React.string}
        </Externals.VisuallyHidden>
      </button>
      <Externals.Dialog
        isOpen=dialog.state
        onDismiss=dialog.setFalse
        ariaLabel={`Options for ${Player.fullName(p)}`}
        className="">
        <More setTourney dialog tourney p />
      </Externals.Dialog>
    </>
  }
}

module PlayerList = {
  @react.component
  let make = (~players: array<Player.t>, ~tourney, ~setTourney, ~byeQueue) => <>
    {players
    ->Array.map(p =>
      <tr key={p.id->Data.Id.toString} className={"player " ++ Player.Type.toString(p.type_)}>
        <td> {p.firstName->React.string} </td>
        <td> {p.lastName->React.string} </td>
        <td>
          <OptionsForm setTourney tourney byeQueue p />
        </td>
      </tr>
    )
    ->React.array}
  </>
}

@react.component
let make = (~tournament: LoadTournament.t) => {
  let {tourney, setTourney, players, activePlayers, playersDispatch, getPlayer, _} = tournament
  let (playerTable, tableDispatch) = Hooks.useSortedTable(
    ~table=Map.valuesToArray(activePlayers),
    ~column=sortFirstName,
    ~isDescending=false,
  )
  let {playerIds, roundList, byeQueue, _} = tourney
  let (isSelecting, setIsSelecting) = React.useState(() => Set.isEmpty(playerIds))
  let matches = Rounds.rounds2Matches(roundList)
  <div className="content-area">
    <div className="toolbar">
      <button onClick={_ => setIsSelecting(_ => true)}>
        <Icons.Edit />
        {React.string(" Edit player roster")}
      </button>
    </div>
    <Utils.PanelContainer>
      <Utils.Panel style={ReactDOM.Style.make(~flexShrink="0", ())}>
        <table>
          <caption> {React.string("Current roster")} </caption>
          <thead>
            <tr>
              <th>
                <Hooks.SortButton sortColumn=sortFirstName data=playerTable dispatch=tableDispatch>
                  {React.string("First name")}
                </Hooks.SortButton>
              </th>
              <th>
                <Hooks.SortButton sortColumn=sortLastName data=playerTable dispatch=tableDispatch>
                  {React.string("Last name")}
                </Hooks.SortButton>
              </th>
              <th> {React.string("Options")} </th>
            </tr>
          </thead>
          <tbody className="content">
            <PlayerList byeQueue setTourney tourney players=playerTable.table />
          </tbody>
        </table>
      </Utils.Panel>
      <Utils.Panel>
        <h3> {React.string("Bye queue")} </h3>
        {switch byeQueue {
        | [] => <p className="caption-20"> {React.string("No one has signed up yet.")} </p>
        | byeQueue =>
          <table style={ReactDOM.Style.make(~width="100%", ())}>
            <tbody>
              {Array.map(byeQueue, pId =>
                <tr
                  key={Data.Id.toString(pId)} className={hasHadBye(matches, pId) ? "disabled" : ""}>
                  <td> {pId->getPlayer->Player.fullName->React.string} </td>
                  <td>
                    <button
                      className="button-micro"
                      onClick={_ =>
                        setTourney({
                          ...tourney,
                          byeQueue: Js.Array2.filter(byeQueue, id => !Id.eq(pId, id)),
                        })}>
                      {React.string("Remove")}
                    </button>
                  </td>
                </tr>
              )->React.array}
            </tbody>
          </table>
        }}
      </Utils.Panel>
      <Externals.Dialog
        isOpen=isSelecting
        onDismiss={() => setIsSelecting(_ => false)}
        ariaLabel="Select players"
        className="">
        <button className="button-micro button-primary" onClick={_ => setIsSelecting(_ => false)}>
          {React.string("Done")}
        </button>
        <Selecting tourney setTourney players playersDispatch />
      </Externals.Dialog>
    </Utils.PanelContainer>
  </div>
}
