//
// Auther: Joseph McDade
// GitHub: https://github.com/FlexibleToast/kOS
//

Declare Parameter
EntrancePeriapsis is 45000,
ArmChute is          10000.

function main {
  clearscreen.
  print "Returning from orbit.".
  sas off.
  decelerateCraft().
  landCraft().
  shutdownCraft().
}

function decelerateCraft {
  lock steering to retrograde.
  wait 5.
  set throttle to 1.
  print "Periapsis:".
  until periapsis < EntrancePeriapsis {
    print round(periapsis,0) at (11,1).
  }
  print "Reached desired entrance periapsis.".
  set throttle to 0.
  //Prepare craft for reentry
  panels off.
  wait 5.
  list engines in craftEngines.
  until craftEngines:length = 0 {
    // Ditch remaining engines
    wait until stage:ready.
    stage.
    wait 1.
    list engines in craftEngines.
  }
  print "Coasting to atomosphere.".
  if ship:altitude > 70000 {
    set warp to 4.
  }
}

function landCraft {
  lock steering to srfretrograde.
  wait until alt:radar < ArmChute.
  print "Deploying chutes.".
  until stage:number < 1 {
    wait until stage:ready.
    stage.
  }
}

function shutdownCraft {
  set throttle to 0.
  unlock throttle.
  unlock steering.
}

main().
