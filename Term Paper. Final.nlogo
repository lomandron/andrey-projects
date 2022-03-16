globals [intersections1 roads mouse-clicked?]
breed [houses1 house1]
breed [houses2 house2]
breed [houses3 house3]
breed [houses4 house4]
breed [houses5 house5]
breed [guards guard]
breed [walkers walker]
breed [facilities facility]
breed [stoneroads stoneroad]
breed [intersections intersection]
walkers-own [goal age memory myhome]
directed-link-breed [paths path]
patches-own [intersection? dist-to-school dist-to-shop dist-to-buses dist-to-house1 dist-to-house2 dist-to-house3 dist-to-house4 dist-to-house5 grass? popularity road-to-house?]



to setup
  clear-all
  ask patches [set pcolor green set intersection? false set grass? false set road-to-house? false]
  creating-roads
  creating-roads-to-facilities
  creating-houses
  creating-facilities
  creating-walkers
  ;creating-intersection
  if fences [creating-fences]
  set-distances

  reset-ticks
end

to go
  make-guards
  ifelse desire-way [desire-paths] [stone-paths]
  tick
end

to stone-paths
  ask walkers [
    let goals (turtle-set myhome other facilities)
    if patch-here = [patch-here] of myhome [set memory [] set goal one-of facilities]
    if patch-here = [patch-here] of goal [set memory [] set goal one-of goals]
    set memory lput patch-here memory
    ifelse any? facilities in-radius 6 [move] [
      ifelse any? other walkers-on patch-ahead 1 [ifelse patch-here = [patch-here] of myhome [move-to patch-here][move]] [move]]
    if length memory > 5 [
      set memory remove first memory memory]
  ]
end

to move
  let goal-patch-school min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself ] [dist-to-school]
  let goal-patch-shop min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself ] [dist-to-shop]
  let goal-patch-bus min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself ] [dist-to-buses]
  let goal-patch-home1 min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself] [dist-to-house1]
  let goal-patch-home2 min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself] [dist-to-house2]
  let goal-patch-home3 min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself] [dist-to-house3]
  let goal-patch-home4 min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself] [dist-to-house4]
  let goal-patch-home5 min-one-of neighbors4 with [pcolor = gray - 2 and not member? self [memory] of myself] [dist-to-house5]

  if myhome = one-of houses1 [
    face goal-patch-home1 move-to goal-patch-home1 ]
  if myhome = one-of houses2 [
    face goal-patch-home2 move-to goal-patch-home2 ]
  if myhome = one-of houses3 [
    face goal-patch-home3 move-to goal-patch-home3 ]
  if myhome = one-of houses4 [
    face goal-patch-home4 move-to goal-patch-home4 ]
  if myhome = one-of houses5 [
    face goal-patch-home5 move-to goal-patch-home5 ]
  if [shape] of goal = "building institution" [
    face goal-patch-school move-to goal-patch-school ]
  if [shape] of goal = "building store" [
    face goal-patch-shop move-to goal-patch-shop ]
  if [shape] of goal = "bus" [
    face goal-patch-bus move-to goal-patch-bus ]
  if patch-ahead 1 = nobody [set heading heading - 180 fd 1 set memory []]
end
to desire-move
  let goal-patch-school min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-school != 0] [dist-to-school]
  let goal-patch-shop min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-shop != 0] [dist-to-shop]
  let goal-patch-bus min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-buses != 0] [dist-to-buses]
  let goal-patch-home1 min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-house1 != 0] [dist-to-house1]
  let goal-patch-home2 min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-house2 != 0] [dist-to-house2]
  let goal-patch-home3 min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-house3 != 0] [dist-to-house3]
  let goal-patch-home4 min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-house4 != 0] [dist-to-house4]
  let goal-patch-home5 min-one-of neighbors4 with [not member? self [memory] of myself and dist-to-house5 != 0] [dist-to-house5]

  if myhome = one-of houses1 [
    face goal-patch-home1 move-to goal-patch-home1 ]
  if myhome = one-of houses2 [
    face goal-patch-home2 move-to goal-patch-home2 ]
  if myhome = one-of houses3 [
    face goal-patch-home3 move-to goal-patch-home3 ]
  if myhome = one-of houses4 [
    face goal-patch-home4 move-to goal-patch-home4 ]
  if myhome = one-of houses5 [
    face goal-patch-home5 move-to goal-patch-home5 ]
  if [shape] of goal = "building institution" [
    face goal-patch-school move-to goal-patch-school ]
  if [shape] of goal = "building store" [
    face goal-patch-shop move-to goal-patch-shop ]
  if [shape] of goal = "bus" [
    face goal-patch-bus move-to goal-patch-bus ]
  if patch-ahead 1 = nobody [set heading heading - 180 fd 1 set memory []]

  if goal-patch-school = nobody [set memory []]
  if goal-patch-shop = nobody [set memory []]
  if goal-patch-bus = nobody [set memory []]
  if goal-patch-home1 = nobody [set memory []]
  if goal-patch-home2 = nobody [set memory []]
  if goal-patch-home3 = nobody [set memory []]
  if goal-patch-home4 = nobody [set memory []]
  if goal-patch-home5 = nobody [set memory []]
