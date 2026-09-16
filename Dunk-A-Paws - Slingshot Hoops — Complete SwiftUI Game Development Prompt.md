# MASTER DEVELOPMENT PROMPT
## Dunk-A-Paws / Slingshot Hoops
### Basketball × Slingshot Trick-Shot Physics Game for iOS

You are an expert iOS game developer specializing in **Swift, SwiftUI, SpriteKit, 2D physics, game architecture, animation, touch interaction, and mobile game UX**.

Build a complete, polished, playable iOS game called:

# Dunk-A-Paws
### Slingshot Hoops

The core concept is:

> Fluffy animal characters curl themselves into spherical balls and are launched from a slingshot toward basketball hoops through physics-based trick-shot levels.

The game should feel like a combination of:
- Casual arcade basketball
- Slingshot physics
- Puzzle/trick-shot gameplay
- Cute animal characters
- Satisfying mobile physics
- Short replayable levels

The final result must feel like a **real mobile game prototype/MVP**, not a technical demo.

---

# 1. TECHNOLOGY REQUIREMENTS

Use:

- Swift
- SwiftUI
- SpriteKit
- SpriteKit PhysicsBody
- GameplayKit only where genuinely useful
- Core Haptics / UIKit haptic generators where appropriate
- UserDefaults for lightweight local game progress
- Swift concurrency only where useful
- No third-party dependencies unless absolutely necessary

Target:
- iPhone
- Portrait orientation
- Modern iOS
- Swift 5.9+

IMPORTANT:

Use **SwiftUI as the application/UI layer** and **SpriteKit as the gameplay/physics layer**.

Recommended architecture:

```text
SwiftUI
   |
   ├── Main Menu
   ├── Character Selection
   ├── Level Selection
   ├── Settings
   └── Game HUD
          |
          v
     SpriteView
          |
          v
    GameScene
          |
          ├── Physics
          ├── Slingshot
          ├── Characters
          ├── Obstacles
          ├── Hoops
          ├── Stars
          ├── Particles
          ├── Camera
          └── Level Logic
```

Do not attempt to implement physics using SwiftUI views.

---

# 2. CORE GAMEPLAY LOOP

The primary gameplay loop is:

```text
Select Animal
      ↓
Select Level
      ↓
Animal appears inside slingshot
      ↓
Player drags backward
      ↓
Trajectory prediction appears
      ↓
Player aims
      ↓
Player releases
      ↓
Animal launches
      ↓
Physics simulation
      ↓
Interact with obstacles
      ↓
Collect stars
      ↓
Enter basketball hoop
      ↓
Score + Swish effect
      ↓
Level completion
      ↓
Stars awarded
      ↓
Next Level / Retry
```

The gameplay must be immediately understandable.

The player should be able to launch an animal within seconds of entering a level.

---

# 3. GAME CONCEPT

The animals are not normal basketballs.

They are cute animals that curl into compact spherical forms.

When launched:
- Their bodies behave approximately like balls.
- They rotate during flight.
- They bounce off appropriate surfaces.
- They interact with physics objects.
- They can trigger special abilities.

The visual style should be:

- Cute
- Colorful
- Playful
- Soft
- Premium casual mobile game
- High readability
- Clean 2D/cartoon aesthetic

Avoid making the game visually complicated.

Gameplay clarity is more important than visual complexity.

---

# 4. ANIMAL CHARACTERS

Implement the following playable animals.

## PANDA

Name:

**Panda**

Ability:

**Ground Slam**

Description:

The Panda is heavy and powerful.

When the Panda hits a valid ground/ice obstacle with sufficient downward velocity, it performs a ground slam.

Effects:

- Breaks fragile ice blocks
- Produces screen shake
- Produces dust particles
- Creates impact sound
- Gives strong haptic feedback
- Can destroy specific obstacles

Physics characteristics:

- Higher mass
- Stronger impact
- Lower bounce
- Slightly slower trajectory

Suggested configuration:

```text
Mass: 2.0
Bounce: 0.35
Friction: 0.8
Ability: Ground Slam
```

---

# 5. CAT

Name:

**Cat**

Ability:

**Air Correction / Double Jump**

The Cat can perform one mid-air correction after launch.

When the player taps the screen while the Cat is airborne:

- Apply a controlled impulse
- Slightly redirect velocity
- Allow one correction per launch
- Show a small visual effect
- Produce light haptic feedback

Do not make this ability excessively powerful.

The purpose is to allow players to correct difficult trick shots.

