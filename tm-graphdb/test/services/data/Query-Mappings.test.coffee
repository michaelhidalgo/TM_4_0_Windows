Import_Service = require('./../../../src/services/data/Import-Service')

describe '| services | data | Query-Mappings.test', ->
  importService  = null
  query_Mappings = null

  @.timeout 5000

  before (done)->
    using new Import_Service(name: 'tm-uno'), ->
      importService  = @
      query_Mappings = @.query_Mappings
      @.content.load_Data =>
        importService.graph.openDb (status)->
          status.assert_True()
          done()

  after (done)->
    importService.graph.closeDb ->
      done()

  it 'get_Query_Mappings', (done)->
    using query_Mappings, ->
      @.get_Queries_Mappings (mappings)=>
        mappings.keys().assert_Not_Empty()
        query_Id = mappings.keys().first()
        @.get_Query_Mappings query_Id, (query_Mappings)=>
          query_Mappings.assert_Is_Object()
          query_Mappings.assert_Is(mappings[query_Id])
          done();

  it 'get_Queries_Mappings', (done)->
    using query_Mappings, ->
      @.get_Queries_Mappings (queries_Mappings)=>
        queries_Mappings.keys().assert_Size_Is_Bigger_Than(10)
        query_Id = queries_Mappings.keys().first()
        query    = queries_Mappings[query_Id];
        query.assert_Is_Object()
        done();

  it 'find_Root_Queries', (done)->
    using query_Mappings, ->
      @.find_Root_Queries (root_Queries)=>
        root_Queries.id      .assert_Is 'Root-Queries'
        root_Queries.title   .assert_Is 'Root Queries'
        root_Queries.queries .assert_Size_Is_Bigger_Than 4
        root_Queries.articles.assert_Size_Is 0             # for now, no queries are returned in this top level list
        done()