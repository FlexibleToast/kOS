set EntrancePeriapsis to 45000.
set ArmChute to          10000.

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
    print round(periapsis,0) at (11,1).
    lock steering to retrograde.
  }
  set throttle to 0.
  panels off.
  wait 5.
  // Ditch remaining engines
  list engines in craftEngines.
  until craftEngines:length < 1 {
    wait until stage:ready.
    stage.
    wait 1.
    list engines in craftEngines.
  }
}

function landCraft {
  until alt:radar < ArmChute { lock steering to srfretrograde. }
  print "Deploying chutes.".
  chutes on.
}

main().
