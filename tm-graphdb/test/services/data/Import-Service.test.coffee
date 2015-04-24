Import_Service = require('./../../../src/services/data/Import-Service')
async          = require('async')

describe '| services | data | Import-Service.test', ->

  describe 'core', ->
    importService = null

    before ->
      importService = new Import_Service(name: 'Import-Service.test')

    after (done)->
      importService.graph.deleteDb ->
        #importService.cache.cacheFolder().folder_Delete_Recursive()
        done()

    it 'check ctor()', ->
      Import_Service.assert_Is_Function()
      importService             .assert_Is_Object()
      importService.name        .assert_Is_String()
      #importService.cache       .assert_Is_Object()#.assert_Instance_Of()
      importService.graph       .assert_Is_Object()
      importService.path_Root   .assert_Is_String()
      importService.path_Name   .assert_Is_String()

      importService.name        .assert_Is 'Import-Service.test'
      importService.path_Root   .assert_Is('.tmCache')
      importService.path_Name   .assert_Is('.tmCache/Import-Service.test')
      importService.path_Name.folder_Delete_Recursive().assert_Is_True()

    it 'check ctor (name)', (done)->
      aaaa_ImportService  = new Import_Service(name: 'aaaa')
      aaaa_ImportService.name         .assert_Is 'aaaa'
      aaaa_ImportService.path_Name    .assert_Is '.tmCache/aaaa'
      aaaa_ImportService.graph.dbName .assert_Is 'aaaa'
      aaaa_ImportService.graph.deleteDb ->
        #aaaa_ImportService.cache.cacheFolder().folder_Delete_Recursive()
        done()

    it 'setup', (done)->
      importService.setup.assert_Is_Function()
      (importService.graph.db is null).assert_Is_True()
      importService.setup ->
        importService.graph.dbPath.assert_That_File_Exists()
        done()




