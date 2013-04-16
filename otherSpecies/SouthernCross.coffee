find_ideal_position = undefined
get_Label = undefined
get_board_exit_pos = undefined
get_threats = undefined
is_alone = undefined
queen_A = undefined
threat_factor = undefined
speed_change_fear = 60.0
my_start_pos = null
min_tot_weight = 0.07
threat_thresh = 15 #if the nearest threat < this, just thrust
ai.step = (o) ->
  label = null
  new_target = undefined
  threats = undefined
  thrust = undefined
  torque = undefined
  _ref = undefined
  
  #lets initially shard some ships
  #queens = 0 and 6
  sharders = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
  if lets_shard(o) and sharders.indexOf(o.me.ship_id) isnt -1
    unless is_small(o.me)
      _ref = o.lib.targeting.simpleTarget(o.me, get_center_of_near_friendlies(o, sharders))
      torque = _ref.torque
      thrust = _ref.thrust
  else if lets_cross and not o.me.queen
    # odds go north
    # evens go south
    # queens stays
    updown = 1
    if o.lib.math.mod(o.me.ship_id, 2) == 0
      updown = -1
    _ref = o.lib.targeting.simpleTarget(o.me, [0, o.game.moon_field * (0.75) * updown])
    torque = _ref.torque
    thrust = _ref.thrust * 0.5
    label = "crossing"
  else
    label = "attack"
    threats = get_threats(o)
    new_target = find_ideal_position(o, threats)
    _ref = o.lib.targeting.simpleTarget(o.me, new_target)
    torque = _ref.torque
    thrust = _ref.thrust

    thrust = 1.0  if threats[0].threat_factor < threat_thresh
  torque: torque
  thrust: thrust
  label: label
  #null #Math.round(o.me.area_frac * 100)/100//threats[0].type + ": " + Math.round(threats[0].threat_factor)

lets_shard = (o) ->
  if o.game.time < 2 then true else false

lets_cross = (o) ->
  if o.game.time >= 2 and o.game.time < 4 then true else false


get_aggression = (o, threat) ->
  a = 9 #default aggression
  if o.me.queen and is_alone(o) #more aggressive if only queen
    a += 20
  else if is_small(o.me) #more aggressive if small and game is afoot
    a += 10  if o.game.time > 8
    a += 10  if threat.dist < 100 #more aggressive if close!
  a *= 10  if o.me.invincible #crazy aggressive if invincible
  a

get_center_of_near_friendlies = (o, limit_to) ->
  _ref = o.ships
  near_bigs = []
  _i = 0
  _len = _ref.length

  while _i < _len
    s = _ref[_i]
    near_bigs.push s.pos  if not s.queen and s.friendly and not is_small(s) and limit_to.indexOf(s.ship_id) isnt -1
    _i++
  o.lib.vec.center near_bigs

get_max_ship_area = (o) ->
  _ref = o.ships
  max = 0
  _i = 0
  _len = _ref.length

  while _i < _len
    s = _ref[_i]
    max = (if s.area > max then s.area else max)  unless s.queen
    _i++
  max

is_small = (ship) ->
  (if ship.area_frac < 0.5 then 1 else 0)

is_big = (ship) ->
  (if ship.area_frac > 0.7 then 1 else 0)

get_threats = (o) ->
  angle = undefined
  edge = undefined
  exit = undefined
  radius = undefined
  s = undefined
  t = undefined
  _i = undefined
  _j = undefined
  _len = undefined
  _len1 = undefined
  _ref = undefined
  _ref1 = undefined
  threats = []
  
  #nearest moon
  threats.push
    pos: o.moons[0].pos
    vel: o.moons[0].vel
    dist: o.moons[0].dist - o.moons[0].radius
    type: "moon"

  
  #disperse after sharding... but after a while
  unless lets_shard(o)
    my_start_pos = o.me.pos  if my_start_pos is null
    threats.push
      pos: my_start_pos
      dist: o.lib.vec.dist(o.me.pos, my_start_pos)
      vel: [0, 0]
      type: "start_pos"

  
  #all ships
  _ref = o.ships
  _i = 0
  _len = _ref.length

  while _i < _len
    s = _ref[_i]
    threats.push
      pos: s.pos
      dist: s.dist
      vel: s.vel
      type: (if s.friendly then "friendly_ship" else (if s.queen and not o.me.queen then "target" else "enemy_ship"))
      ship: s

    _i++
  
  #nearest edge of board
  _ref1 = o.lib.vec.toPolar(o.me.pos)
  radius = _ref1[0]
  angle = _ref1[1]

  edge = o.lib.vec.fromPolar([o.game.moon_field, angle])
  threats.push
    pos: edge
    dist: o.lib.vec.dist(o.me.pos, edge)
    vel: [0, 0]
    type: "edge"

  
  #edge of board heading towards
  exit = get_board_exit_pos(o)
  threats.push
    pos: exit
    dist: o.lib.vec.dist(o.me.pos, exit)
    vel: [0, 0]
    type: "exit"

  
  #now for each threat, figure out some more stuff
  _j = 0
  _len1 = threats.length

  while _j < _len1
    t = threats[_j]
    t.rel_vel = o.lib.vec.diff(o.me.vel, t.vel)
    t.speed_toward = o.lib.physics.speedToward(t.rel_vel, o.me.pos, t.pos) + speed_change_fear
    t.time_threat = (if t.speed_toward > 0 then t.dist / t.speed_toward else Infinity)
    t.dir = o.lib.targeting.dir(o.me, t.pos)
    t.threat_factor = threat_factor(o, t)
    _j++
  threats.sort (a, b) ->
    b.threat_factor - a.threat_factor



