# -----------------------------------------------------------------------------
#                         ~ The Spinara ~
#                          @malgorithms
# -----------------------------------------------------------------------------

# The spinara are cowards.
#
# This team builds an array of threats and simply
# avoids them, with extra weighting for the closer
# threats.
#

ai.step = (o) ->
  label            = null
  threats          = get_threats o
  new_target       = find_ideal_position o, threats    
  {torque, thrust} = o.lib.targeting.simpleTarget o.me, new_target
  if threats[0].threat_factor < threat_thresh then thrust = 1.0
  return { torque, thrust, label }

# Some constants -------
speed_change_fear = 50.0
my_start_pos      = null
threat_thresh     = 1.0 # if the nearest threat < this, just thrust
# ----------------------

get_threats = (o) ->
  threats = []
  
  
  # nearest moon
  threats.push {
    pos:  o.moons[0].pos
    vel:  o.moons[0].vel
    dist: o.moons[0].dist - o.moons[0].radius # the surface of the moon
    type: 'moon'
  }

  # nearest ship
  for s in o.ships
    if true #(not s.friendly)
      threats.push {
        pos:  s.pos
        dist: s.dist
        vel:  s.vel  
        type: if s.friendly then 'friendly_ship' else 'enemy_ship'
      }
      break

  # nearest edge of board
  [radius, angle] = o.lib.vec.toPolar o.me.pos
  edge = o.lib.vec.fromPolar [o.game.moon_field, angle]
  threats.push {
    pos: edge
    dist: o.lib.vec.dist o.me.pos, edge
    vel: [0,0]
    type: 'edge'
  }
  
  # edge of board heading towards
  exit = get_board_exit_pos o
  threats.push {
    pos: exit
    dist: o.lib.vec.dist o.me.pos, exit
    vel: [0,0]
    type: 'exit'
  }
  
  # where I started, so I disperse
  if not my_start_pos? then my_start_pos = o.me.pos
  threats.push {
    pos: my_start_pos
    dist: o.lib.vec.dist o.me.pos, my_start_pos
    vel: [0,0]
    type: 'start_pos'
  }
    
  # now for each threat, figure out some more stuff
  for t in threats
    t.rel_vel       = o.lib.vec.diff o.me.vel, t.vel
    t.speed_toward  = o.lib.physics.speedToward(t.rel_vel, o.me.pos, t.pos) + speed_change_fear
    t.time_threat   = if t.speed_toward > 0 then t.dist / t.speed_toward else Infinity
    t.dir           = o.lib.targeting.dir o.me, t.pos
    t.threat_factor = threat_factor t
  
  threats.sort (a,b) -> b.threat_factor - a.threat_factor
  

threat_factor = (t) ->
  res = 1 / t.time_threat
  res = res * res
  if      t.type is "moon"          then res *= 2  # moons also suck us in
  else if t.type is "friendly_ship" then res /= 16 # hitting a ship isn't the end of the world
  else if t.type is "enemy_ship"    then res /= 2  # hitting a ship isn't the end of the world
  res

find_ideal_position = (o, threats) ->
  # for each threat, let's try to move the ship
  # 1 unit in the direction away from it. And let's
  # average all these desires together, weighted by the
  # magnitude of the threat. As mentioned, the Spinara are
  # cowards.
  total_weight = 0
  target = [0,0]
  for t in threats  
    target_diff = o.lib.vec.diff o.me.pos, t.pos          # the vec from the threat to me    
    n_diff      = o.lib.vec.normalized target_diff        # normalized
    diff        = o.lib.vec.times n_diff, t.threat_factor # now multiply by the threat weighting    
    total_weight += t.threat_factor
    target[0] += diff[0]
    target[1] += diff[1]
  target[0] /= total_weight
  target[1] /= total_weight
  return o.lib.vec.sum o.me.pos, target

get_board_exit_pos = (o) ->
    t    = 0
    dt   = 0.05
    ddt  = 0.025
    maxt = 10
    [vx,vy] = o.me.vel
    [px,py] = o.me.pos
    rad_sq = o.game.moon_field * o.game.moon_field
    while (t < maxt) and (px * px + py * py < rad_sq)
      t += dt
      px += vx * dt
      py += vy * dt
      dt += ddt
    return [px,py]
  