end
to creating-roads
  set roads patches with [pxcor = 5 or pxcor = -5 or pxcor = 15 or pxcor = -15 and pycor <= 30  and pycor >= -30 or pycor = 15 or pycor = -15 or pycor = 0]
  ask roads [
    set pcolor gray - 2
  ]
  ask patches with [pcolor = gray - 2 and pxcor >= -14 and pxcor <= 14 and pycor >= -14 and pycor <= 14 or pycor <= -16 and pxcor >= -14 and pxcor <= 14] [set pcolor green set grass? true]
  ask patches with [pcolor = gray - 2 and pycor > 23 and pxcor = 5] [set pcolor green set grass? true]
  ask patches with [pcolor = gray - 2 and pycor > 23 and pxcor = -5] [set pcolor green set grass? true]
end

to creating-roads-to-facilities
  ;HOUSES
  ask patches with [pxcor = -10 and pycor > 15 and pycor <= 23 or pxcor = 0 and pycor > 15 and pycor <= 23 or pxcor = 10 and pycor > 15 and pycor <= 23 ] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pxcor = 23 and pycor < -15 and pycor >= -23 or pycor = -23 and pxcor > 15 and pxcor <= 23] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pxcor = -23 and pycor < -15 and pycor >= -23 or pycor = -23 and pxcor < -15 and pxcor >= -23] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pycor = 23 and pxcor > -15 and pxcor < 15] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]

  ;SHOP
  ask patches with [pxcor = -22 and pycor <= 7 and pycor > 0 ] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pxcor = -22 and pycor <= 14 and pycor >= 7] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pycor = 7 and pxcor <= -16 and pxcor >= -22] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]


  ;SCHOOL
  ask patches with [pxcor = 0 and pycor <= -16 and pycor >= -26 ] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pycor = -27 and pxcor > -15 and pxcor < 15] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ;BUS
  ask patches with [pxcor = 22 and pycor <= 3 and pycor >= 1 ] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
  ask patches with [pycor = 3 and pxcor >= 16 and pxcor <= 22 ] [
    set pcolor gray - 2
    set road-to-house? true
    sprout-stoneroads 1[
      set shape "tile brick"
      set color grey
      set heading 270
      stamp die
    ]
  ]
end

to creating-houses
  let houses (turtle-set houses1 houses2 houses3)
  create-houses1 1 [
    setxy -10 23
    set shape "house colonial"
    set color cyan
    set size 8
  ]
  create-houses2 1 [
    setxy 0 23
    set shape "house colonial"
    set color cyan
    set size 8
  ]
  create-houses3 1 [
    setxy 10 23
    set shape "house colonial"
    set color cyan
    set size 8
  ]
  create-houses4 1 [
    setxy -23 -23
    set shape "house colonial"
    set color cyan
    set size 8
  ]
  create-houses5 1 [
    setxy 23 -23
    set shape "house colonial"
    set color cyan
    set size 8
  ]

end

to creating-facilities
  create-facilities 1 [
    set label "school"
    setxy 0 -26
    set shape "building institution"
    set color magenta - 1
    set size 12
  ]
  create-facilities 1 [
    set label "bus stop"
    setxy 22 3
    set shape "bus"
    set size 6
    set color yellow
  ]
  create-facilities 1 [
    set label "shop"
    setxy -22 7
    set shape "building store"
    set size 10
    set color orange + 1
  ]
  ask patch 5 -20 [set plabel "school"]
end

