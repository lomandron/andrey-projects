globals [baby-bonus-size living-wage my-list list-rich list-mid list-poor]

breed [households household]
breed [children child]

households-own [salary salary-group education n-of-children age age-group first-birth-age parent-first-birth-age attitude attitude-want attitude-not-want subjective-norm perceived-control parent? b1 b2 b3 loan-size flat]
children-own [age age-group parent-first-birth-age parent-income flat]
turtles-own [who-parent parent-edu home-patch]
patches-own [territory]

to setup
  clear-all
  reset-ticks
  patches-color
  set my-list []
  set list-rich []
  set list-mid []
  set list-poor []
  create-households number-of-households [
    kek
  ]
  set baby-bonus-size 600000
  regions
  age-distribution
  edu-distribution
  ask n-of (0.3 * number-of-households) households [set flat "yes"]
  ask households with [age > 45] [
    set first-birth-age 24
    set parent? true
  ]


end

to patches-color
  ask patches with [pxcor >= -16] [set pcolor red + 2.5 set territory "poor"]
  ask patches with [pxcor >= -6 and pxcor < 6] [set pcolor red + 1.5 set territory "middle"]
  ask patches with [pxcor >= 6 and pxcor <= 16] [set pcolor red set territory "rich"]
  ask patches with [pxcor = 11 and pycor = 16 ] [ set plabel "rich" ]
  ask patches with [pxcor = 0 and pycor = 16 ] [ set plabel "middle" ]
  ask patches with [pxcor = -11 and pycor = 16 ] [ set plabel "poor" ]
end

to kek
  set flat "no"
  set color green
  set shape "house"
  set parent? false
  set attitude-want 0
  set attitude-not-want 0
  set subjective-norm 0
  set perceived-control 0
  set parent-first-birth-age 24
  set b1 attitude-weight
  set b2 sn-weight
  set b3 pbc-weight

end


to go
  tick
  ask turtles [
    death
    set age age + 1
    if age = 21 [graduate]
    change-age-group]
  become-a-household
  check
  update-fertility
  update-children

end

to update-fertility

  set my-list lput precision (count children / count households) 3 my-list


end

