//
// Auther: Joseph McDade
// GitHub: https://github.com/FlexibleToast/kOS
//

Declare Parameter
TargetOrbit is     100000,
StartTurnAlt is      2000,
EndTurnAlt is       70000,
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
  // Calculate ratio of current apoapsis vs starting and ending apoapsis
  lock turnRatio to ((apoapsis - StartTurnAlt)/(EndTurnAlt - StartTurnAlt)).
  // Calculate ratio of start vs ending angle
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
  unlock pitch.
  print "Target orbit apoapsis reached".
  wait 1.
}

// Helper function for ascentProfile
function printApoapsis{
  print round(apoapsis,0) at (10,1).
  autoStage().
}

function circularizeOrbit{
  // Make sure we've exited atmosphere
  if ship:altitude < 70000 {
    lock steering to srfprograde.
    wait until ship:altitude > 70000.
  }
  lock steering to prograde.
  // Calculate circularization burn
  set burnTime to calcBurnTime(circDeltavCalc(apoapsis)).
  set aTime to time:seconds + eta:apoapsis.
  print "Caclulated dV:        " + circDeltavCalc(apoapsis).
  print "Calculated burn time: " + burnTime.
  // Coast to apoapsis
  wait 10.
  warpto(aTime - (burnTime/2 + 20)). // Warp to 20s before burn
  wait until time:seconds > aTime - burnTime/2.
  lock throttle to 1.
  print "Circularizing orbit.".
  print "Periapsis:".
  set startTime to time:seconds.
  until time:seconds > aTime + burnTime/2 {
    print round(periapsis,0) at (11,4).
  }
  lock throttle to 0.
  set endTime to time:seconds.
  print "Actual burn time:     " + (endTime - startTime).
}

function circDeltavCalc {
  parameter desiredOrbit.
  local u to ship:obt:body:mu.
  local r1 to periapsis + ship:obt:body:radius.
  local r2 to desiredOrbit + ship:obt:body:radius.
  return sqrt(u / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).
}

function calcBurnTime {
  parameter dV, burnAlt is apoapsis.
  local f is (calcThrust() * 1000).
  local m is (ship:mass * 1000).
  local e is constant():E.
  local isp is calcISP().
  local g is (constant():G * ship:obt:body:mass) / (burnAlt + ship:obt:body:radius)^2.
  return (g * m * isp * (1 - e^(-dV/(g*isp))) / f).
}

function calcThrust {
  list engines in en.
  local thrust to 0.
  for engine in en { // thrustlimit, thrust,
    set thrust to (thrust + engine:availablethrust).
  }
  print "calculated thrust: " + thrust.
  return thrust.
}

function calcISP {
  list engines in en.
  local ispSum to 0.
  for engine in en {
    if engine:isp > 0 {
      set ispSum to (ispSum + (engine:availablethrust / engine:isp)).
    }
  }
  print "calculated ISP:    " + (calcThrust() / ispSum).
  return (calcThrust() / ispSum).
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
