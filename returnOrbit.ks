set EntrancePeriapsis to 45000.
set ArmChute to 4000.

function main {
  clearscreen.
  print "Returning from orbit.".
  sas off.
  decelerateCraft().
  print "Reached desired entrance periapsis.".
  landCraft().
}

function decelerateCraft {
  set steering to retrograde.
  wait 3.
  set throttle to 1.
  print "Periapsis:".
  until periapsis < EntrancePeriapsis {
    print round(periapsis,0) at (10,1).
    lock steering to retrograde.
  }
  set throttle to 0.
  panels off.
  // Todo: Add way to stage away all engines
}

function landCraft {
  until alt:radar < ArmChute { lock steering to srfretrograde. }
  print "Deploying chute when safe.".
  until chutessafe {
    lock steering to srfretrograde.
    chutessafe on.
  }
}

main().
