GitHubApi     = require('github')
Cache_Service = require('./Cache-Service')

class GitHubService
    constructor: ->
        @key      = "c2012dff24635c968afc"
        @secret   = "8e00a142cfc1ad59a22a4511c082476583cfb3da"
        @version  = "3.0.0"
        @debug    = false
        @github   = null
        @useCache = false
        
        @authenticate()
    
    authenticate: ->
      @github = new GitHubApi (version: @version, debug: @debug)
      @github.authenticate    (type   : "oauth" , key  : @key, secret : @secret)
      return @

    enableCache: ->
      @useCache = true
      @

    cacheService: (key, main_callback, noData_callback)=>
      if @useCache
        cacheService = new Cache_Service('github')
        data = cacheService.get(key)
        if (data)
          main_callback(JSON.parse(data))
        else
          noData_callback (data)->
            if (data)
              cacheService.put(key,JSON.stringify(data))
            main_callback(data)
      else
        noData_callback (data)->
          main_callback(data)

    rateLimit: (callback)=>
        @cacheService 'rateLimit', callback, (cache_callback) =>
          @github.misc.rateLimit {}, (err,res)=>
            throw err if err
            cache_callback(res)
        
    gist_Raw: (id, callback)->
      @cacheService 'gist_Raw_'.append(id), callback, (cache_callback) =>
        @github.gists.get  id : id, (err, res)->
          if err
            callback(null)
          else
            cache_callback(res)
            
    gist: (id, file, callback)->
      @cacheService "gist_#{id}_#{file}", callback, (cache_callback) =>
        @github.gists.get  id : id, (err, res)->
          if err or res.files.keys().not_Contains(file)
            cache_callback(null)
          else
            cache_callback(res.files[file])

    repo_Raw: (user,repo, callback)->
      @cacheService "repo_Raw_#{user}_#{repo}", callback, (cache_callback) =>
        @github.repos.get  user : user, repo: repo, (err, res)->
          throw err if err
          cache_callback(res)
            
    tree_Raw: (user,repo, sha, callback)->
      recursive = true
      @cacheService "tree_Raw_#{user}_#{repo}_#{sha}_#{recursive}", callback, (cache_callback) =>
        @github.gitdata.getTree  user : user, repo: repo, sha: sha, recursive : recursive, (err, res)->
          throw err if err
          cache_callback(res)
    
    file: (user,repo, path, callback)->
      path_safe = path.replace('/','_')
      @cacheService "file_#{user}_#{repo}_#{path_safe}", callback, (cache_callback) =>
        @github.repos.getContent  user : user, repo: repo, path: path, (err, res)->
          throw err if err
          asciiContent = new Buffer(res.content, 'base64').toString('ascii')
          cache_callback(asciiContent)


module.exports = GitHubService