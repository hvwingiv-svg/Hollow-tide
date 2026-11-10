# Hollow Tide: movement grey-box (milestone 1)

Run, jump, roll, and camera in a test room made of placeholder rectangles.
No combat, stamina, or enemies yet; those are milestones 2 and 3.

## Run it

1. Install Godot 4.3 or newer (standard build, not .NET).
2. In the Project Manager choose Import and select `project.godot`.
3. Press F5.

The project uses the Compatibility renderer and a 640 x 360 viewport with
integer scaling, so it is light on integrated graphics.

## Controls

| Action | Keyboard | Gamepad | Touch |
| --- | --- | --- | --- |
| Move | A / D or arrow keys | Left stick or d-pad | Arrow buttons, bottom left |
| Jump | Space (hold for a higher jump) | A | JUMP button (hold for higher) |
| Roll | Shift or K | B | ROLL button |

Touch buttons hide when you press a key or gamepad button and return on the
next touch. Your movement thumb can slide between left and right without
lifting. Mouse clicks count as touches, so the buttons can be tested without
a touchscreen. Layout and size are constants at the top of
`scripts/ui/touch_controls.gd`.

The player turns teal while a roll is invincible. The top-left readout shows
the current state, speed, and whether i-frames are on.

## What to try in the test room

Left to right:

- Open floor for run, stop, and roll feel. Grid lines are 32 px apart.
- A 48 px gap. A running jump clears it; a roll does not. Falling in respawns you.
- A staircase with rises of 16, 32, and 48 px. The last needs a full jump.
- Two one-way platforms you can jump up through.
- A drop to a lower floor with a step to climb back out, for the camera's vertical follow.

## Tuning

Every movement number lives in `data/player_movement.tres`. Open it in the
inspector and change values while the game runs.

| Setting | Start value |
| --- | --- |
| Run speed | 120 px/s |
| Jump height / time to apex | 52 px / 0.36 s |
| Coyote time | 0.10 s |
| Input buffer (on the InputComponent node) | 0.15 s |
| Roll duration / invincible window | 0.45 s / 0.20 s |
| Roll distance | about 80 px |

## Layout

```
project.godot
data/player_movement.tres        tuning numbers
scenes/test_room.tscn            main scene
scenes/player/player.tscn        player: body, input, state machine
scripts/input_setup.gd           autoload: builds input actions per player index
scripts/components/              InputComponent (buffered input for one player)
scripts/state_machine/           State and StateMachine, reused by enemies later
scripts/player/                  Player, MovementData, and the four states
scripts/camera/follow_camera.gd  follows the midpoint of the "players" group
scripts/world/                   GreyboxBlock (resizable solid rectangle), grid
scripts/ui/debug_hud.gd          on-screen readout
scripts/ui/touch_controls.gd     on-screen touch buttons
```

## Co-op readiness

Single player for now, but nothing assumes one player:

- Input actions are named per player (`p1_jump`, `p2_jump`, ...).
- The camera and HUD find players through the `players` group.
- There is no global player singleton.

## Next: milestone 2

Stamina, light and heavy attacks, hitboxes and hurtboxes, hit freeze, and a
training dummy. The roll's `invincible` flag is already there for the hurtbox
to read.
