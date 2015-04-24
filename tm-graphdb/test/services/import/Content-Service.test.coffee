async           = require 'async'
Content_Service = require '../../../src/services/import/Content-Service'

describe '| services | import | Content-Service.test |', ->

  contentService = null

  before ->
    contentService  = new Content_Service()

  it 'constructor',->
    using contentService, ->
      @.options    .assert_Is {}
      @.configService.constructor.name.assert_Is('Config_Service')

  it 'construtor (with params)',->
    options = { configService: 'abc'}
    using new Content_Service(options), ->
      @.options      .assert_Is(options)
      @.configService.assert_Is(options.configService)

  it 'library_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)->
        folder.assert_Folder_Exists()
              .assert_Contains(['.tmCache','_TM_3_5_Content'])
              .assert_Contains('Lib_')
              .assert_Contains(process.cwd())
        done()

  it 'library_Json_Folder', (done)->
    using contentService,->
      @.library_Folder (folder)=>
        @.library_Json_Folder (json_Folder, library_Folder)->
          library_Folder.assert_Is(folder)
          json_Folder   .assert_Is(library_Folder.append('-json'))
          done()

  it 'load_Library_Data',(done)->
    @timeout(20000)         # git it time to clone
    using contentService,->
      @.library_Folder (folder)=>
        @.load_Library_Data (result)->
          folder.assert_Contains(folder)
          done()

  it 'convert_Xml_To_Json', (done)->
    @timeout 15000
    contentService.json_Files (files)->
      (done();return) if files.not_Empty()
      using contentService,->
        @.convert_Xml_To_Json ()=>
          @.library_Json_Folder (json_Folder, library_Folder)=>
            @json_Files (jsons)=>
              @xml_Files (xmls)->
                xmls.assert_Not_Empty()
                    .assert_Size_Is(jsons.size())
                done()

  it 'load_Data', (done)->
    @timeout 10000
    using contentService,->
      @library_Json_Folder (json_Folder, library_Folder)=>
        @._json_Files = null
        @load_Data =>
          @json_Files (jsons)=>
            @xml_Files (xmls)=>
              xmls.assert_Size_Is(jsons.size())

              done()

  it 'article_Data', (done)->
    using contentService,->
      check_File = (xml_File, next)=>
        article_Id  = xml_File.file_Name().remove('.xml')
        @article_Data article_Id, (article_Data)->
          if (article_Data.TeamMentor_Article)
            using article_Data.TeamMentor_Article, ->
              @.assert_Is_Object()
              @.Metadata.assert_Is_Object()
              @.Content.assert_Is_Object()
          next()

      @.xml_Files (xml_Files)->
        async.each xml_Files.take(10), check_File, done

          #guid = '00869e27-75c2-4ba3-a91b-d15aea30411d'


        #log article_Data
