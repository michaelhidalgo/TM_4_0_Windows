Import_Service = require('./../../../src/services/data/Import-Service')

describe '| services | data | Queries.test', ->

  importService  = null
  queries        = null
  graph_Find     = null

  @timeout 5000

  before (done)->
    using new Import_Service(name:'tm-uno'), ->
      importService  = @
      queries        = @.queries
      graph_Find     = @.graph_Find
      @.content.load_Data =>
        importService.graph.openDb ->
          done()

  after (done)->
    importService.graph.closeDb ->
      done()

  it 'get_Articles_Queries', (done)->
      using queries, ->
        @.get_Articles_Queries (articles_Queries)->
          articles_Queries.keys().assert_Not_Empty()
          done();

  it 'map_Article_Parent_Queries', (done)->
    using importService, ->
      @.graph_Find.find_Articles (articles)=>
        article_Id = articles.first()
        @.queries.get_Articles_Queries (articles_Queries,queries_Mappings)=>
          article_Parent_Queries = @.queries.map_Article_Parent_Queries articles_Queries,queries_Mappings, null, article_Id
          using article_Parent_Queries, ->
            @.articles.keys().assert_Size_Is(1)
            @.articles[@.articles.keys().first()].parent_Queries.assert_Size_Is_Bigger_Than(8)
            @.queries.keys().assert_Size_Is_Bigger_Than(8)
            done();

  it 'map_Articles_Parent_Queries', (done)->
    using importService, ->
      @.graph_Find.find_Articles (articles)=>
        article_Ids = [articles.first(), articles.second()]
        @.queries.map_Articles_Parent_Queries article_Ids, (articles_Parent_Queries)->
          using articles_Parent_Queries, ->
            @.articles.keys().assert_Size_Is(2)
            @.articles[@.articles.keys().first()].parent_Queries.assert_Size_Is_Bigger_Than(8)
            @.queries.keys().assert_Size_Is_Bigger_Than(10)
            done()