Suggested configuration:

```text
Mass: 1.0
Bounce: 0.55
Friction: 0.4
Ability uses: 1
```

The Cat should feel agile and responsive.

---

# 6. PENGUIN

Name:

**Penguin**

Ability:

**Ice Slide**

The Penguin performs exceptionally well on ice surfaces.

When touching an ice ramp:

- Reduce friction
- Preserve horizontal velocity
- Slide smoothly
- Maintain momentum

Suggested configuration:

```text
Mass: 1.1
Bounce: 0.45
Friction: 0.08
Ice multiplier: 1.5
```

The Penguin should be particularly useful in ice-themed levels.

---

# 7. OPTIONAL FOURTH CHARACTER

Include an additional animal if practical:

## OTTER

Ability:

**Water Bounce**

The Otter can interact with water.

When entering a water zone:

- Reduce vertical velocity
- Perform a controlled bounce
- Gain horizontal momentum

This character is optional if it increases development complexity too much.

The first three animals are mandatory.

---

# 8. SLINGSHOT SYSTEM

This is the most important mechanic.

Create a physical-looking slingshot positioned near the lower-left portion of the screen.

The selected animal starts at:

```text
launchPoint
```

The player touches the animal and drags it backward.

The animal follows the drag position but must remain within a maximum radius.

For example:

```text
maximumPullDistance = 150 points
```

The farther the player pulls:

- The greater the launch power.
- The longer the predicted trajectory.
- The more stretched the slingshot bands appear.

When released:

```text
launchVelocity = (launchPoint - dragPosition) * powerMultiplier
```

Apply the resulting velocity to the animal physics body.

---

# 9. SLINGSHOT VISUALS

Create:

- Left elastic band
- Right elastic band
- Wooden/colored slingshot frame
- Animal sitting between bands

During dragging:

```text
Frame
   \ 
    Animal
   /
```

The elastic bands should visually stretch toward the animal.

When released:

- Bands snap back.
- Animal launches.
- Small particle burst occurs.

---

# 10. AIMING SYSTEM

While dragging the animal:

Display a trajectory prediction.

The trajectory should be represented by approximately:

- 15–25 dots
- Or small circles
- With gradually decreasing opacity

The prediction must respond in real time.

Use projectile physics approximately based on:

```text
position(t) =
initialPosition
+ velocity * t
+ 0.5 * gravity * t²
```

Do not make the trajectory prediction perfectly complicated.

It should be:

- Smooth
- Fast
- Understandable
- Responsive

The trajectory should disappear immediately after launch.

---

# 11. AIM ASSIST

Add subtle aim assistance.

Do NOT automatically aim for the player.

Instead:

- Slightly highlight nearby hoop zones
- Make the trajectory readable
- Provide subtle visual feedback when the predicted path approaches the hoop

The player should still perform the shot.

---

# 12. BASKETBALL HOOPS

Create physics-based basketball hoops.

Each hoop should contain:

```text
Backboard
Rim
Net
Scoring Sensor
```

The scoring sensor should detect when the animal passes:

```text
from above the rim
through the scoring region
to below the rim
```

Only then should the shot count.

Avoid awarding points merely because the animal touches the rim.

---

# 13. SWISH DETECTION

Implement three scoring outcomes.

## SWISH

Animal passes cleanly through the center.

Reward:

- Large "SWISH!" text
- Particle burst
- Net animation
- Strong haptic feedback
- Score multiplier

## RIM SHOT

Animal touches the rim before entering.

Reward:

- Smaller score
- Small effect

## BANK SHOT

Animal hits the backboard and then enters the hoop.

Reward:

- "BANK SHOT!"
- Bonus points
- Special particles

---

# 14. HOOP MOVEMENT

Hoops should not always be static.

Implement several hoop behaviors.

## Static Hoop

Basic target.

## Horizontal Moving Hoop

Moves left/right.

## Vertical Moving Hoop

Moves up/down.

## Rotating Hoop

The entire hoop assembly rotates.

## Swinging Hoop

Hoop swings around an anchor point.

## Disappearing Hoop

Temporarily becomes inactive.

Use these progressively in later levels.

---

# 15. TRAMPOLINES

Add trampoline objects.

When the animal touches a trampoline:

- Apply strong upward impulse.
- Preserve some horizontal momentum.
- Animate trampoline compression.
- Play bounce effect.
- Trigger haptic feedback.

The trampoline should create satisfying trick-shot opportunities.