to creating-walkers
  ifelse number-of-houses-with-people > 3 [
    if number-of-houses-with-people = 4 [
      create-walkers number-of-walkers / 4 [setxy -10 23 set myhome one-of houses1 ]
      create-walkers number-of-walkers / 4 [setxy 0 23 set myhome one-of houses2]
      create-walkers number-of-walkers / 4 [setxy 10 23 set myhome one-of houses3]
      create-walkers number-of-walkers / 4 [setxy -23 -23 set myhome one-of houses4]
    ]
    if number-of-houses-with-people = 5 [
      create-walkers number-of-walkers / 5 [setxy -10 23 set myhome one-of houses1 ]
      create-walkers number-of-walkers / 5 [setxy 0 23 set myhome one-of houses2]
      create-walkers number-of-walkers / 5 [setxy 10 23 set myhome one-of houses3]
      create-walkers number-of-walkers / 5 [setxy -23 -23 set myhome one-of houses4]
      create-walkers number-of-walkers / 5 [setxy 23 -23 set myhome one-of houses5]
    ]
  ][
    create-walkers number-of-walkers / 3 [setxy -10 23 set myhome one-of houses1 ]
    create-walkers number-of-walkers / 3 [setxy 0 23 set myhome one-of houses2]
    create-walkers number-of-walkers / 3 [setxy 10 23 set myhome one-of houses3]
  ]

  ask walkers [setting-walkers]
end

to setting-walkers
  face min-one-of patches with [pcolor = gray - 2] [distance myself]
  ;set goal one-of facilities
  ;set shape one-of ["person business" "person construction" "person doctor"
    ;"person farmer" "person graduate" "person lumberjack" "person police" "person service"
    ;"person student" "person soldier"]


end

to creating-intersection
  ask patches with [pcolor = gray - 2] [
    if count other patches in-radius 1 with [pcolor = gray - 2] = 3 [set intersection? true]
    if count other patches in-radius 1 with [pcolor = gray - 2] = 4 [set intersection? true]
  ]
  ask patches with [intersection? = true] [
    sprout-intersections 1 [
      set color yellow
      set shape "star"

    ]
  ]

  ;create-links-between-intersection
end

to create-links-between-intersection
  ask intersections [
    create-link-with min-one-of other intersections [distance myself]
  ]
  ask links [set color red]
end

to set-distances
  ask patches with [pcolor != red][
    let houses (turtle-set houses1 houses2 houses3)
    set dist-to-school [distance myself] of [patch-here] of one-of facilities with [shape = "building institution"]
    set dist-to-shop [distance myself] of [patch-here] of one-of facilities with [shape = "building store"]
    set dist-to-buses [distance myself] of [patch-here] of one-of facilities with [shape = "bus"]
    set dist-to-house1 [distance myself] of [patch-here] of one-of houses1
    set dist-to-house2 [distance myself] of [patch-here] of one-of houses2
    set dist-to-house3 [distance myself] of [patch-here] of one-of houses3
    set dist-to-house4 [distance myself] of [patch-here] of one-of houses4
    set dist-to-house5 [distance myself] of [patch-here] of one-of houses5
  ]

end

to creating-fences
  ask patches with [pcolor = gray - 2] [ask neighbors4 with [pcolor != gray - 2] [set pcolor yellow + 2]]

  if percent-of-fences = 0 [
    ask n-of percent-of-fences patches with [pcolor = gray - 2] [ask neighbors4 with [pcolor != gray - 2] [set pcolor red]]
    ask patches [ask neighbors4 with [pcolor != gray - 2] [set pcolor green]]
  ]

  if percent-of-fences = 50 [
    ask patches with [pcolor = gray - 2 and pxcor >= -15 and pxcor <= 15 and pycor <= 15 and pycor >= -15] [ask neighbors4 with [pcolor != gray - 2] [set pcolor red]]
  ]

  if percent-of-fences = 100 [
    ask n-of ((percent-of-fences / 100) * count patches with [pcolor = gray - 2]) patches with [pcolor = gray - 2] [ask neighbors4 with [pcolor != gray - 2] [set pcolor red]]]




end

