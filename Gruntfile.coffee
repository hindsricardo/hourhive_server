module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffeelint:
      app: ['app/*.coffee', 'scripts/*.coffee']
      options:
        'no_trailing_whitespace':
          'level':'error'
  grunt.config 'mochaTest', require './grunt/mochaTest.coffee'
  #grunt.config 'coffeelint' require './grunt/coffeelint.coffee' # Not working as an individual unit. Maybe because its watching te base app
  grunt.loadNpmTasks 'grunt-mocha-test'
  grunt.loadNpmTasks 'grunt-coffeelint'
