module.exports = (grunt) ->
  
  # Project configuration.
  grunt.initConfig
    simplemocha:
      options:
        globals: ["should"]
        timeout: 3000
        ignoreLeaks: false
        ui: "bdd"
        reporter: "tap"

      all:
        src: "test/**/*.coffee"



  grunt.loadNpmTasks "grunt-simple-mocha"
  grunt.registerTask "default", "simplemocha"
  grunt.registerTask "test", "simplemocha"