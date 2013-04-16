should = require 'should'

Util = require('../util')

util = new Util({})

describe 'util', ->
  describe 'module', ->
    it 'exists', (done) ->
      should.exist util
      done()

  describe 'torque', ->
    it 'knows how to get to 1rad/sec', (done) ->
      ship = {
        area: 11.8125
        mass: 11.8125
      }
      I = util.momentOfInertia(ship.mass, ship.area)
      torque = I * 1
      console.log torque
      should.exist torque
      done()

  # describe 'module', ->
  #   it 'exists', (done) ->
  #     should.exist util
  #     done()


# describe 'util', ->
  