### A group effort to produce a collection of base utility methods and strategies for NodeWar.

#### What's happening here?

This is Peter-- I'm just brainstorming code that we may need.  My idea is that we code up some basic ship movement patterns, and make them easy to piece together or to selectively apply.  Then when we think about strategy, we have a semi-complete codebase to cherrypick from.


#### What code utilites do we need?

* Having ships avoid walls
* Having ships avoid moons
* Having ships be able to path-find through the 3 moons.
* Have ships respect the gravity of the system and use it to get from point A to point B faster.  (i.e. gravitational whipping)

There are some more complicated multi-ship tactics we may want to code such us:

* Sharting (which is defined as: splitting up your own ships into smaller ships, so that you have more ships and that they're faster.)

* Defense:
  * Attacking oncoming enemy ships
  * Forming a "point defense field" around our queen ship.  Possibly by having multiple ships orbiting the mothership, so there's always a defender available to attack an enemy?
  * Tucking ourselves stabily near the moons for protection.

* Offense:
  * Splitting enemy ships aggressively
  * Attacking queen ships

#### Infrastructure / Other

* We may need some physics-minds think about the best way to move around the system/game-field.
* Compiling code into one file.  (This is a requirement if we want to use something like `Underscore.js` or organize our code into multiple files during development.)

#### Resources:

[http://natureofcode.com/book/chapter-6-autonomous-agents/]

[http://collabedit.com/8cvyf]

^ The code of a semi-functional bot

#### Interesting replays:

As encouragement--- this is the most recent replay of the #1 ranked player.  [http://nodewar.com/play/rec/e24b81e9e56e6334]  The cowardly pink team won.