set TargetOrbit to 100000.
set Radial to 90.
set TurnSpeed to 50.
set OrbitTurn to 30000.
set FinalTurn to 60000.

function main {
  clearscreen.
  print "Launching!".
  launchCraft().
  print "Performing gravity turn.".
  gravityTurn().
  clearscreen.
  print "Coasting to apoapsis.".
  shutdownCraft().
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
  print "Apoapsis:".
  until apoapsis > TargetOrbit {
    print round(apoapsis,0) at (10,2).
    autoStage().
    if ship:airspeed < TurnSpeed {
      lock steering to up.
    }else if ship:airspeed > TurnSpeed and apoapsis < 10000 {
      lock steering to heading(Radial, 85).
    }else if apoapsis < OrbitTurn {
      lock steering to srfprograde.
    }else if apoapsis < FinalTurn {
      lock steering to prograde.
    }else{
      lock steering to heading(Radial, 5).
    }
  }
  print "Target orbit apoapsis reached".
}

function circularizeOrbit{
  wait until eta:apoapsis < 30.
  sas off.
  until eta:apoapsis < 15 { lock steering to heading(Radial, 0) .}
  print "Periapsis:".
  set throttle to 1.
  until periapsis > (TargetOrbit - TargetOrbit*.05) {
    print round(periapsis,0) at (0,2).
    autoStage().
    lock steering to heading(Radial, 0).
  }
}

function shutdownCraft{
  lock throttle to 0.
  set steering to prograde.
  sas on.
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