Example:

```text
Animal
   ↓
────────
Trampoline
   ↑↑↑
```

---

# 16. FAN OBSTACLES

Add rotating fans.

The fan:

- Rotates continuously.
- Contains invisible physics/force zones.
- Pushes the animal sideways.

The player must time shots around the fan.

Fan behavior:

```text
windForce
rotationSpeed
forceRadius
```

The wind should affect the animal smoothly rather than teleporting it.

---

# 17. ICE OBSTACLES

Create breakable ice blocks.

Ice blocks:

- Have their own physics bodies.
- Can be destroyed by Panda Ground Slam.
- Crack after smaller impacts.
- Break after sufficient force.

Visual sequence:

```text
Normal
 ↓
Small Crack
 ↓
More Cracks
 ↓
Break
 ↓
Ice Particles
```

Only Panda should easily destroy them with its special ability.

---

# 18. STARS

Every level can contain collectible stars.

Possible configuration:

```text
1-star level:
Reach hoop

2-star:
Reach hoop + collect 1 star

3-star:
Reach hoop + collect all stars
```

Or use a score-based system.

Stars should:

- Rotate slowly
- Glow
- Produce small particles
- Disappear when collected
- Trigger light haptic feedback

The player should be encouraged to take difficult routes to collect them.

---

# 19. LEVEL OBJECTIVES

Every level should have a clear objective.

Examples:

```text
Score the basket.
Collect 2 stars and score.
Make a bank shot.
Break the ice wall and score.
Bounce from the trampoline before scoring.
Avoid the fan and score.
Use the Cat's air correction.
Use Panda's ground slam.
```

Display the objective at the beginning of the level.

---

# 20. LEVEL STRUCTURE

Create at least **20 playable levels** using reusable level configuration.

Do NOT hard-code every level into separate classes.

Create a data-driven system.

Example:

```swift
struct LevelData {
    let id: Int
    let animal: AnimalType
    let objective: LevelObjective
    let launchPosition: CGPoint
    let hoopPosition: CGPoint
    let obstacles: [ObstacleData]
    let stars: [CGPoint]
    let parShots: Int
}
```

The exact implementation can differ.

The important requirement is that levels are configurable.

---

# 21. LEVEL DIFFICULTY

Progressively increase difficulty.

## LEVELS 1–5
Tutorial:

- Static hoop
- Basic slingshot
- Simple trajectory
- One star

## LEVELS 6–10
Introduce:

- Moving hoops
- Trampolines
- Bank shots
- Multiple stars

## LEVELS 11–15
Introduce:

- Fans
- Ice blocks
- Difficult angles
- Character abilities

## LEVELS 16–20
Advanced:

- Multiple obstacles
- Moving hoops
- Fans
- Trampolines
- Ice
- Precision shots
- Multiple stars

---

# 22. SHOT LIMIT

Each level should have limited shots.

Example:

```text
3 shots
```

If the player fails:

```text
OUT OF SHOTS
```

Show:

- Retry
- Level Select
- Main Menu

Do not immediately kick the player out of the game.

---

# 23. SCORING SYSTEM

Create a score system.

Base basket:

```text
100 points
```

Add bonuses:

```text
Swish: +100
Bank shot: +50
Star: +50
Trampoline shot: +50
Long shot: +bonus
Few-shot completion: +bonus
```

Display:

```text
SCORE
1250
```

Score should animate when increasing.

---

# 24. COMBO SYSTEM

Add optional combo scoring.

If the player performs multiple trick-shot actions in one shot:

```text
Star
↓
Trampoline
↓
Bank Shot
↓
Swish
```

Display:

```text
TRICK SHOT!
x3
```

This should reward creative shots.

---

# 25. PHYSICS

Use SpriteKit physics.

Create physics categories:

```text
animal
ground
hoop
rim
backboard
trampoline
fan
ice
star
boundary
water
```

Use bit masks correctly.

Do not rely on visual overlap alone.

Collision detection must be deterministic.

---

# 26. WORLD BOUNDARIES

Create invisible boundaries around the playable area.

If the animal leaves the playable area:

- Stop/return the animal
- Count the shot as failed
- Allow another shot if shots remain

Avoid allowing the animal to disappear permanently.

---

# 27. CAMERA

Use an SKCameraNode.

The camera should:

- Follow the animal during long shots
- Keep important gameplay objects visible
- Avoid excessive movement
- Smoothly interpolate movement

For short levels, the camera can remain fixed.

