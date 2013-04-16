# -----------------------------------------------------------------------------
#                         ~ Alpha Roger Bots ~
#                          @pconerly
# -----------------------------------------------------------------------------

# * Having ships avoid walls
# * Having ships avoid moons
# * Having ships be able to path-find through the 3 moons.
# * Have ships respect the gravity of the system and use it to get from point A to point B faster.  
#   (i.e. gravitational whipping)

class Util
  o: null

  constructor: (o) ->
    @o = o

  square: (x) ->
    x*x

  distance: (pos, target) ->
    Math.sqrt(square(pos[0] - target[0]) + square(pos[1] - target[1]))

  hypotenous: (pos) ->
    @distance(pos, [0,0])

  sideFromArea:(area) ->
    # for an equilateral triangle
    # http://en.wikipedia.org/wiki/Equilateral_triangle
    return Math.sqrt((area * 4)/ Math.sqrt(3))

  circumscribedRadius: (side) ->
    return side * Math.sqrt(3) * (1/3)

  inscribedRadius: (side) ->
    return @circumscribedRadius(side) / 2

  averageRadius: (side) ->
    return side * Math.sqrt(3) * (1/3) * (3/4)

  avgRadiusFromArea: (area) ->
    @averageRadius @sideFromArea(area)




# ai = ai or {}

ai.step = (o) ->
  o.mothership.util ?= Util(o)

  return stepDrone(o)
  # return {
  #   thrust: 0.5
  #   torque: 1
  #   label: o.me.area
  #   log: o.me.mass
  # }


# circle calculations
# is the o.me.pos + o.me.vel * 2 outside of the game field
# or inside the moon


outsideGameField = (o, pos) ->
  if o.mothership.util.hypotenous(pos) - 10 > o.game.moon_field
    return true
  else
    return false


stepDrone = (o) ->
  # find current position
  # x + 1 position
  # x + 2 position
  positions = [o.me.pos, o.me.pos + o.me.vel*1, o.me.pos + o.me.vel*2]

  # calculate game field limit
  goingOut = false
  # shootTheMoon = false
  for p in positions
    goingOut = goingOut or outsideGameField(p)

  if goingOut
    # find how far to turn in either direction to avoid game field exit
    avgRadiusFromArea(o.me.area)

  else
    return {
      torque: torque
      thrust: '.5'
      label: 'queen' 
    }



