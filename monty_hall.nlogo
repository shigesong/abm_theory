;; Monty Hall Problem Simulation
;; This model simulates the famous Monty Hall problem to demonstrate
;; that switching doors gives you a 2/3 chance of winning, while
;; staying with your original choice gives only a 1/3 chance.

globals [
  car-door           ; which door has the car (1, 2, or 3)
  contestant-choice  ; contestant's initial choice
  host-opens         ; which door the host opens
  final-choice       ; contestant's final choice after deciding to switch or stay
  
  ;; Statistics for "stay" strategy
  stay-trials
  stay-wins
  stay-win-rate
  
  ;; Statistics for "switch" strategy
  switch-trials
  switch-wins
  switch-win-rate
  
  ;; Current game state
  game-result        ; "win" or "lose" for current game
  current-strategy   ; "stay" or "switch" for current game
]

breed [doors door]

doors-own [
  door-number
  has-car?
  is-opened?
  is-chosen?
  is-final-choice?
]

to setup
  clear-all
  reset-ticks
  
  ;; Initialize statistics
  set stay-trials 0
  set stay-wins 0
  set stay-win-rate 0
  
  set switch-trials 0
  set switch-wins 0
  set switch-win-rate 0
  
  ;; Create visual representation of doors
  create-doors 3 [
    set shape "square"
    set size 8
    set color brown
    set door-number who + 1
    set has-car? false
    set is-opened? false
    set is-chosen? false
    set is-final-choice? false
    setxy (door-number * 8 - 16) 0
    set label door-number
    set label-color white
  ]
  
  setup-game
end

to setup-game
  ;; Reset all doors
  ask doors [
    set has-car? false
    set is-opened? false
    set is-chosen? false
    set is-final-choice? false
    set color brown
    set label door-number
  ]
  
  ;; Randomly place the car behind one door
  set car-door random 3 + 1
  ask doors with [door-number = car-door] [
    set has-car? true
  ]
  
  set game-result ""
  set current-strategy ""
end