# Is the Queen the Last man standing?
is_alone = (o) ->
  s = undefined
  _i = undefined
  _len = undefined
  _ref = undefined
  _ref = o.ships
  _i = 0
  _len = _ref.length

  while _i < _len
    s = _ref[_i]
    false  if s.friendly and s.alive and not o.me.queen
    _i++
  true

threat_factor = (o, t) ->
  res = 1 / t.time_threat
  res = res * res
  aggression = get_aggression(o, t)
  if t.type is "moon" #moons are scary
    if o.me.queen #more if you're the queen
      res = res * 25
    else
      res = res * 20
      res = (if is_small(o.me) then res / 1.3 else res) #less if kamikaze
  else if t.type is "edge" #edges are often scary
    if o.me.queen #more if you're the queen
      res = res * 12
    else
      res = res * 10
      res = (if is_small(o.me) then res / 1.3 else res) #less if kamikaze
  else if t.type is "friendly_ship" #hitting a ship isn't the end of the world
    if t.ship.queen
      res = res * 2 #stay away from the queen!
    else
      if o.me.queen and lets_shard(o)
        res = res * 20 #the queen should be wary of sharders!
      else if is_small(t.ship) #don't try and shard small friendlies (or they'll dust away)
        res = res / 8
      else
        res = res / (16 + aggression)
  else if t.type is "enemy_ship" #hitting an enemy is usually good
    if o.me.queen #more fear if you're the queen
      res = res / 2
    else
      if is_small(o.me) and is_big(t.ship) #lets seek out big ships if we're small!
        res *= -1
      else
        res = res / (2 * aggression)
  else if t.type is "target" #kill it with fire!
    res = (res * -0.4) - aggression
    res -= (aggression * 3)  if o.me.queen #queen on queen action is okay
  res

find_ideal_position = (o, threats) ->
  
  #for each threat, let's try to move the ship
  #  1 unit in the direction away from it. And let's
  #  average all these desires together, weighted by the
  #  magnitude of the threat. As mentioned, the Spinara are
  #  cowards.
  diff = undefined
  n_diff = undefined
  t = undefined
  target = undefined
  target_diff = undefined
  total_weight = undefined
  _i = undefined
  _len = undefined
  total_weight = 0
  target = [0, 0]
  _i = 0
  _len = threats.length

  while _i < _len
    t = threats[_i]
    target_diff = o.lib.vec.diff(o.me.pos, t.pos) #the vec from the threat to me
    n_diff = o.lib.vec.normalized(target_diff) #normalized
    diff = o.lib.vec.times(n_diff, t.threat_factor) #now multiply by the threat weighting
    total_weight += t.threat_factor
    target[0] += diff[0]
    target[1] += diff[1]
    _i++
  total_weight = min_tot_weight  if total_weight < min_tot_weight
  target[0] /= total_weight
  target[1] /= total_weight
  o.lib.vec.sum o.me.pos, target

get_board_exit_pos = (o) ->
  ddt = undefined
  dt = undefined
  maxt = undefined
  px = undefined
  py = undefined
  rad_sq = undefined
  t = undefined
  vx = undefined
  vy = undefined
  _ref = undefined
  _ref1 = undefined
  t = 0
  dt = 0.05
  ddt = 0.025
  maxt = 10
  _ref = o.me.vel
  vx = _ref[0]
  vy = _ref[1]

  _ref1 = o.me.pos
  px = _ref1[0]
  py = _ref1[1]

  rad_sq = o.game.moon_field * o.game.moon_field
  while (t < maxt) and (px * px + py * py < rad_sq)
    t += dt
    px += vx * dt
    py += vy * dt
    dt += ddt
  [px, py]