to update-children
;  if any? children-on patches with [territory = "rich"] [
;  set list-rich lput precision (count children-on patches with [territory = "rich"] / count households-on patches with [territory = "rich"]) 3 list-rich
;  ]
;
;  if any? children-on patches with [territory = "middle"] [
;  set list-mid lput precision (count children-on patches with [territory = "middle"] / count households-on patches with [territory = "middle"]) 3 list-mid
;  ]
;  if any? children-on patches with [territory = "poor"] [
;  set list-poor lput precision (count children-on patches with [territory = "poor"] / count households-on patches with [territory = "poor"]) 3 list-poor

  if any? children with [parent-income = "high"] [
  set list-rich lput precision (count children with [parent-income = "high"] / count households with [salary-group = "high"]) 3 list-rich
  ]
  if any? children with [parent-income = "mid"][
  set list-mid lput precision (count children with [parent-income = "mid"] / count households with [salary-group = "mid"]) 3 list-mid
  ]
  if any? children with [parent-income = "low"] [
  set list-poor lput precision (count children with [parent-income = "low"] / count households with [salary-group = "low"]) 3 list-poor
;  set list-rich lput mean [n-of-children] of households-on patches with [territory = "rich"] list-rich
;  set list-mid lput mean [n-of-children] of households-on patches with [territory = "middle"] list-mid
;  set list-poor lput mean [n-of-children] of households-on patches with [territory = "poor"] list-poor
  ]
end

to become-a-household
  ask children with [age = 16] [
    set breed households
    set color green
    set shape "house"
    set parent? false
    set education "lower"
    set b1 attitude-weight
    set b2 sn-weight
    set b3 pbc-weight
    set salary living-wage
    (foreach ["moscow" "len.obl" "perm" "kostroma"] [4583333 1833333 1100000 1008333][ [a b] -> if region = a [set loan-size b]])
  ]
end



to change-age-group
  (ifelse
    (age > 0 and age <= 15) [set age-group "zero"]
    (age > 15 and age < 30) [set age-group "first"]
    (age >= 30 and age < 50) [set age-group "second"]
    (age >= 50 and age < 80) [set age-group "third"]
    [set age-group "fourth"]
  )

end

to death ;probability of death
  ( ifelse
    (age > 0 and age < 14) [ if random 10000 < 7 [die] ]
    (age > 15 and age < 29) [ if random 1000 < 1 [die] ]
    (age > 30 and age < 49) [ if random 1000 < 4 [die] ]
    (age > 50 and age < 79) [ if random 100 < 2 [die] ]
    (age > 80 and age < 100) [ if random 100 < 11 [die] ]
    (age > 100) [if random 100 < 50 [die]]
  )
end

to check
  ask households [
    if n-of-children <= 7 [birth]
  ]
end


to birth

  if age >= 16 and age <= 45 [
    ifelse tpb [
      check-pbc
      check-subjective-norm
      check-attitude
      let intention (b1 * attitude) + (b2 * subjective-norm) + (b3 * perceived-control)
      if intention > intention-threshold [childbearing]

    ]
    [childbearing]


  ]
end

to childbearing
  hatch-children 1 [
    move-to one-of patches with [territory = [territory] of [patch-here] of myself]
    set color white
    set shape "person"
    ;set size ([size] of myself / 2)
    set age 1
    set age-group "zero"
    set who-parent [who] of myself
    set parent-income [salary-group] of myself
    ifelse [flat] of household who-parent = "yes" [set flat "yes"] [set flat "no"]
    set parent-first-birth-age [age] of household who-parent
    set parent-edu [education] of myself
  ]
  set parent? true

  set n-of-children n-of-children + 1
  if n-of-children = 1 [
    set first-birth-age age]

end

to check-attitude

  if age >= 16 and age <= 18 [
    ifelse member? parent-edu ["higher" "middle"] [
      set attitude-want 0
      set attitude-not-want one-of (range 50 100 10)
    ] [
      set attitude-want 50
      set attitude-not-want 50
    ]
  ]
  if age > 18 and age <= 25 [
    set attitude-want one-of (range 50 100 10)
    set attitude-not-want one-of (range 50 100 10)
  ]
  if age > 25 [
    set attitude-want one-of (range 75 100)
    set attitude-not-want one-of (range 25 100)
  ]
  set attitude (attitude-want - attitude-not-want)
  if flat = "no" and baby-bonus [
    if baby-bonus-size / loan-size > 0.5 [set attitude 100]
  ]

end

to check-subjective-norm

  let avg-birth-age mean [first-birth-age] of households with [parent?]
  let diff-age (avg-birth-age - age)
  if diff-age > 5 [set subjective-norm 0]
  if diff-age < 3 and diff-age > 1 [set subjective-norm one-of (range 0 50 10)]
  if diff-age < 1 and diff-age > -1 [set subjective-norm one-of (range 50 100 25)]
  if diff-age < -1 and diff-age > -3 [set subjective-norm one-of (range 50 100 10)]
  if diff-age < -3 and diff-age > -5 [set subjective-norm one-of (range 0 50 10)]
  if diff-age < -5 [set subjective-norm 0]
end

to check-pbc
  if not baby-bonus [
    (foreach ["higher" "middle" "lower"] [450000 400000 350000][
      [a b] ->
      if education = a [
        let child-basket b
        set perceived-control (1 - (child-basket / (salary * 2))) * 100 ]])]

  if baby-bonus [
    (foreach ["higher" "middle" "lower"] [450000 400000 350000][
      [a b] ->
      if education = a [
        let child-basket b
        set perceived-control (1 - (child-basket / (salary * 2 + (baby-bonus-size / 4)))) * 100 ]])] ;
end


to graduate

  ifelse random 100 < 80 [set education parent-edu] [set education one-of ["lower" "middle" "higher"]]
  get-salary

end

to get-salary

  if region = "moscow" [
    set salary random-normal 800000 160000
    (ifelse
        (salary <= 640000) [ set salary-group "low"]
        (salary >= 640000 and salary < 960000) [ set salary-group "mid"]
        (salary >= 960000) [ set salary-group "high"]
      )
  ]
  if region = "len.obl" [
    set salary random-normal 500000 100000
    (ifelse
        (salary <= 400000) [ set salary-group "low"]
        (salary >= 400000 and salary < 600000) [ set salary-group "mid"]
        (salary >= 600000) [ set salary-group "high"]
      )
  ]
  if region = "perm" [
    set salary random-normal 400000 80000
     (ifelse
        (salary <= 320000) [ set salary-group "low"]
        (salary >= 320000 and salary < 480000) [ set salary-group "mid"]
        (salary >= 480000) [ set salary-group "high"]
      )
  ]
  if region = "kostroma" [
    set salary random-normal 300000 60000
    (ifelse
        (salary <= 240000) [ set salary-group "low"]
        (salary >= 240000 and salary < 360000) [ set salary-group "mid"]
        (salary >= 360000) [ set salary-group "high"]
      )
  ]

end

to age-distribution

  ask n-of (0.2 * number-of-households) households [
    set age one-of (range 15 29)
    set age-group "first"
  ]
  ask n-of (0.37 * number-of-households) households with [age-group != "first"] [
    set age one-of (range 30 49)
    set age-group "second"
  ]
  ask n-of (0.38 * number-of-households) households with [age-group != "first" and age-group != "second"] [
    set age one-of (range 50 79)
    set age-group "third"
  ]
  ask n-of (0.05 * number-of-households) households with [age-group != "first" and age-group != "second" and age-group != "third"] [
    set age one-of (range 80 100)
    set age-group "fourth"
  ]
  ask households [
    if age = 0 [
      set age one-of (range 15 100)
    ]
  ]
  ask households [change-age-group]
end

to edu-distribution
; high income
  let working-households households with [age >= 21]
  let high-income-households working-households with [salary-group = "high"]
  ask n-of (floor (0.6 * count high-income-households)) high-income-households [
    set education "higher"
  ]
  ask n-of (floor (0.25 * count high-income-households)) high-income-households with [education != "higher"] [
    set education "middle"
  ]
  ask n-of (floor (0.15 * count high-income-households)) high-income-households with [education != "higher" and education != "middle"] [
    set education "lower"
  ]
  ask high-income-households with [education = 0] [set education "lower"]


; mid income
  let mid-income-households working-households with [salary-group = "mid"]
  ask n-of (floor (0.3 * count mid-income-households)) mid-income-households [
    set education "higher"
  ]
  ask n-of (floor (0.45 * count mid-income-households)) mid-income-households with [education != "higher"] [
    set education "middle"
  ]
  ask n-of (floor (0.25 * count mid-income-households)) mid-income-households with [education != "higher" and education != "middle"] [
    set education "lower"
  ]
  ask mid-income-households with [education = 0] [set education "lower"]

; low income
  let low-income-households working-households with [salary-group = "low"]
  ask n-of (floor (0.15 * count low-income-households)) low-income-households [
    set education "higher"
  ]
  ask n-of (floor (0.25 * count low-income-households)) low-income-households with [education != "higher"] [
    set education "middle"
  ]
  ask n-of (floor (0.6 * count low-income-households)) low-income-households with [education != "higher" and education != "middle"] [
    set education "lower"
  ]
  ask low-income-households with [education = 0] [set education "lower"]

end

to regions
  ; salary is counted for the year
  set living-wage 144000
  if region = "moscow" [
    ask households [
      set salary random-normal 800000 160000
      set loan-size 4583333
      (ifelse
        (salary <= 640000) [move-to one-of patches with [pcolor = red + 2.5] set salary-group "low"]
        (salary >= 640000 and salary < 960000) [move-to one-of patches with [pcolor = red + 1.5] set salary-group "mid"]
        (salary >= 960000) [move-to one-of patches with [pcolor = red] set salary-group "high"]
      )
    ]
  ]

  if region = "len.obl" [
   ask households [
      set salary random-normal 500000 100000
      set loan-size 1833333
      (ifelse
        (salary <= 400000) [move-to one-of patches with [pcolor = red + 2.5] set salary-group "low"]
        (salary >= 400000 and salary < 600000) [move-to one-of patches with [pcolor = red + 1.5] set salary-group "mid"]
        (salary >= 600000) [move-to one-of patches with [pcolor = red] set salary-group "high"]
      )
    ]
  ]
  if region = "perm" [
   ask households [
      set salary random-normal 400000 80000
      set loan-size 1100000
      (ifelse
        (salary <= 320000) [move-to one-of patches with [pcolor = red + 2.5] set salary-group "low"]
        (salary >= 320000 and salary < 480000) [move-to one-of patches with [pcolor = red + 1.5] set salary-group "mid"]
        (salary >= 480000) [move-to one-of patches with [pcolor = red] set salary-group "high"]
      )
    ]
  ]
  if region = "kostroma" [
   ask households [
      set salary random-normal 300000 60000
      set loan-size 1008333
      (ifelse
        (salary <= 240000) [move-to one-of patches with [pcolor = red + 2.5] set salary-group "low"]
        (salary >= 240000 and salary < 360000) [move-to one-of patches with [pcolor = red + 1.5] set salary-group "mid"]
        (salary >= 360000) [move-to one-of patches with [pcolor = red] set salary-group "high"]
      )
    ]
  ]
end

@#$#@#$#@
GRAPHICS-WINDOW
235
20
633
419
-1
-1
11.82
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
27
58
105
91
NIL
setup\n
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
50
99
168
132
go one year
go\n
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
12
20
213
53
number-of-households
number-of-households
1
100
100.0
1
1
NIL
HORIZONTAL

CHOOSER
11
138
210
183
region
region
"moscow" "len.obl" "perm" "kostroma"
3

MONITOR
648
10
749
55
with children
count households with [parent?]
17
1
11

MONITOR
749
10
850
55
without children
count households with [parent? = false]
17
1
11

BUTTON
126
58
189
91
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

PLOT
1007
66
1267
242
Age distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"15-29" 1.0 0 -11221820 true "" "plot count turtles with [age-group = \"first\"]"
"30-49" 1.0 0 -987046 true "" "plot count turtles with [age-group = \"second\"]"
"50-79" 1.0 0 -2674135 true "" "plot count turtles with [age-group = \"third\"]"
"80+" 1.0 0 -955883 true "" "plot count turtles with [age-group = \"fourth\"]"

MONITOR
1266
66
1316
111
15-29
count turtles with [age-group = \"first\"]
17
1
11

MONITOR
1266
110
1316
155
30-49
count turtles with [age-group = \"second\"]
17
1
11

MONITOR
1266
154
1316
199
50-79
count turtles with [age-group = \"third\"]
17
1
11

MONITOR
1266
198
1316
243
80+
count turtles with [age-group = \"fourth\"]
17
1
11

MONITOR
1007
10
1117
55
N people
count turtles
17
1
11

MONITOR
1117
10
1207
55
N kids
count children
17
1
11

MONITOR
1206
10
1316
55
N households
count households
17
1
11

BUTTON
321
430
530
463
technical reset
ask turtles [stop-inspecting self] 
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
904
109
983
154
fertility rate
mean (my-list)
5
1
11

SWITCH
11
189
101
222
tpb
tpb
0
1
-1000

MONITOR
1193
241
1316
286
oldest person
max [age] of turtles
17
1
11

MONITOR
648
65
773
110
mean-age-first-birth
mean [first-birth-age] of households with [parent?]
3
1
11

SWITCH
89
189
210
222
baby-bonus
baby-bonus
0
1
-1000

PLOT
648
109
906
298
Fertility Rate
NIL
NIL
0.0
10.0
0.0
3.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean (my-list)"

MONITOR
1006
289
1164
334
avg yearly salary
min [salary] of households
2
1
11

MONITOR
1006
333
1243
378
avg yearly earnings of uni graduates
mean [salary] of households with [education = \"higher\"]
2
1
11

SLIDER
12
241
210
274
intention-threshold
intention-threshold
0
100
40.0
1
1
NIL
HORIZONTAL

MONITOR
648
317
811
362
avg kids in rich families
mean(list-rich)
3
1
11

MONITOR
648
361
811
406
avg kids in middle class
mean(list-mid)
3
1
11

MONITOR
648
405
811
450
avg kids in poor families
mean(list-poor)
3
1
11

SLIDER
12
287
208
320
attitude-weight
attitude-weight
0.1
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
12
322
208
355
sn-weight
sn-weight
0.1
1
0.3
0.1
1
NIL
HORIZONTAL

SLIDER
12
358
208
391
pbc-weight
pbc-weight
0.1
1
0.4
0.1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(1st strategy is when agents born children if age is more than 16 and less than 45)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
