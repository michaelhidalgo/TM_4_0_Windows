#Graph_Add_Data = require('./../../../src/services/graph/Graph-Add-Data')
Import_Service = require('./../../../src/services/data/Import-Service')

describe '| services | graph | Graph-Add_Data.test', ->
  importService = null

  before (done)->
    importService = new Import_Service(name: 'Graph-Add_Data.test')
    importService.setup ->
      done()

  after (done)->
    importService.graph.deleteDb ->
      #importService.cache.cacheFolder().folder_Delete_Recursive()
      done()

  it 'add_Db and get_Subject', (done)->
    type = 'test'
    guid = "aaaa-bbbc-cccc-dddd"
    data = { b:'c_'.add_Random_Letters() , d: 'e_'.add_5_Random_Letters()}
    importService.graph_Add_Data.add_Db type, guid, data, (id)->
      importService.graph_Find.get_Subject_Data id, (id_Data)->
        id_Data.assert_Is_Object()
        id_Data.b.assert_Is(data.b)
        id_Data.d.assert_Is(data.d)
        done()

  it 'add_Is, find_Using_Is', (done)->
    id    = 'is_id'
    value = 'is_value'
    importService.graph_Add_Data.add_Is id, value, ->
      importService.graph_Find.find_Using_Is value, (data)->
        data.first().assert_Is(id)
        done()

  it 'add_Is, find_Using_Title', (done)->
    id    = 'title_id'
    value = 'title_value'
    importService.graph_Add_Data.add_Title id, value, ->
      importService.graph_Find.find_Using_Title value, (data)->
        data.first().assert_Is(id)
        done();

  it 'new_Data_Import_Util', ->
    importService.graph_Add_Data.new_Data_Import_Util.assert_Is_Function()
    importService.graph_Add_Data.new_Data_Import_Util().assert_Is_Object()

  it 'new_Short_Guid', ->
    importService.graph_Add_Data.new_Short_Guid.assert_Is_Function()
    importService.graph_Add_Data.new_Short_Guid('aaa').starts_With('aaa').assert_Is_True()
    importService.graph_Add_Data.new_Short_Guid('bbb','b56ddd610d9e'    ).assert_Is('bbb-b56ddd610d9e')