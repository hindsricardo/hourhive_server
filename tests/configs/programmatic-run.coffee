module.exports = (mocha) ->
  fs = require 'fs'
  path = require 'path'

  testDir = './tests/unit'

  #Add each .test.coffee  to mocha instance
  fs.readdirSync(testDir).filter( (file)->
    #Only keep the .test.coffee files
    return file.substr(-7) == '.coffee')
    .forEach (file) ->
      mocha.addFile path.join testDir, file

  #Run the test
    mocha.run (failures) ->
      process.on 'exit', ->
        process.exit failures
