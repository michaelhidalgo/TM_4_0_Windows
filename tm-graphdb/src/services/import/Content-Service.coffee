require 'fluentnode'
xml2js  = require('xml2js')
async   = require('async')

Config_Service = require '../utils/Config-Service'
Git_API        = require '../../api/Git-API'

class Content_Service
  constructor: (options)->
    @.options        = options || {}
    @.configService  = @options.configService || new Config_Service()
    @.force_Reload   = false
    @._json_Files     = null
    @._xml_Files      = null

  library_Folder: (callback)=>
    @.configService.get_Config (config)->
        folder = __dirname.path_Combine('../../../')
                          .path_Combine(config.content_Folder)
                          .path_Combine(config.current_Library)
                          .folder_Create()
        callback(folder)

  library_Json_Folder: (callback)=>
    @.library_Folder (library_Folder)=>
      json_Folder = library_Folder.append('-json')
      callback json_Folder, library_Folder

  load_Library_Data: (callback)=>
    @.xml_Files (xmlFiles)=>
      if xmlFiles.not_Empty() and @.force_Reload is false
        callback("data load skipped")
      else
        @.configService.get_Config (config)=>
          @.library_Folder (folder)->

            source_Repo = config.default_Repo
            target_Folder = folder
            target_Folder.folder_Delete_Recursive()
            git_Command =
              name  : 'clone'
              params:['clone', "#{source_Repo}","#{target_Folder}"]
            execMethod = new Git_API().git_Exec_Method(git_Command)
            res =
              send: (result)->
                #log "Clone completed"
                #log result
                callback(result)
            execMethod(null, res)


  convert_Xml_To_Json: (callback)=>
    @.json_Files (json_Files)=>
      if json_Files.not_Empty() and @.force_Reload is false
        callback()
      else
        @.library_Json_Folder (json_Folder, library_Folder)->
          convert_Library_File = (file, next)=>
            json_File = file.replace(library_Folder, json_Folder)
                            .replace('.xml','.json')
            json_File.parent_Folder().folder_Create()
            xml2js.parseString file.file_Contents(), (error, json) ->
              if not error
                json.save_Json(json_File)
              next()

          xml_Files = library_Folder.files_Recursive(".xml")

          async.each xml_Files,convert_Library_File, callback

  json_Files: (callback)=>
    if @._json_Files and @._json_Files.not_Empty()
      callback @._json_Files
    else
      @.library_Json_Folder (json_Folder, library_Folder)=>
        @._json_Files = json_Folder.files_Recursive(".json")
        callback @._json_Files

  load_Data: (callback)=>
    @.library_Json_Folder (json_Folder, library_Folder)=>
     @json_Files (jsons)=>
      @xml_Files (xmls)=>
        if @force_Reload or xmls.empty() or jsons.size() isnt xmls.size()
          @load_Library_Data =>
            @convert_Xml_To_Json =>
              callback()
        else
          callback();

  xml_Files: (callback)=>
    if @._xml_Files and @._xml_Files.not_Empty()
      callback @._xml_Files
    else
      @.library_Json_Folder (json_Folder, library_Folder)=>
        @._xml_Files = library_Folder.files_Recursive(".xml")
        callback @._xml_Files

  article_Data: (articleId, callback) =>
    @json_Files (jsonFiles) =>
      article_File = jsonFile for jsonFile in jsonFiles when jsonFile.contains(articleId)
      if article_File and article_File.file_Exists()
        callback article_File.load_Json().TeamMentor_Article
      else
        callback null

module.exports = Content_Service