to desire-paths
  ask walkers [
    let goals (turtle-set myhome other facilities)
    let visible-patches (patch-set patch-ahead 1 patch-ahead 2 patch-ahead 3 patch-ahead 4 patch-ahead 5)
    if patch-here = [patch-here] of myhome [set memory [] set goal one-of facilities]
    if patch-here = [patch-here] of goal [set memory [] set goal one-of goals]
    set memory lput patch-here memory
    face goal
    ifelse percent-of-fences = 0 [
      ifelse [pcolor] of patch-ahead 1 = red + 3 [set heading heading + 90 fd 1] [fd 1]] [
      ifelse [pcolor] of patch-ahead 1 = red [rt 2 desire-move] [ifelse [pcolor] of patch-ahead 1 = red + 3 [set heading heading + 100 fd 1] [fd 1]]
    ]
    ;if length memory > 10 [
      ;set memory remove first memory memory]
  ]
  ask patches with [pcolor = green ] [
    if any? walkers-here [set pcolor brown + 1 set popularity popularity + 100]
  ]
  ask patches with [pcolor = brown + 1 and not any? walkers-here] [
    set popularity popularity - 1
    if popularity < 1 [set pcolor green]
  ]
end




to make-guards
  if desire-way [
  ifelse mouse-down? [
    if not mouse-clicked? [
      set mouse-clicked? true
      ask patch mouse-xcor mouse-ycor [ change-guards ask patches in-radius 5 [set pcolor red + 3] ask roads in-radius 5 with [grass? = false] [set pcolor gray - 2]]]
  ] [
    set mouse-clicked? false
  ]]
end


to change-guards
  let nearby-guards guards in-radius 5
  ifelse any? nearby-guards [
    ; if there is a building near where the mouse was clicked
    ; (and there should always only be one), we remove it and
    ask nearby-guards [ die ]
  ] [
    ; if there was no buildings near where
    ; the mouse was clicked, we create one
    sprout-guards 1 [
      set color red
      set size 1
      set shape "person"
    ]
  ]
end



@#$#@#$#@
GRAPHICS-WINDOW
480
10
983
514
-1
-1
8.115
1
10
1
1
1
0
0
0
1
-30
30
-30
30
0
0
1
ticks
30.0

SLIDER
35
98
207
131
number-of-walkers
number-of-walkers
1
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
34
23
133
82
NIL
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
145
22
240
82
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
259
98
374
131
fences
fences
1
1
-1000

BUTTON
253
22
357
83
NIL
go
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
35
140
241
173
number-of-houses-with-people
number-of-houses-with-people
3
5
5.0
1
1
NIL
HORIZONTAL

SWITCH
260
139
374
172
desire-way
desire-way
1
1
-1000

SLIDER
35
182
207
215
percent-of-fences
percent-of-fences
0
100
50.0
50
1
NIL
HORIZONTAL

TEXTBOX
243
180
393
231
If desire-way \"on\", you may click at green zone and guards will appear
14
0.0
0

TEXTBOX
243
238
393
272
Do not set desire-way \"off\" while GO
14
15.0
1

@#$#@#$#@
## WHAT IS IT?

This model describes the concept of desire paths and path-finding algorithm. The model shows how do people behave in a certain environment when they have a goal to follow, for example shop, school or their home. Moreover, the model includes social control feature - guards, these are cameras or guards which are created in order to prevent the creation of desire paths in a particular place.

## HOW IT WORKS

The main rule agents follow, is following the goal. Goals are distributed randomly among all agents. First, they choose a path they will follow according to set characteristics of the environment and behavior. Then, they follow the path until they reach their goal. Finally, they change their goals and the procedure repeats.

## HOW TO USE IT

The user may regulate any settings he/she wants:
NUMBER-OF-WALKERS - set the overal number of walkers in the model
NUMBER-OF-HOUSES-WITH-PEOPLE - set the overal number of houses with people in the model. Note: houses are blue buildings
PERCENT-OF-FENCES - the value can be 0, 50, or 100. If 0, there are no fences along the roads. If 50, the green zone in the center is surrounded by red fence which restrics agents to move to this zone. If 100, agents may follow only roads. 
FENCES - creates fences if PERCENT-OF-FENCES > 0
DESIRE-WAY - the mein mechanism for investigating desire paths. If "on", agents follow brown paths which are paths created by grass erosion.

## THINGS TO TRY

First, turn off FENCES and DESIRE-WAY. Here, you can regulate the number of walkers and houses, you may see how agents move between different facilities and houses.
Second, turn on DESIRE-WAY and see how agents shorten their paths to goals, you may notice that the network of paths smoothly appear.
Third, turn on DESIRE-WAY and click anywhere in central green zone, you may see how agents go round of pink zone. It means that they are afraid of being caught by guard/camera. 
Fourth, turn on FENCES and DESIRE-WAY, and set PERCENT-OF-FENCES 50, you may notice that agents will shorten the angles, also you will see a big circle which surrounds central green zone.

