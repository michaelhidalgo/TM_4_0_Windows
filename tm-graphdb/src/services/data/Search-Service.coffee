Import_Service        = require './Import-Service'
Search_Text_Service   = require '../text-search/Search-Text-Service'

class Search_Service

  constructor: (options)->
    @.options       = options || {}
    @.importService = @.options.importService || new Import_Service(name:'tm-uno')
    @.graph         = @.importService.graph

  article_Titles: (callback)=>
    @.graph.db.nav('Article').archIn('is').as('id')
                             .archOut('title').as('title')
                             .solutions (err,data) ->
                                callback data
  article_Summaries: (callback)=>
    @.graph.db.nav('Article').archIn('is').as('id')
                             .archOut('summary').as('summary')
                             .solutions (err,data) ->
                                callback data

  query_Titles: (callback)=>
    @.graph.db.nav('Query').archIn('is').as('id')
                             .archOut('title').as('title')
                             .solutions (err,data) ->
                                callback data

  search_Using_Text: (text, callback)=>
    text = text.lower()
    new Search_Text_Service().words_Score text, (results)->
      callback results

  query_Id_From_Text: (text)=>
    "search-#{text.trim().to_Safe_String()}"

  query_From_Text_Search: (text, callback)=>
    query_Id = @query_Id_From_Text text

    @.importService.graph_Find.get_Subject_Data query_Id, (data)=>
      if data.is
        callback data.id
        return
      #"[search] calculating search for: #{text}".log()
      # add check if search query already exists
      @.search_Using_Text text, (results)=>
        if results.empty()
          callback null
          return

        article_Ids = (result.id for result in results)

        articles_Nodes = [{ subject:query_Id , predicate:'is'         , object:'Query' }
                          { subject:query_Id , predicate:'is'         , object:'Search' }
                          { subject:query_Id , predicate:'title'      , object: text }
                          { subject:query_Id , predicate:'id'         , object: query_Id }
                          { subject:query_Id , predicate:'search-data', object: results }]
        for article_Id in article_Ids
          articles_Nodes.push { subject:query_Id , predicate:'contains-article'  , object:article_Id }
        @graph.db.put articles_Nodes, =>
          @.importService.graph_Add_Data.add_Is query_Id, 'Query', =>
            @importService.graph_Add_Data.add_Is query_Id, 'Search', =>
              @importService.graph_Add_Data.add_Title query_Id, text, =>
                @importService.query_Mappings.update_Query_Mappings_With_Search_Id query_Id, =>
                  callback(query_Id)

module.exports = Search_Service