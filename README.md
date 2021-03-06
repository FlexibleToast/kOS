# kOS Scripts

## What is this?

[kOS](https://ksp-kos.github.io/KOS/) is a automation/scripting language made for the game [Kerbal Space Program](https://www.kerbalspaceprogram.com/). Kerbal Space Program, or KSP, is a game based upon using approximations of physics to get your Kerbals to space. Where to go and why? That's up to the player. The real accomplishments is learning orbital mechanics and the feeling of success when you finally land on one of Kerbin's moons or even another planet. With kOS you get write your own autopilot programs.

KSP actually inspired me to go back to school and get a degree in Computer Science. It really motivated me to study and be the best student I could with hopes of being able to join a space program someday. While I never did join a space program I did discover that I really enjoy programing and solving problems. After over 1000 hours in KSP I've finally given kOS a try... I don't know why I waited so long as it combines two of my favorite things.

## The Scripts

### launchOrbit.ks

| Parameter      | Default | Description                                                                                                |
| -------------- | -------:| ---------------------------------------------------------------------------------------------------------- |
| TargetOrbit    | 100000  | Altitude in meters that you would like your final orbit to be                                              |
| StartTurnAlt   | 2000    | Altitude in meters that you would like to start the ascent profile                                         |
| EndTurnAlt     | 70000   | Altitude in meters that you would like to end the ascent profile                                           |
| Radial         | 90      | Radial at which you would like to point the craft for your ascent, (0 North, 90 East, 180 South, 270 West) |
| Roll           | 180     | Angle at which you would like the craft to be rolled to for the ascent                                     |
| StartTurnAngle | 90      | Angle above the horizon for the ship to point at the start of the ascent (90 is straight up)               |
| EndTurnAngle   | 5       | Angle above the horizon the ship will stop turning over at until the ascent is complete                    |

This script will launch given an ascent profile that uses the ratio of StartTurnAlt:EndTurnAlt, your current apoapsis, and StartTurnAngle:EndTurnAngle. As your apoapsis increases through StartTurnAlt:EndTurnAlt your ascent will directly proportionally change angle from StartTurnAngle to EndTurnAngle. This is calculated as follows:

$$
Pitch = StartTurnAngle - \left(\frac{CurrentApoapsis - StartTurnAlt}{EndTurnAlt - StartTurnAlt}\right) * \left(StartTurnAngle - EndTurnAngle\right)
$$

First the script initiates the launch by locking the throttle to 1 (full), locking steering to straight up, and staging until available thrust is greater than 0. As the craft ascends there is an autoStage function that will detect if the available thrust drops by more than 10. This allows the craft to automatically stage even when using [asparagus](https://wiki.kerbalspaceprogram.com/wiki/Asparagus_staging) style staging. When the craft's apoapsis reaches the StartTurnAlt it will then lock the steering to the have the pitch StartTurnAngle and will progressively turn the craft until the apoapsis has reached StopTurnAlt at which point the pitch will be StopTurnAngle. The craft will continue to burn until apoapsis has reached TargetOrbit. At that point the craft will ditch all remaining stages until the number of engines left on the craft is equal to FinalEngines and coast to apoapsis.

As soon as the craft exits the atmosphere the Vis-Viva equation is performed to calculate delta v requirements for circularization and the Rocket Equation is performed to find the length of time needed for the burn.

$$
ISP = \frac{\sum_i T_i}{\sum_i \frac{T_i}{isp_i}}
$$

$$
\Delta v_2 = \sqrt{\frac{\mu}{r_2}}\left(1-\sqrt{\frac{2r_1}{r_1+r_2}}\right)
$$

$$
burnTime = \frac{g*m*ISP*\left(1-e^{\frac{-\Delta v_2}{g*ISP}}\right)}{T}
$$

The craft then orients prograde to orbit and time warps to 20 seconds before the calculated burn time, allowing margin of error and the craft to correct its orientation. Then burns at full throttle for the calculated time.

### launchSat.ks

Mostly the same as launchOrbit.ks but ditches stages until the craft only has FinalEngines number of engines attached. This is good for dumping partially used stages before circulrization. I found this initially useful for launch satellites as I only needed the final stage to circularize to setup a communication network or surface scanner.

| Parameter      | Default | Description                                                                                                |
| -------------- | -------:| ---------------------------------------------------------------------------------------------------------- |
| TargetOrbit    | 100000  | Altitude in meters that you would like your final orbit to be                                              |
| StartTurnAlt   | 2000    | Altitude in meters that you would like to start the ascent profile                                         |
| EndTurnAlt     | 70000   | Altitude in meters that you would like to end the ascent profile                                           |
| FinalEngines   | 1       | The number of engines on your final satellite design                                                       |
| Radial         | 90      | Radial at which you would like to point the craft for your ascent, (0 North, 90 East, 180 South, 270 West) |
| Roll           | 180     | Angle at which you would like the craft to be rolled to for the ascent                                     |
| StartTurnAngle | 90      | Angle above the horizon for the ship to point at the start of the ascent (90 is straight up)               |
| EndTurnAngle   | 5       | Angle above the horizon the ship will stop turning over at until the ascent is complete                    |

This script will launch given an ascent profile that uses the ratio of StartTurnAlt:EndTurnAlt, your current apoapsis, and StartTurnAngle:EndTurnAngle. As your apoapsis increases through StartTurnAlt:EndTurnAlt your ascent will directly proportionally change angle from StartTurnAngle to EndTurnAngle. This is calculated as follows:

$$
Pitch = StartTurnAngle - \left(\frac{CurrentApoapsis - StartTurnAlt}{EndTurnAlt - StartTurnAlt}\right) * \left(StartTurnAngle - EndTurnAngle\right)
$$

First the script initiates the launch by locking the throttle to 1 (full), locking steering to straight up, and staging until available thrust is greater than 0. As the craft ascends there is an autoStage function that will detect if the available thrust drops by more than 10. This allows the craft to automatically stage even when using [asparagus](https://wiki.kerbalspaceprogram.com/wiki/Asparagus_staging) style staging. When the craft's apoapsis reaches the StartTurnAlt it will then lock the steering to the have the pitch StartTurnAngle and will progressively turn the craft until the apoapsis has reached StopTurnAlt at which point the pitch will be StopTurnAngle. The craft will continue to burn until apoapsis has reached TargetOrbit. At that point the craft will ditch all remaining stages until the number of engines left on the craft is equal to FinalEngines and coast to apoapsis.

As soon as the craft exits the atmosphere the Vis-Viva equation is performed to calculate delta v requirements for circularization and the Rocket Equation is performed to find the length of time needed for the burn.

$$
ISP = \frac{\sum_i T_i}{\sum_i \frac{T_i}{isp_i}}
$$

$$
\Delta v_2 = \sqrt{\frac{\mu}{r_2}}\left(1-\sqrt{\frac{2r_1}{r_1+r_2}}\right)
$$

$$
burnTime=\frac{g*m*ISP*\left(1-e^{\frac{-\Delta v_2}{g*ISP}}\right)}{T}
$$

The craft then orients prograde to orbit and time warps to 20 seconds before the calculated burn time, allowing margin of error and the craft to correct its orientation. Then burns at full throttle for the calculated time.

### returnOrbit.ks

| Parameter         | Default | Description                                                                                           |
| ----------------- | -------:| ----------------------------------------------------------------------------------------------------- |
| EntrancePeriapsis | 45000   | The altitude in meters that you would like the initially periapsis to be as you enter the atmosphere. |
| ArmChute          | 5000    | The altitude in meters at which you would like to deploy the parachutes.                              |

This script makes two assumptions currently. It assumes you're not landing repulsively and that your parachutes are your final stage. First the script will orient your craft orbit:retrograde, burn until your periapsis is below the EntrancePeriapsis, stage until all engines are the craft are gone, then warp until the craft is entering the atmosphere. Next the craft will be oriented surface:retrograde, wait until the current altitude:radar is less than ArmChute, then will stage the craft until it has reached the last stage.

## Boot Files

Currently these boot files are specific to how I'm using them. I initially planned on making a set of generic boot files for different orbital altitudes. However, I've noticed that this boot scripts are run every time kOS is powered on for the craft, not just on the launch pad. This leads to undesirable effects when started during the incorrect stage of the craft's life. Will probably just use these for development purposes as they greatly speed up the time between writing new code and testing.

### defOrbit.ks

Used for development, opens terminal and runs launchSat.ks without passing any parameters.

### commSat.ks

Used for launching my initial Comm Sat array. Opens terminal and runs the launchSat.ks script while passing appropriate parameters.

## Todo

- Move common functions to a library to remove duplication of code

- Add ability to create and execute maneuver nodes

- Increase accuracy of circularization (maybe manipulate steering to not just be orbit prograde but vary based on apoapsis movement similar to using a manuever node or just use a maneuver node instead, finesse the throttle)