For larger levels, use controlled follow behavior.

---

# 28. GAME STATES

Implement a clear game-state machine.

States:

```text
menu
characterSelection
levelSelection
ready
aiming
flying
scored
failed
levelComplete
paused
```

Do not allow invalid actions during inappropriate states.

Example:

The player should not be able to drag the animal while the game is paused.

---

# 29. GAME HUD

During gameplay display:

Top-left:

```text
LEVEL 01
```

Top-center:

```text
SCORE
1250
```

Top-right:

```text
★ ★ ☆
```

Bottom:

```text
SHOTS: 2
```

Ability button:

```text
ABILITY
```

For Cat:

```text
AIR JUMP
```

For Panda:

```text
SLAM
```

For Penguin:

```text
SLIDE
```

The HUD should be implemented with SwiftUI over the SpriteKit scene where practical.

---

# 30. PAUSE MENU

Add a pause button.

Pause menu:

```text
PAUSED

Resume
Restart
Settings
Exit Level
```

When paused:

- SpriteKit scene pauses.
- Physics stops.
- Animations stop.
- Timers stop.
- User cannot interact with gameplay.

---

# 31. LEVEL COMPLETE SCREEN

When the player scores successfully:

Display a polished result screen.

Example:

```text
LEVEL COMPLETE!

SWISH!

★ ★ ★

SCORE
1850

BEST
1850

[ NEXT LEVEL ]
[ RETRY ]
```

Use animated star reveals.

Stars should appear one-by-one.

---

# 32. LEVEL FAILED SCREEN

Example:

```text
SHOT MISSED!

Shots Remaining: 0

[ RETRY ]
[ LEVEL SELECT ]
```

Keep it friendly.

Do not make failure frustrating.

---

# 33. MAIN MENU

Create a polished SwiftUI main menu.

Title:

```text
DUNK-A-PAWS
```

Subtitle:

```text
SLINGSHOT HOOPS
```

Buttons:

```text
PLAY
CHARACTERS
LEVELS
SETTINGS
```

Add a cute animated animal in the background.

Keep the interface simple.

---

# 34. CHARACTER SELECT

Create a SwiftUI character-selection screen.

Cards:

```text
🐼 PANDA
Heavy hitter
Ground Slam

🐱 CAT
Agile
Air Correction

🐧 PENGUIN
Ice specialist
Ice Slide
```

Show:

- Character illustration
- Name
- Ability
- Short description
- Selected state

The selected character should persist.

---

# 35. LEVEL SELECT

Create a level selection grid.

Example:

```text
01 ★★★
02 ★★☆
03 ★☆☆
04 🔒
05 🔒
```

Completed levels are unlocked.

A level is unlocked when the previous level is completed.

Persist progress using UserDefaults.

---

# 36. SAVE SYSTEM

Use UserDefaults for:

```text
selectedCharacter
highestUnlockedLevel
levelStars
bestScores
soundEnabled
musicEnabled
hapticsEnabled
```

Create a clean wrapper such as:

```text
GameProgressManager
```

Avoid scattering UserDefaults calls throughout the codebase.

---

# 37. HAPTIC FEEDBACK

Use UIKit haptic generators where appropriate.

Examples:

Light impact:
- Star collection
- Small bounce

Medium impact:
- Rim collision
- Trampoline

Heavy impact:
- Panda Ground Slam
- Strong obstacle destruction

Success notification:
- Swish
- Level completion

Failure notification:
- Missed shot

Provide a settings option:

```text
Haptics
ON/OFF
```

Never continuously trigger haptics every frame.

---

# 38. SCREEN SHAKE

Implement a reusable camera shake system.

Use screen shake for:

- Panda slam
- Strong trampoline bounce
- Ice destruction
- Major rim collision

Keep screen shake short.

Example conceptual parameters:

```text
duration
intensity
frequency
```

Do not shake the camera excessively.

---

# 39. PARTICLE EFFECTS

Use SpriteKit particle effects where useful.

Required effects:

### Launch
Small dust burst.

### Star Collection
Sparkle burst.

### Swish
Confetti + sparkle.

### Ice Break
Ice shards.

### Panda Slam
Dust + impact particles.

### Trampoline
Small bounce particles.

### Fan
Subtle wind particles.

Do not overuse particles.

Performance is important.

---

# 40. AUDIO

Design an audio system with reusable sound identifiers.

Sounds:

