require 'fluentnode'

Cache_Service  = require('./Cache-Service')
xml2js         = require('xml2js');

class TeamMentor_Service
  constructor: (options)->
    @options        = options || {}
    @name           = @options.name || '_tm_data'
    @cacheService   = new Cache_Service(@name)
    @tmServer       = @options.tmServer || 'https://tmdev01-uno.teammentor.net'
    @asmx           = new TeamMentor_ASMX(@)
    @tmConfig_File  = @options.tmConfig_File || null
    @tmConfig       = null
    @load_TM_Config()

  load_TM_Config: ()=>
    if (global.file_Exists(@tmConfig_File))
      @tmConfig = @tmConfig_File.load_Json()
    else
      @tmConfig = { tm_User : { username: '', token: ''} }
    @

  auth_Param: ()=>
    "?auth=#{@tmConfig.tm_User.token}"

  tmServerVersion: (callback)->
    url = @tmServer + '/rest/version'
    @cacheService.http_GET url, (html)->
      xml2js.parseString html, (error, json) -> callback json.string._

  libraries: (callback)=>
    @asmx.getFolderStructure_Libraries (data)=>
      libraries = {}
      for libraryStructure in data
        libraries[libraryStructure.name] = libraryStructure
      callback(libraries)

  library: (name, callback)=>
    @libraries (libraries)=>
      callback(libraries[name])

  article: (guid, callback)=>
    if not guid
      callback null
    else
      url = @tmServer + "/jsonp/#{guid}" + @auth_Param()
      @cacheService.json_GET url, (article)->
        callback article

  login_Rest: (username,password, callback)=>
    url = @tmServer + "/rest/login/#{username}/#{password}"
    @cacheService.json_GET url, (article)->
      callback article

  whoami: (callback)=>
    url = @tmServer + "/whoami" + @auth_Param()
    url.json_GET callback



class TeamMentor_ASMX
  constructor: (teamMentorService)->
    @teamMentor   = teamMentorService
    @asmx_BaseUrl = @teamMentor.tmServer + '/Aspx_Pages/TM_WebServices.asmx/'

  _json_Post: (methodName, postData,callback) =>
    @teamMentor.cacheService.json_POST @asmx_BaseUrl + methodName, postData, callback

  ping: (message,callback) =>
    @_json_Post "Ping", {message:message}, (json, response) -> callback(json.d)

  getFolderStructure_Libraries: (callback) =>
    @_json_Post "GetFolderStructure_Libraries", {}, (json, response) ->  callback(json.d)

  login: (username, password, callback) =>
    @_json_Post "Login", {username:username, password:password}, (json, response) ->
      #console.log json
      callback(json.d)

module.exports = TeamMentor_Service