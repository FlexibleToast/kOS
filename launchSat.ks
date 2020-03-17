//
// Auther: Joseph McDade
// GitHub: https://github.com/FlexibleToast/kOS
//

Declare Parameter
TargetOrbit is     100000,
StartTurnAlt is      5000,
EndTurnAlt is       70000,
FinalEngines is         1,
Radial is              90,
Roll is               180,
StartTurnAngle is      90,
EndTurnAngle is         5.

function main {
  clearscreen.
  print "Launching!".
  launchCraft().
  ascentProfile().
  clearscreen.
  print "Coasting to apoapsis.".
  circularizeOrbit().
  print "Orbit circularized.".
  shutdownCraft().
}

function launchCraft{
  set throttle to 1.
  lock steering to heading(Radial, 90, Roll).
  until ship:maxthrust > 0 {
    stageCraft().
  }
}

function ascentProfile{
  // Ascent changes pitch proportianlly basen on the start:end of the turn as
  // well as the start:end of the angle of the turn.
  // Calculate ration of current apoapsis vs starting and ending apoapsis
  lock turnRatio to ((apoapsis - StartTurnAlt)/(EndTurnAlt - StartTurnAlt)).
  // Calculate ration of start vs ending angle
  set angleRatio to (StartTurnAngle - EndTurnAngle).
  // Put it together and calculate pitch
  lock pitch to round((StartTurnAngle - (turnRatio*angleRatio)),0).

  print "Apoapsis:".
  // Point up until StartTurnAlt
  until apoapsis > StartTurnAlt { printApoapsis (). }
  // Pitch over for ascent profile until apoapsis is at EndTurnAlt
  lock steering to heading(Radial, pitch, Roll).
  until apoapsis > EndTurnAlt { printApoapsis(). }
  // Set pitch to EndTurnAngle for rest of burn
  lock steering to heading(Radial, EndTurnAngle, Roll).
  until apoapsis > TargetOrbit { printApoapsis(). }

  // Setup craft to coast to apoapsis
  lock throttle to 0.
  if ship:altitude < 70000 {
    lock steering to srfprograde.
  } else {
    lock steering to prograde.
  }
  print "Target orbit apoapsis reached".
  wait 1.
}

// Helper function for ascentProfile
function printApoapsis{
  print round(apoapsis,0) at (10,1).
  autoStage().
}

function circularizeOrbit{
  // Ditch excess ascent stages not needed for a satellite
  list engines in craftEngines.
  until craftEngines:length = FinalEngines {
    stageCraft().
    list engines in craftEngines.
  }
  // Finish coasting to apoapsis
  if ship:altitude < 70000 {
    lock steering to srfprograde.
    wait until ship:altitude > 70000.
  }
  lock steering to prograde.
  wait 5.
  set warp to 3.
  // Prepare for circularization burn
  wait until eta:apoapsis < 40. // todo: change this to calculate actual time
  set warp to 0.
  wait until eta:apoapsis < 2.
  // Begin circularization
  lock throttle to 1.
  lock steering to prograde.
  set targetPeriapsis to apoapsis.
  print "Circularizing orbit.".
  print "Periapsis:".
  until periapsis > (targetPeriapsis - targetPeriapsis*.03) {
    print round(periapsis,0) at (11,2).
  }
}

function shutdownCraft{
  set throttle to 0.
  unlock throttle.
  unlock steering.
  sas on.
}

function stageCraft{
  wait until stage:ready.
  stage.
  until ship:maxthrust > 0 {
    // Stage craft until next engine
    stageCraft().
  }
}

function autoStage{
  // This function stages while being able to compensate for asparagus style
  // staging. Might think about how this would work with asparagus style tank
  // staging in the future.
  if not(defined thrust){ declare global thrust to ship:availablethrust. }
  if ship:availablethrust < (thrust - 10){
    // if thrust drops, stage
    stageCraft().
    wait 2.
    set thrust to ship:availablethrust.
  }
}

main().