## EXTENDING THE MODEL

In further work I would like to add more features of social control, the model will be more realistic when I will add collective behavior.


## RELATED MODELS

Grider, R. and Wilensky, U. (2015). NetLogo Paths model.
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

building institution
false
0
Rectangle -7500403 true true 0 60 300 270
Rectangle -16777216 true false 130 196 168 256
Rectangle -16777216 false false 0 255 300 270
Polygon -7500403 true true 0 60 150 15 300 60
Polygon -16777216 false false 0 60 150 15 300 60
Circle -1 true false 135 26 30
Circle -16777216 false false 135 25 30
Rectangle -16777216 false false 0 60 300 75
Rectangle -16777216 false false 218 75 255 90
Rectangle -16777216 false false 218 240 255 255
Rectangle -16777216 false false 224 90 249 240
Rectangle -16777216 false false 45 75 82 90
Rectangle -16777216 false false 45 240 82 255
Rectangle -16777216 false false 51 90 76 240
Rectangle -16777216 false false 90 240 127 255
Rectangle -16777216 false false 90 75 127 90
Rectangle -16777216 false false 96 90 121 240
Rectangle -16777216 false false 179 90 204 240
Rectangle -16777216 false false 173 75 210 90
Rectangle -16777216 false false 173 240 210 255
Rectangle -16777216 false false 269 90 294 240
Rectangle -16777216 false false 263 75 300 90
Rectangle -16777216 false false 263 240 300 255
Rectangle -16777216 false false 0 240 37 255
Rectangle -16777216 false false 6 90 31 240
Rectangle -16777216 false false 0 75 37 90
Line -16777216 false 112 260 184 260
Line -16777216 false 105 265 196 265

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 false 60 135 60 165
Line -7500403 false 60 120 60 165
Line -7500403 false 90 120 90 165
Line -7500403 false 120 120 120 165
Line -7500403 false 150 120 150 165
Line -7500403 false 180 120 180 165
Line -7500403 false 210 120 210 165
Line -7500403 false 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 false 257 120 257 207

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

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

person student
false
0
Polygon -13791810 true false 135 90 150 105 135 165 150 180 165 165 150 105 165 90
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 100 210 130 225 145 165 85 135 63 189
Polygon -13791810 true false 90 210 120 225 135 165 67 130 53 189
Polygon -1 true false 120 224 131 225 124 210
Line -16777216 false 139 168 126 225
Line -16777216 false 140 167 76 136
Polygon -7500403 true true 105 90 60 195 90 210 135 105

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

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tile stones
false
0
Polygon -7500403 true true 0 240 45 195 75 180 90 165 90 135 45 120 0 135
Polygon -7500403 true true 300 240 285 210 270 180 270 150 300 135 300 225
Polygon -7500403 true true 225 300 240 270 270 255 285 255 300 285 300 300
Polygon -7500403 true true 0 285 30 300 0 300
Polygon -7500403 true true 225 0 210 15 210 30 255 60 285 45 300 30 300 0
Polygon -7500403 true true 0 30 30 0 0 0
Polygon -7500403 true true 15 30 75 0 180 0 195 30 225 60 210 90 135 60 45 60
Polygon -7500403 true true 0 105 30 105 75 120 105 105 90 75 45 75 0 60
Polygon -7500403 true true 300 60 240 75 255 105 285 120 300 105
Polygon -7500403 true true 120 75 120 105 105 135 105 165 165 150 240 150 255 135 240 105 210 105 180 90 150 75
Polygon -7500403 true true 75 300 135 285 195 300
Polygon -7500403 true true 30 285 75 285 120 270 150 270 150 210 90 195 60 210 15 255
Polygon -7500403 true true 180 285 240 255 255 225 255 195 240 165 195 165 150 165 135 195 165 210 165 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

tree pine
false
0
Rectangle -6459832 true false 120 225 180 300
Polygon -7500403 true true 150 240 240 270 150 135 60 270
Polygon -7500403 true true 150 75 75 210 150 195 225 210
Polygon -7500403 true true 150 7 90 157 150 142 210 157 150 7

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
NetLogo 6.2.0
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
