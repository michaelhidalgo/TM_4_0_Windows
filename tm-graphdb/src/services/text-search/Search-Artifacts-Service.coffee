Cache_Service  = null
Import_Service = null
Article        = null
crypto         = null
cheerio        = null
async          = null

checksum = (str, algorithm, encoding)->
    crypto.createHash(algorithm || 'md5')
           .update(str, 'utf8')
           .digest(encoding || 'hex')

class Search_Artifacts_Service

  dependencies: ->
    Import_Service  = require('./../../../src/services/data/Import-Service')
    Article         = require './../../../src/graph/Article'
    Cache_Service   = require('teammentor').Cache_Service
    crypto          = require('crypto')
    cheerio         = require 'cheerio'
    async           = require 'async'

  constructor: (options)->
    @.dependencies()
    @.options         = options || {}
    @.import_Service  = @.options.import_Service || new Import_Service(name:'tm-uno')
    @.article         = new Article(@.import_Service)
    @.cache           = new Cache_Service("article_cache")
    @.cache_Search    = new Cache_Service("search_cache")

  batch_Parse_All_Articles: (callback)=>
    @.article.ids  (article_Ids)=>
      @.parse_Articles article_Ids, callback

  parse_Article: (article_Id, callback)=>
    key = "#{article_Id}.json"
    if @.cache.has_Key key
      data = @.cache.get key
      setImmediate ->
        callback data.json_Parse(), false
    else
      @.parse_Article_Html article_Id, (data)=>
        #log "Parsed html for #{article_Id}"
        @.cache.put key, data
        process.nextTick ->
          callback data, true

  parse_Articles: (article_Ids, callback)=>
    results = []
    if article_Ids is undefined or article_Ids is null
      return callback results
    total = article_Ids.size()
    count = 0
    map_Article = (article_Id, next)=>
      @.parse_Article article_Id, (data, showLog)->
        count++
        if showLog and (count %% 50) is 0
          log "[#{count}/#{total}] Parsed html for #{article_Id}"
        results.push data
        next()

    async.eachSeries article_Ids , map_Article, ()=>
      callback results

  parse_Article_Html: (article_Id, callback)=>
    data =
          id       : article_Id
          checksum : null
          words    : {}
          tags     : {}
          links    : []
    @.article.html article_Id, (html)=>
      data.html     = html
      data.checksum = checksum(html,'sha1')

      $ = cheerio.load html

      $('*').each (index,item)->
        tagName = item.name
        $tag = $(item)
        text    = $tag.text()
        if tagName is 'a'
          attrs = $tag.attr()
          attrs.text = $tag.text()
          data.links.push attrs

        data.tags[tagName] ?= []
        data.tags[tagName].push(text.trim())
        for word in text.split(' ')
          word = word.trim().lower().replace(/[,\.;\:\n\(\)\[\]<>]/,'')     # this has some performance implications (from 9ms to 18ms) and it might be better to do it on data consolidation
          if word and word isnt ''
            if data.words[word] is undefined or typeof data.words[word] is 'function' # need to do this in order to avoid confict with js build in methods (like constructor)
              data.words[word] = []
            data.words[word].push(tagName)

      @.article.raw_Data article_Id, (raw_Data)->
        title = raw_Data.TeamMentor_Article.Metadata[0].Title.first()
        for word in title.split(' ')
          word = word.trim().lower().replace(/[,\.;\:\n\(\)\[\]<>]/,'')
          if word isnt ''
            if data.words[word] is undefined or typeof data.words[word] is 'function'
              data.words[word] = []
            data.words[word].push('title')
        callback data

  raw_Articles_Html: (callback)=>
    key = 'raw_articles_html.json'
    if @.cache_Search.has_Key key
      data =@.cache_Search.get key
      callback data.json_Parse()
    else
      "no key for raw_Articles_Html, so calculating them all".log()
      @.batch_Parse_All_Articles =>
        raw_Articles_Html = []
        for file in @.cache.cacheFolder().files()
          raw_Articles_Html.push file.load_Json()
        if raw_Articles_Html.not_Empty()
          @.cache_Search.put key, raw_Articles_Html,
        callback raw_Articles_Html

  create_Search_Mappings: (callback)=>
    @.raw_Articles_Html (articles_Data)=>
      search_Mappings = {}
      for article_Data in articles_Data
        for word,where of article_Data.words
          if search_Mappings[word] is undefined or typeof search_Mappings[word] is 'function'
            search_Mappings[word] = {}
          search_Mappings[word][article_Data.id] =  where : where #.unique()

      keys =  (key for key of search_Mappings)
      if keys.length > 0
        @.cache_Search.put 'search_mappings.json', search_Mappings
      callback search_Mappings

  create_Tag_Mappings :(callback)=>
    @.import_Service.graph_Find.find_Tags (tags_Data)=>
      @.cache_Search.put 'tags_mappings.json', tags_Data
      callback tags_Data

module.exports = Search_Artifacts_Service