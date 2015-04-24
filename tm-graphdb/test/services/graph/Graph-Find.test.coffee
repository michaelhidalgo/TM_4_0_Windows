Import_Service = require('./../../../src/services/data/Import-Service')

describe '| services | graph | Graph-Find.test', ->

  importService = null
  graph_Find    = null

  @timeout 5000

  before (done)->
    using new Import_Service(name: 'tm-uno'), ->
      importService = @
      graph_Find    = @.graph_Find
      @.content.load_Data =>
        importService.graph.openDb ->
          done()

  after (done)->
    importService.graph.closeDb ->
      done()

  it 'find_Queries', (done)->
    using graph_Find, ->
      @find_Queries (queries)->
        queries.assert_Not_Empty()
        done()

  it 'find_Articles', (done)->
    using graph_Find, ->
      @find_Articles (articles)->
        articles.assert_Not_Empty()
        done()

  it 'find_Articles, find_Article_Parent_Queries, find_Query_Articles', (done)->
    using graph_Find, ->
      @.find_Articles (articles)=>
        @find_Article_Parent_Queries articles.first(), (parent_Queries)=>
          @find_Query_Articles parent_Queries.first(), (query_Articles)=>
            query_Articles.assert_Contains(articles.first())
            done()

  it 'find_Library', (done)->
    using graph_Find, ->
      @.find_Library (library_Data)=>
        library_Data.title.assert_Is_String()
        library_Data.id   .assert_Is_String()
        library_Data.is   .assert_Is ['Library', 'Query']
        library_Data['contains-query'].assert_Not_Empty()
        done()

  it 'find_Queries, find_Query_Parent_Queries, find_Query_Queries', (done)->
    using graph_Find, ->
      @.find_Queries (queries)=>
        @find_Query_Parent_Queries queries.first(), (parent_Queries)=>
          @find_Query_Queries parent_Queries.first(), (query_Queries)=>
            query_Queries.assert_Contains(queries.first())
            done()

  it 'get_Subject_Data (bad data)', (done)->
    graph_Find.get_Subject_Data null, ->
      done()

  describe 'find_Article_By_....', ->
    articles     = null
    article_Id   = null
    article_Data = null

    before (done)->
      using graph_Find, ->
        @.find_Articles (articles)=>
          article_Id = articles.first()
          @.get_Subject_Data article_Id, (data)->
            using data,->
              article_Data = @
              @.id.assert_Is article_Id
              @.keys().assert_Contains ['guid','title','summary','is','id']
            done()

    it 'find_Article', (done)->
      using graph_Find, ->
        @.find_Article article_Data.id, (by_id)=>
          @.find_Article article_Data.guid, (by_guid)=>
            @.find_Article article_Data.title, (by_title)=>
              @.find_Article article_Data.title.replace(' ', '-'), (by_title_dashed)->
                by_id.assert_Is article_Id
                by_guid.assert_Is article_Id
                by_title.assert_Is article_Id
                by_title_dashed.assert_Is article_Id
                done()

    it 'find_Article_By_Id', (done)->
      using graph_Find, ->
        @.find_Article article_Id, (article_Data)->
          article_Data.assert_Is article_Id
          done()

    it 'find_Article_By_Partial_Id', (done)->
      using graph_Find, ->
        @.find_Article_By_Partial_Id article_Id.remove('article-'), (article_Data)=>
          article_Data.assert_Is article_Id
          @.find_Article_By_Partial_Id 'aaab', (article_Data)->
            assert_Is_Null article_Data
            done()

    it 'find_Article_By_Guid', (done)->
      using graph_Find, ->
        @.find_Article_By_Guid article_Data.guid, (article_Data)->
          article_Data.assert_Is article_Id
          done()

    it 'find_Article_By_Title', (done)->
      using graph_Find, ->
        @.find_Article_By_Title article_Data.title, (article_Data)->
          article_Data.assert_Is article_Id
          done()

    it 'find_Article_By_Title (dashed title)', (done)->
      title = article_Data.title.replace(/\s/g ,'-')
      using graph_Find, ->
        @.find_Article_By_Title title, (article_Data)->
          article_Data.assert_Is article_Id
          done()

    it 'find_Tags', (done)->
      using graph_Find, ->
        @.find_Tags (tags)=>
          tags.keys().assert_Not_Empty()
          tags.values().assert_Not_Empty()
          done()