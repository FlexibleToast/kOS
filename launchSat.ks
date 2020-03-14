Declare Parameter
TargetOrbit is     100000,
EndTurnAlt is       70000,
StartTurnAlt is      5000,
Radial is              90.
set Roll to           180.
set StartTurnAngle to  90.
set EndTurnAngle to     5.

function main {
  clearscreen.
  print "Launching!".
  launchCraft().
  gravityTurn().
  clearscreen.
  print "Coasting to apoapsis.".
  circularizeOrbit().
  print "Orbit circularized.".
  shutdownCraft().
}

function launchCraft{
  set throttle to 1.
  lock steering to up.
  until ship:maxthrust > 0 {
    stageCraft().
  }
}

function gravityTurn{
  // Locking the pitch to the calculation here to make as readible as possible
  lock pitch to round((StartTurnAngle - (((apoapsis - StartTurnAlt)/(EndTurnAlt - StartTurnAlt))
                      *(StartTurnAngle - EndTurnAngle))),0).
  print "Apoapsis:".
  until apoapsis > TargetOrbit {
    print round(apoapsis,0) at (10,1).
    autoStage().
    if apoapsis < StartTurnAlt {
      lock steering to heading(Radial, 90, Roll).
    } else if apoapsis < EndTurnAlt {
      lock steering to heading(Radial, pitch, Roll).
    } else {
      lock steering to heading(Radial, EndTurnAngle, Roll).
    }
  }
  lock throttle to 0.
  if ship:altitude < 70000 {
    lock steering to srfprograde.
  } else {
    lock steering to prograde.
  }
  print "Target orbit apoapsis reached".
  wait 1.
}

function circularizeOrbit{
  // Ditch excess ascent stages not needed for a satellite
  until stage:number = 0 {
    stageCraft().
  }
  if ship:altitude < 70000 {
    until ship:altitude > 70000 { lock steering to srfprograde. }
  }
  set steering to prograde.
  wait 5.
  set warp to 3.
  wait until eta:apoapsis < 40.
  set warp to 0.
  until eta:apoapsis < 2 { lock steering to prograde. }
  print "Circularizing orbit.".
  print "Periapsis:".
  set throttle to 1.
  set targetPeriapsis to apoapsis.
  until periapsis > (targetPeriapsis - targetPeriapsis*.03) {
    print round(periapsis,0) at (11,2).
    autoStage().
    lock steering to prograde.
  }
}

function shutdownCraft{
  set throttle to 0.
  unlock throttle.
  set steering to prograde.
}

function stageCraft{
  wait until stage:ready.
  stage.
  until ship:maxthrust > 0 {
    stageCraft().
  }
}

function autoStage{
  if not(defined thrust){ declare global thrust to ship:availablethrust. }
  if ship:availablethrust < (thrust - 10){
    stageCraft().
    wait 1.
    set thrust to ship:availablethrust.
  }
}

main().