```text
slingshot_pull
launch
bounce
rim_hit
backboard_hit
swish
star_collect
ice_break
trampoline
fan
ability
level_complete
button_click
```

Music:

- Main menu music
- Gameplay music
- Victory music

Implement:

```text
SoundManager
```

with:

```text
musicEnabled
soundEnabled
```

If audio assets are unavailable, create the system with placeholder references and ensure the game still runs without crashing.

---

# 41. ANIMAL ANIMATION

Animals should have simple state-based animation.

States:

```text
idle
aiming
launching
flying
bouncing
ability
success
fail
```

If sprite sheets are unavailable:

Use scalable placeholder vector/SKShapeNode representations.

The game must remain playable without external artwork.

However, structure the project so artwork can easily be replaced later.

---

# 42. VISUAL DESIGN

Use a colorful casual-game style.

Suggested palette:

- Sky blue
- Soft green
- Warm yellow
- Orange
- Pink accents
- Deep navy for text

Use:

- Rounded corners
- Large buttons
- Friendly typography
- Soft shadows
- Clear hierarchy

Avoid:

- Dark corporate UI
- Tiny text
- Excessive gradients
- Cluttered interfaces

---

# 43. BACKGROUND THEMES

Create reusable themes.

## Theme 1 — Sunny Park

- Blue sky
- Clouds
- Grass
- Trees
- Basketball court

## Theme 2 — Candy World

- Pink/purple environment
- Candy platforms
- Floating objects

## Theme 3 — Arctic

- Snow
- Ice platforms
- Snowflakes
- Ice ramps

## Theme 4 — Factory

- Metal platforms
- Fans
- Moving machinery

Each theme should use reusable background nodes.

---

# 44. LEVEL GENERATION

Do NOT create levels randomly.

Use deterministic level configurations.

Every level should be intentionally designed.

Example:

```text
Level 1:
Simple direct shot

Level 2:
Higher hoop

Level 3:
Backboard bank shot

Level 4:
Star above trampoline

Level 5:
Moving hoop

Level 6:
Fan obstacle

...
```

The levels should teach mechanics gradually.

---

# 45. TUTORIAL

Create a short interactive tutorial.

First launch:

```text
PULL BACK
↓
AIM
↓
RELEASE
```

Then show:

```text
SWISH!
```

Next introduce stars.

Later introduce character abilities.

Do not create a long text tutorial.

Use visual instructions.

---

# 46. TOUCH INPUT

Implement robust touch handling.

Required:

```text
touchesBegan
touchesMoved
touchesEnded
```

Dragging should only start when the player touches the active animal.

While dragging:

- Clamp position to slingshot radius.
- Update trajectory.
- Update elastic bands.

On release:

- Calculate velocity.
- Launch animal.
- Disable further dragging.

Prevent accidental multi-touch launches.

---

# 47. TRAJECTORY IMPLEMENTATION

Create a reusable:

```text
TrajectoryRenderer
```

It should:

- Receive start point
- Receive velocity
- Receive gravity
- Calculate points
- Render prediction dots
- Update efficiently

Do not create dozens of expensive SpriteKit nodes every frame.

Reuse nodes when possible.

---

# 48. SLINGSHOT COMPONENT

Create a reusable:

```text
SlingshotNode
```

Responsibilities:

- Draw frame
- Draw bands
- Hold launch point
- Update band positions
- Animate release
- Provide launch position

Keep it independent from the GameScene where possible.

---

# 49. ANIMAL COMPONENT

Create a reusable:

```text
AnimalNode
```

Responsibilities:

- Animal visual
- Physics body
- Animal type
- Ability state
- Rotation
- Animation
- Collision interaction

Example concept:

```swift
enum AnimalType {
    case panda
    case cat
    case penguin
    case otter
}
```

---

# 50. OBSTACLE SYSTEM

Create reusable obstacle types.

Example:

```swift
enum ObstacleType {
    case trampoline
    case fan
    case iceBlock
    case movingPlatform
    case wall
}
```

Each obstacle should have:

- Position
- Size
- Physics configuration
- Visual representation
- Optional behavior

---

# 51. HOOP COMPONENT

Create:

```text
HoopNode
```

Responsibilities:

- Backboard
- Rim
- Net
- Scoring sensor
- Movement behavior
- Scoring detection
- Swish animation

Support:

```text
static
horizontal
vertical
rotating
swinging
```

---

# 52. STAR COMPONENT

Create:

```text
StarNode
```

Responsibilities:

