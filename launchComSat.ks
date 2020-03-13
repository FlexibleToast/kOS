set TargetOrbit to 250000.
set Radial to 90.

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
    print round(apoapsis,0) at (0,3).
    autoStage().
    if ship:airspeed < 100{
      lock steering to up.
    }else if ship:airspeed > 100 and apoapsis < 10000{
      lock steering to heading(Radial, 85).
    }else if apoapsis < 50000{
      lock steering to srfprograde.
    }else if apoapsis < 100000{
      lock steering to prograde.
    }else{
      lock steering to heading(Radial, 0).
    }
  }
  print "Target orbit apoapsis reached".
}

function circularizeOrbit{
  wait until eta:apoapsis < 30.
  until eta:apoapsis < 5 { lock steering to prograde .}
  print "Periapsis:".
  set throttle to 1.
  until (apoapsis - periapsis) < 1000{
    print round(periapsis,0) at (0,2).
    autoStage().
    lock steering to prograde.
  }
}

function shutdownCraft{
  lock throttle to 0.
  set steering to prograde.
  sas on.
  set sasmode to "prograde".
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