to play-one-game
  setup-game
  
  ;; Step 1: Contestant makes initial choice
  set contestant-choice random 3 + 1
  ask doors with [door-number = contestant-choice] [
    set is-chosen? true
    set color yellow
  ]
  
  ;; Step 2: Host opens a door with a goat (not the contestant's choice, not the car)
  set host-opens get-door-to-open
  ask doors with [door-number = host-opens] [
    set is-opened? true
    set color gray
    set label word door-number " 🐐"
  ]
  
  ;; Step 3: Contestant decides to switch or stay based on strategy
  ifelse strategy = "switch" [
    ;; Switch to the other unopened door
    set final-choice get-other-door contestant-choice host-opens
    set current-strategy "switch"
    set switch-trials switch-trials + 1
  ] [
    ;; Stay with original choice
    set final-choice contestant-choice
    set current-strategy "stay"
    set stay-trials stay-trials + 1
  ]
  
  ;; Update visual for final choice
  ask doors with [door-number = final-choice] [
    set is-final-choice? true
    set color green
  ]
  
  ;; Step 4: Reveal if contestant won
  ifelse final-choice = car-door [
    set game-result "win"
    if current-strategy = "stay" [
      set stay-wins stay-wins + 1
    ]
    if current-strategy = "switch" [
      set switch-wins switch-wins + 1
    ]
  ] [
    set game-result "lose"
  ]
  
  ;; Update win rates
  if stay-trials > 0 [
    set stay-win-rate (stay-wins / stay-trials) * 100
  ]
  if switch-trials > 0 [
    set switch-win-rate (switch-wins / switch-trials) * 100
  ]
  
  ;; Reveal all doors
  ask doors with [has-car?] [
    set label word door-number " 🚗"
  ]
  
  tick
end

to play-multiple-games
  repeat num-games [
    play-one-game
    if show-animation? [
      wait animation-speed
    ]
  ]
end

to-report get-door-to-open
  ;; Host must open a door that:
  ;; 1. Is not the contestant's choice
  ;; 2. Does not have the car
  ;; Note: There will always be at least one such door since:
  ;; - If contestant chose the car: 2 goat doors are available
  ;; - If contestant chose a goat: 1 goat door is available
  
  let available-doors [door-number] of doors with [
    door-number != contestant-choice and not has-car?
  ]
  
  report one-of available-doors
end

to-report get-other-door [choice opened]
  ;; Return the door that is neither the choice nor the opened door
  let all-doors [1 2 3]
  let other-doors remove choice all-doors
  set other-doors remove opened other-doors
  report first other-doors
end

to reset-statistics
  set stay-trials 0
  set stay-wins 0
  set stay-win-rate 0
  
  set switch-trials 0
  set switch-wins 0
  set switch-win-rate 0
  
  clear-all-plots
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
20
20
100
53
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
110
20
210
53
Play One
play-one-game
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
20
70
210
115
strategy
strategy
"stay" "switch"
1

BUTTON
20
125
210
158
Play Multiple
play-multiple-games
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
20
170
210
203
num-games
num-games
1
1000
100.0
1
1
NIL
HORIZONTAL

SWITCH
20
215
210
248
show-animation?
show-animation?
1
1
-1000

SLIDER
20
260
210
293
animation-speed
animation-speed
0
1
0.1
0.1
1
sec
HORIZONTAL

MONITOR
670
20
775
65
Stay Trials
stay-trials
0
1
11

MONITOR
670
75
775
120
Stay Wins
stay-wins
0
1
11

MONITOR
670
130
775
175
Stay Win %
stay-win-rate
2
1
11

MONITOR
670
195
775
240
Switch Trials
switch-trials
0
1
11

MONITOR
670
250
775
295
Switch Wins
switch-wins
0
1
11

MONITOR
670
305
775
350
Switch Win %
switch-win-rate
2
1
11

MONITOR
20
310
210
355
Last Result
game-result
17
1
11

MONITOR
20
365
210
410
Last Strategy
current-strategy
17
1
11

BUTTON
110
420
210
453
Reset Stats
reset-statistics
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
790
20
1090
240
Win Rates Comparison
Trials
Win Rate %
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Stay" 1.0 0 -2674135 true "" "if stay-trials > 0 [ plot stay-win-rate ]"
"Switch" 1.0 0 -13840069 true "" "if switch-trials > 0 [ plot switch-win-rate ]"

TEXTBOX
675
365
830
393
Expected:\nStay ≈ 33%\nSwitch ≈ 67%
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model simulates the famous **Monty Hall problem**, a probability puzzle based on a game show scenario. The problem demonstrates a counter-intuitive result in probability theory.

## THE MONTY HALL PROBLEM

The scenario is as follows:

1. There are three doors. Behind one door is a car (the prize), and behind the other two doors are goats.
2. You pick one door (but don't open it yet).
3. The host, who knows what's behind each door, opens one of the other two doors, always revealing a goat.
4. The host then asks: "Do you want to switch to the other unopened door, or stay with your original choice?"

**The Question:** Is it better to switch or stay?

## THE SURPRISING ANSWER

Contrary to what many people's intuition suggests, **switching gives you a 2/3 (≈67%) chance of winning**, while **staying gives you only a 1/3 (≈33%) chance**.

## WHY SWITCHING IS BETTER

When you first choose a door:
- Probability your door has the car: 1/3
- Probability the car is behind one of the other two doors: 2/3

When the host opens a goat door, they're giving you information. Since the host knows where the car is and will always reveal a goat, if the car is behind one of the other two doors (2/3 chance), it must be behind the remaining unopened door.

By switching, you essentially get the combined probability of both other doors (2/3).

## HOW TO USE IT

**Requirements:** NetLogo 6.0 or later (for emoji support: 🚗 car, 🐐 goat)

1. **Setup**: Click to initialize the simulation
2. **Choose Strategy**: Select either "stay" or "switch"
3. **Play One**: Play a single game to see the step-by-step process
4. **Play Multiple**: Run many games automatically to see the statistics converge
5. **num-games**: Set how many games to play when using "Play Multiple"
6. **show-animation?**: Toggle whether to show each game when playing multiple
7. **animation-speed**: Control the speed of animation (in seconds per game)

## THINGS TO NOTICE

- The doors are color-coded:
  - **Brown**: Unopened door
  - **Yellow**: Your initial choice
  - **Gray**: Door opened by host (always shows a goat 🐐)
  - **Green**: Your final choice
  - After reveal, the car 🚗 is shown

- The monitors show:
  - Statistics for the "stay" strategy
  - Statistics for the "switch" strategy
  - Last game result and strategy used

- The plot shows how win rates evolve over many trials

## THINGS TO TRY

1. Run 100 games with the "stay" strategy. What's the win rate?
2. Run 100 games with the "switch" strategy. What's the win rate?
3. Run 1000 games of each strategy. Do the percentages get closer to the theoretical values (33% for stay, 67% for switch)?
4. Try to predict which door has the car before it's revealed!

## EXTENDING THE MODEL

Some ideas for extensions:

- Add a "random" strategy that randomly chooses to switch or stay
- Modify the game to have 4 or 5 doors
- Add a contestant agent that learns the optimal strategy over time
- Track individual door selection patterns

## NETLOGO FEATURES

This model demonstrates:
- Use of breeds (doors)
- Global variables for game state and statistics
- Conditional logic for game rules
- Visual feedback with colors and labels
- Real-time statistics monitoring
- Plotting for data visualization

## RELATED MODELS

This model relates to probability and decision-making models in the NetLogo Models Library.

## CREDITS AND REFERENCES

The Monty Hall problem is named after Monty Hall, the host of the television game show "Let's Make a Deal."

The problem became famous after being featured in Marilyn vos Savant's "Ask Marilyn" column in Parade magazine in 1990, where she correctly stated that switching is the optimal strategy, sparking considerable debate.

References:
- vos Savant, M. (1990). "Ask Marilyn" column, Parade magazine
- Selvin, S. (1975). "A problem in probability". American Statistician. 29 (1): 67
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
