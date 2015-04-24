require 'fluentnode'
request = require 'request'

class CacheService
    constructor: (area)->
      @_cacheFolder    = "./.tmCache"
      @_forDeletionTag = ".deleteCacheNext"
      @area = area || null
      @setup()

    cacheFolder: =>
      @_cacheFolder.append_To_Process_Cwd_Path()
                   .path_Combine(@area || '')

    delete_CacheFolder: =>
      @cacheFolder().realPath().folder_Delete_Recursive()

    markForDeletion: =>
      forDeleleTag_File = @cacheFolder().path_Combine(@._forDeletionTag)
      forDeleleTag_File.touch()
      return forDeleleTag_File

    setup: =>
      if @cacheFolder().path_Combine(@._forDeletionTag).exists()
        @delete_CacheFolder()
      if not @cacheFolder().folder_Exists()
        if @area
          @_cacheFolder.append_To_Process_Cwd_Path().folder_Create();
        @cacheFolder().folder_Create()

    path_Key: (key)->
      if(key)
        safeKey = key.replace(/[^a-z0-9._-]/gi, '_').lower()
        return @cacheFolder().path_Combine(safeKey)
      return null

    put: (key, value)=>
      if(key and value)
        if(typeof value is 'string')
          value.saveAs(@path_Key(key))
        else
          JSON.stringify(value,null, " ").saveAs(@path_Key(key))
        return value
      return null

    get: (key) =>
      if(key)
        return @path_Key(key).file_Contents()
      return null

    delete: (key) =>
      if(key)
        return @path_Key(key).file_Delete()
      return false

    has_Key: (key) =>
      path = @path_Key(key)
      if path then path.file_Exists() else false

    http_GET: (url, callback)=>
      key = "http_get_#{url}"
      if @has_Key(key)
        response = JSON.parse(@get(key))
        callback response.body, response
      else
        request url, (error, response)=>
          throw error if error
          @put(key,response)
          callback response.body, response

    json_GET: (url, callback)->
      key = "json_get_#{url}"
      if @has_Key(key)
        response = JSON.parse(@get(key))           #
        json     = response.body                   #
        callback json, response                    #
      else
        "[CacheService][json_GET] downloading: #{url}".log()
        options = { url: url , json: true }
        request options, (error, response)=>
          throw error if error
          @put(key,response)
          callback response.body, response

    json_POST: (url, postData, callback)->
      key = "json_post_#{url}"
      if @has_Key(key)
        response = JSON.parse(@get(key))
        json     = response.body
        callback json, response
      else

        options         = { url: url , body:postData, json: true}
        options.headers = {
                            'accept':'application/json, text/javascript, */*; q=0.01'
                            'content-type':'application/json'
                            'x-requested-with':'XMLHttpRequest'
                          }
        request.post options, (error, response)=>
          throw error if error
          @put(key,response)
          callback response.body, response

module.exports = CacheService