- Animation
- Collision detection
- Collection state
- Particle effect
- Sound
- Haptic

---

# 53. GAME MANAGER

Create a central:

```text
GameManager
```

Responsible for:

- Current level
- Current animal
- Game state
- Score
- Shots
- Stars
- Level completion
- Restart
- Pause

Avoid putting everything inside GameScene.

---

# 54. LEVEL MANAGER

Create:

```text
LevelManager
```

Responsibilities:

- Load LevelData
- Build level
- Spawn obstacles
- Spawn stars
- Spawn hoop
- Configure animal
- Reset level

---

# 55. SCORE MANAGER

Create:

```text
ScoreManager
```

Responsible for:

- Base score
- Bonuses
- Combo
- Best score
- Final score

Use clear methods such as:

```text
addScore()
addBonus()
resetScore()
```

---

# 56. AUDIO MANAGER

Create:

```text
SoundManager
```

Responsible for:

- Sound effects
- Music
- Volume
- Enable/disable settings

---

# 57. HAPTIC MANAGER

Create:

```text
HapticManager
```

Responsible for:

- Light impact
- Medium impact
- Heavy impact
- Success
- Warning/error

---

# 58. ARCHITECTURE

Use a clean architecture.

Recommended:

```text
SwiftUI
    ↓
ViewModels
    ↓
GameManager
    ↓
SpriteKit GameScene
    ↓
Gameplay Components
```

Use MVVM where appropriate.

Do not force every SpriteKit node into MVVM if it makes the architecture worse.

The priority is maintainability.

---

# 59. PROJECT STRUCTURE

Organize the project approximately like:

```text
DunkAPaws/
│
├── App/
│   └── DunkAPawsApp.swift
│
├── Views/
│   ├── MainMenuView.swift
│   ├── CharacterSelectView.swift
│   ├── LevelSelectView.swift
│   ├── GameView.swift
│   ├── PauseView.swift
│   ├── LevelCompleteView.swift
│   ├── LevelFailedView.swift
│   └── SettingsView.swift
│
├── Game/
│   ├── GameScene.swift
│   ├── GameManager.swift
│   ├── LevelManager.swift
│   ├── LevelData.swift
│   ├── PhysicsCategories.swift
│   └── GameState.swift
│
├── Nodes/
│   ├── AnimalNode.swift
│   ├── SlingshotNode.swift
│   ├── HoopNode.swift
│   ├── StarNode.swift
│   ├── TrampolineNode.swift
│   ├── FanNode.swift
│   └── IceBlockNode.swift
│
├── Systems/
│   ├── TrajectoryRenderer.swift
│   ├── ScoreManager.swift
│   ├── SoundManager.swift
│   ├── HapticManager.swift
│   ├── CameraManager.swift
│   └── GameProgressManager.swift
│
├── Models/
│   ├── AnimalType.swift
│   ├── LevelObjective.swift
│   ├── ObstacleType.swift
│   └── GameProgress.swift
│
└── Resources/
    ├── Textures
    ├── Sounds
    └── ParticleEffects
```

You may adjust this structure if a better architecture is justified.

---

# 60. RESPONSIVE SCREEN DESIGN

The game must work across common iPhone aspect ratios.

Do not hard-code gameplay around one exact screen resolution.

Use:

```text
scene.size
camera
safe areas
normalized positions
```

for layout.

The SwiftUI interface must respect:

```text
safeAreaInsets
```

and not overlap the Dynamic Island/notch.

---

# 61. PERFORMANCE

Optimize for mobile.

Avoid:

- Creating unnecessary nodes every frame
- Excessive particle emitters
- Expensive calculations inside update()
- Continuous object allocation
- Large textures
- Memory leaks

Use:

- Node reuse
- Simple physics
- Texture atlases where appropriate
- Efficient trajectory calculations
- Proper cleanup after level restart

The game should remain smooth during physics-heavy shots.

---

# 62. GAME LOOP

The GameScene should manage:

```text
update()
didSimulatePhysics()
didBegin(contact)
didEnd(contact)
```

Use:

```text
update()
```

for continuous game-state updates.

Use:

```text
didBegin(contact)
```

for collision-based events.

Do not perform expensive collision searches every frame.

---

# 63. PHYSICS TUNING

The game should feel arcade-like rather than fully realistic.

Prioritize:

- Fun
- Predictability
- Responsiveness
- Consistency

Physics values should be centralized so they can be tuned easily.

Example:

```text
GamePhysicsConfig
```

containing:

