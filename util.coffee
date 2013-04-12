# -----------------------------------------------------------------------------
#                         ~ Alpha Roger Bots ~
#                          @pconerly
# -----------------------------------------------------------------------------

# * Having ships avoid walls
# * Having ships avoid moons
# * Having ships be able to path-find through the 3 moons.
# * Have ships respect the gravity of the system and use it to get from point A to point B faster.  
#   (i.e. gravitational whipping)


ai.step = (o) ->

  if o.me.queen
    return stepQueen(o)
  else
    return stepDrone(o)



  label            = null
  threats          = get_threats o
  new_target       = find_ideal_position o, threats    
  {torque, thrust} = o.lib.targeting.simpleTarget o.me, new_target
  if threats[0].threat_factor < threat_thresh then thrust = 1.0
  return { 
    torque: torque
    thrust: thrust
    label: label 
  }


stepQueen = (o) ->
  return

stepDrone = (o) ->
  return

square = (x) ->
  x*x

distance = (pos, target) ->
  Math.sqrt(square(pos[0] - target[0]) + square(pos[1] - target[1]))


findWall = (o) ->
  pos = o.me.pos
  ## find distance from center.
  distFromCenter = Math.sqrt(pos[0]**2 + pos[1]**2)
  ## find angle from center.


  return #distance, direction



