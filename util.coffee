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

  momentOfInertia: (mass, area) ->
    mass * @square(@avgRadiusFromArea(area))

  avgRadiusFromArea: (area) ->
    @averageRadius @sideFromArea(area)

module.exports = Util