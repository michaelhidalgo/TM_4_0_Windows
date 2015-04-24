Import_Service = require('./../../src/services/data/Import-Service')

describe '| regression-tests | tests-1',->
  importService  = null
  library_Data   = null

  before (done)->
    @timeout 5000
    using new Import_Service(name: 'tm-uno'), ->
      importService  = @
      @.content.load_Data =>
        importService.graph.openDb =>
          @.graph_Find.find_Library (data)=>
            library_Data = data
            done()

  after (done)->
    importService.graph.closeDb ->
      done()

  it 'Issue xxx - weird bug in query-tree', (done)->
    #log library_Data
    #log root_Queries
    #query_Id = root_Queries.first().id
    #log query_Id
      #query_Id = root_Queries.queries.first().id
    done()