```text
gravity
launchPower
bounce
friction
airResistance
fanForce
trampolineForce
```

---

# 64. RESETTING A SHOT

After a failed shot:

1. Stop the animal.
2. Remove temporary effects.
3. Increment shot counter.
4. Check remaining shots.
5. Reset the animal to launch point.
6. Reset ability usage.
7. Restore trajectory renderer.
8. Allow player to aim again.

Do not recreate the entire scene unnecessarily.

---

# 65. SUCCESS DETECTION

A level is successful when:

```text
objective conditions == true
```

For basic levels:

```text
basket scored == true
```

For advanced levels:

```text
basket scored
AND
required stars collected
```

or:

```text
basket scored
AND
required obstacle interaction completed
```

Keep objectives extensible.

---

# 66. GAME FEEL

This is extremely important.

Every successful action should feel satisfying.

When the animal:

### Launches
- Slingshot snap
- Small particles
- Sound

### Bounces
- Small scale squash
- Haptic
- Bounce sound

### Hits rim
- Metallic sound
- Small screen shake

### Collects star
- Sparkles
- Sound
- Haptic
- Score popup

### Swishes
- Net movement
- Confetti
- Screen shake
- Strong haptic
- "SWISH!" text
- Score animation

### Breaks ice
- Crack animation
- Ice shards
- Strong impact
- Haptic

The game should feel rewarding even when the player is experimenting.

---

# 67. UI ANIMATIONS

Use SwiftUI animations for:

- Menu buttons
- Screen transitions
- Level cards
- Character selection
- Star awards
- Score changes

Avoid excessive animation.

Keep transitions quick and responsive.

---

# 68. ACCESSIBILITY

Add basic accessibility labels.

Examples:

```text
Play button
Character selection
Level selection
Pause
Retry
Settings
```

Use Dynamic Type where reasonable for menus.

Gameplay text can use controlled sizes for visual consistency.

---

# 69. SETTINGS

Create:

```text
Settings

Sound Effects     ON
Music             ON
Haptics           ON

Reset Progress
```

For Reset Progress:

Show confirmation.

---

# 70. ERROR HANDLING

The game must not crash if:

- An asset is missing
- A sound cannot load
- A level contains invalid data
- User progress is unavailable

Use fallback visuals where possible.

If an image is missing, show a simple placeholder shape rather than crashing.

---

# 71. DEBUG MODE

Create an optional debug flag:

```swift
#if DEBUG
```

Debug mode can show:

```text
FPS
Physics bodies
Current game state
Animal velocity
Current score
Current shot
```

Do not show debug information in release mode.

---

# 72. TESTING REQUIREMENTS

Test:

### Slingshot
- Pull
- Maximum pull
- Release
- Very weak shot
- Very strong shot

### Physics
- Rim collision
- Backboard
- Ground
- Trampoline
- Fan
- Ice

### Abilities
- Panda slam
- Cat correction
- Penguin ice behavior

### Level
- Success
- Failure
- Restart
- Pause
- Resume

### Persistence
- Unlock level
- Save stars
- Save best score
- Character selection

---

# 73. IMPORTANT DEVELOPMENT RULE

Do not create fake functionality.

If a button exists:

- It should work.

If a character ability exists:

- It should actually affect gameplay.

If a level exists:

- It should actually be playable.

If an option says:

```text
Sound OFF
```

sound must actually turn off.

---

# 74. PLACEHOLDER ASSET STRATEGY

The game must be runnable even before final artwork is available.

Therefore:

Use simple SpriteKit shapes or generated textures as fallbacks.

Examples:

Panda:
- White circular body
- Black ears
- Black eye patches

Cat:
- Orange/gray circular body
- Ears
- Simple face

Penguin:
- Blue/black circular body
- White belly
- Orange beak

Hoop:
- Orange rim
- White net
- Blue/gray backboard

Trampoline:
- Rounded platform

Fan:
- Circular center + blades

Ice:
- Semi-transparent blue polygon/rectangle

These placeholders should look intentionally cute rather than like debug graphics.

Make it easy to replace them later with PNG/SVG-style artwork.

---

# 75. FIRST PLAYABLE MVP

Before implementing all 20 levels, make sure the first playable slice works completely.

The minimum playable slice must include:

```text
Main Menu
↓
Level 1
↓
Panda/Cat
↓
Slingshot
↓
Trajectory
↓
Launch
↓
Physics
↓
Hoop
↓
Swish detection
↓
Score
↓
Level Complete
↓
Retry / Next
```

