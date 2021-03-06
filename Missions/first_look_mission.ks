// Launch mission
// This mission will take a craft into a circular orbit
// By default, it goes to a 100km equatorial orbit
// Can lauch to a certain heading, altitude, and even
// launch to an initial parking altitude before transferring
// to the final altitude.
{
  output("Loading First Look mission", true).

  global first_look_mission is lex(
    "sequence", list(
      "preflight", preflight@,
      "launch", launch@,
      "ascent", ascent@,
      "circularize", circularize@,
      "transfer", do_transfer@,
      "final_circ", circularize@
    ),
    "events", lex(
      "transmitScience", science_lib["transmitScience"]
    ),
    "target_heading", 0,
    "target_altitude", 100000,
    "final_altitude", 100000
  ).

  function preflight {
    parameter mission.

    set ship:control:pilotmainthrottle to 0.
    output("Launch parameters: " + first_look_mission["target_heading"] + ":" + first_look_mission["target_altitude"] + ":" + first_look_mission["final_altitude"], true).
    if launcher["launch"](first_look_mission["target_heading"], first_look_mission["target_altitude"], first_look_mission["final_altitude"]) {
      launcher["start_countdown"](5).
      mission["next"]().
    } else {
      output("Unable to launch, mission terminated.", true).
      mission["terminate"]().
    }

  }

  function launch {
    parameter mission.
    if launcher["countdown"]() <= 0 {
      mission["add_event"]("staging", event_lib["staging"]).
      mission["next"]().
    }
  }

  function ascent {
    parameter mission.
    if launcher["ascent_complete"]() {
        mission["next"]().
      }
  }

  function circularize {
    parameter mission.
    if curr_mission:haskey("circ") {
      if launcher["circularized"]() {
        curr_mission:remove("circ").
        mission["next"]().
      }
    } else {
      launcher["circularize"]().
      set curr_mission["circ"] to true.
    }
  }

  function do_transfer {
    parameter mission.
    if launcher["transfer_complete"]()
      mission["next"]().
  }

}
