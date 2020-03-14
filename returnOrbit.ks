Declare Parameter
EntrancePeriapsis is 45000,
ArmChute is          10000.

function main {
  clearscreen.
  print "Returning from orbit.".
  sas off.
  decelerateCraft().
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
  print "Reached desired entrance periapsis.".
  print "Coasting to atomosphere.".
  until ship:altitude < 70000 { set warp to 4. }
  set warp to 0.
}

function landCraft {
  until alt:radar < ArmChute {
    lock steering to srfretrograde.
    wait 1.
  }
  print "Deploying chutes.".
  until stage:number = 0 {
    wait stage:ready.
    stage.
  }
}

main().