Only after this works should additional mechanics be layered in.

---

# 76. DEVELOPMENT PRIORITY

Implement in this order:

## PHASE 1
Project setup.

## PHASE 2
SpriteKit GameScene.

## PHASE 3
Slingshot interaction.

## PHASE 4
Trajectory prediction.

## PHASE 5
Animal physics.

## PHASE 6
Hoop and scoring.

## PHASE 7
Stars.

## PHASE 8
Game states.

## PHASE 9
SwiftUI HUD.

## PHASE 10
Menus.

## PHASE 11
Character abilities.

## PHASE 12
Obstacles.

## PHASE 13
Level system.

## PHASE 14
Progress persistence.

## PHASE 15
Audio/haptics.

## PHASE 16
Particles/game feel.

## PHASE 17
Polish and testing.

---

# 77. CODE QUALITY REQUIREMENTS

Write production-quality Swift.

Follow:

- Swift naming conventions
- Small focused classes
- Clear responsibilities
- No unnecessary singletons
- Avoid massive GameScene files
- Avoid force unwraps where practical
- Avoid duplicated code
- Use enums and structs for configuration
- Use comments only where logic is non-obvious

Do not generate a giant 3,000-line GameScene.

Split systems into reusable components.

---

# 78. SWIFTUI + SPRITEKIT INTEGRATION

Create a GameView similar conceptually to:

```text
SwiftUI
   ↓
SpriteView(scene: gameScene)
   +
SwiftUI overlay
```

The SpriteKit scene should expose observable gameplay state to SwiftUI through a suitable interface.

For example:

```text
score
shotsRemaining
starsCollected
gameState
abilityAvailable
```

Avoid tightly coupling SwiftUI views to SpriteKit internals.

---

# 79. FINAL USER EXPERIENCE

The player should be able to:

1. Open the app.
2. See the Dunk-A-Paws title.
3. Tap Play.
4. Choose an animal.
5. Select an unlocked level.
6. See a short objective.
7. Drag the animal backward.
8. See the trajectory.
9. Release.
10. Watch the animal fly.
11. Bounce off objects.
12. Collect stars.
13. Enter the hoop.
14. See SWISH.
15. Receive score.
16. Receive haptic feedback.
17. Earn stars.
18. Unlock the next level.
19. Replay levels to improve their score.

This entire loop must work without crashes.

---

# 80. FINAL ACCEPTANCE CRITERIA

Consider the project complete only when:

- The app builds successfully.
- The app launches successfully.
- Main menu works.
- Character selection works.
- Level selection works.
- Level unlocking works.
- Slingshot works.
- Dragging works.
- Trajectory prediction works.
- Launch physics works.
- Animal collisions work.
- Hoop scoring works.
- Swish detection works.
- Stars work.
- Shots work.
- Retry works.
- Pause works.
- Resume works.
- Character abilities work.
- Trampolines work.
- Fans work.
- Ice obstacles work.
- Level completion works.
- Score system works.
- Haptics work.
- Sound settings work.
- Progress persists.
- The game supports multiple levels.
- The game adapts to different iPhone screen sizes.
- No placeholder button is left non-functional.
- No administrator/backend system is required.
- No internet connection is required for core gameplay.

---

# 81. IMPORTANT: HOW TO IMPLEMENT THIS PROMPT

Do not simply generate a collection of code snippets.

Build the project as a cohesive application.

First inspect the existing project structure if code already exists.

If an existing project exists:

- Reuse useful code.
- Do not unnecessarily rewrite working components.
- Integrate the new architecture carefully.

If starting from an empty project:

- Create all required files.
- Configure SwiftUI.
- Configure SpriteKit.
- Create the necessary models, managers, nodes, views and systems.

When an external visual/audio asset is unavailable:

- Use procedural placeholder graphics.
- Keep the game functional.

Do not stop after creating the UI.

The goal is a **fully playable physics game prototype**.

---

# 82. FINAL DELIVERABLE

Produce a complete working iOS game project named:

**Dunk-A-Paws**

with subtitle:

**Slingshot Hoops**

The final application should feel like a polished casual arcade game where:

> **Cute animals become basketballs, slingshots become launchers, and every basket becomes a trick shot.**

Prioritize **playability → physics → game feel → progression → polish**.

Do not sacrifice working gameplay for decorative UI.

Start by implementing the core playable game loop, then progressively integrate the remaining systems until the complete specification is functional.