set TargetOrbit to 100000.
set Radial to          90.
set Roll to            90.
set StartTurnAlt to  5000.
set EndTurnAlt to   70000.
set StartTurnAngle to  90.
set EndTurnAngle to     5.

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
  // Locking the pitch to the calculation here to make as readible as possible
  lock pitch to round((StartTurnAngle - (((apoapsis - StartTurnAlt)/(EndTurnAlt - StartTurnAlt))
                      *(StartTurnAngle - EndTurnAngle)+StartTurnAngle)),0).
  until apoapsis > TargetOrbit {
    print round(apoapsis,0) at (10,2).
    autoStage().
    if apoapsis < StartTurnAlt {
      lock steering to heading(Radial, 90, Roll).
    } else if apoapsis < EndTurnAlt {
      lock steering to heading(Radial, pitch, Roll)
    } else {
      lock steering to heading(Radial, EndTurnAngle, Roll).
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
