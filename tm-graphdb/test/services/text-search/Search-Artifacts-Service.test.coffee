
Search_Artifacts_Service = require './../../../src/services/text-search/Search-Artifacts-Service'

describe '| services | text-search | Search-Artifacts-Service.test', ->
  article          = null
  import_Service   = null
  library_Data     = null
  search_Artifacts = null
  article_Ids      = null

  before (done)->
    search_Artifacts = new Search_Artifacts_Service()
    import_Service = search_Artifacts.import_Service
    using import_Service, ()->
      import_Service.graph.openDb =>
        search_Artifacts.article.ids (_article_Ids)->
          article_Ids = _article_Ids
          done()

  after (done)->
    import_Service.graph.closeDb ->
      done()

  it 'constructor',->
    #library_Data.assert_Is_Object()
    search_Artifacts               .constructor.name.assert_Is 'Search_Artifacts_Service'
    search_Artifacts.import_Service.constructor.name.assert_Is 'ImportService'
    search_Artifacts.article       .constructor.name.assert_Is 'Article'

  it 'batch_Parse_All_Articles', (done)->
    @.timeout 0
    search_Artifacts.batch_Parse_All_Articles (results)->
      results.assert_Size_Is_Bigger_Than 100
      done()

  it 'create_Search_Mappings', (done)->
    @.timeout 0
    search_Artifacts.create_Search_Mappings ->
      done()

  it 'create_Tag_Mappings', (done)->
    search_Artifacts. create_Tag_Mappings (tag_Mappings_File)->
      search_Artifacts.cache_Search.path_Key 'tags_mappings.json'
                      .assert_File_Exists()
      done()

  it 'parse_Article', (done)->
    article_Id = article_Ids.first()
    search_Artifacts.parse_Article article_Id, (data)->
      data.id      .assert_Is article_Id
      data.checksum.assert_Is_String()
      data.words.keys().assert_Is_Bigger_Than 50
      data.tags .keys().assert_Is_Bigger_Than 1
      data.links       .assert_Is_Bigger_Than 0
      done()

  it 'parse_Article_Html', (done)->
    article_Id = article_Ids.first() #[200.random()]  'article-9e203d1b630f'
    search_Artifacts.parse_Article_Html article_Id, (data)->
      data.id      .assert_Is article_Id
      data.checksum.assert_Is_String()
      data.words.keys().assert_Is_Bigger_Than 50
      data.tags .keys().assert_Is_Bigger_Than 1
      data.links       .assert_Is_Bigger_Than 0
      done()

  it 'parse_Articles', (done)->
    @.timeout 60000
    size = -1
    console.time 'parse_Articles'
    article_Ids = article_Ids.take(size)
    search_Artifacts.parse_Articles article_Ids, (results)->
      console.timeEnd 'parse_Articles'
      for item in results
        item.id.assert_Is_String()
      done()


  it 'raw_Articles_Html', (done)->
    @.timeout 20000
    search_Artifacts.raw_Articles_Html (data)->
      data.assert_Not_Empty()
      done()