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
  until periapsis < 30000 {
    print round(periapsis,0) at (0,2).
    lock steering to retrograde.
  }
  set throttle to 0.
  panels off.
}

function landCraft {
  until alt:radar < 20000 { lock steering to srfretrograde. }
  until chutessafe {
    lock steering to srfretrograde.
    chutessafe on.
  }
}

main().
