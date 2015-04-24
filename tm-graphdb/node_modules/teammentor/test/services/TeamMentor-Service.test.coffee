
TeamMentor_Service   = require('../../src/services/TeamMentor-Service')

describe 'services | test-TeamMentor-Service |', ->

  describe 'core',->

    teamMentor = null

    before ->
      teamMentor = new TeamMentor_Service()

    it 'check ctor', ->
      TeamMentor_Service.assert_Is_Function()
      using teamMentor,->
        @.name          .assert_Is_String()
        @.tmServer      .assert_Is_String()
        @.cacheService  .assert_Is_Object()
        @.asmx          .assert_Is_Object()

        @.name          .assert_Is '_tm_data'
        @.name          .assert_Is teamMentor.cacheService.area
        @.tmServer      .assert_Is 'https://tmdev01-uno.teammentor.net'
        @.tmConfig      .assert_Is_Object()
        assert_Is_Null(@.tmConfig_File)


    it 'check ctor (with options)', ->
      tmpConfigFile = '.tmp_tm_config'.append_To_Process_Cwd_Path()
      tmConfigData = {tm_User : { username: 'abc', token: '123'}}
      tmConfigData.save_Json(tmpConfigFile)
      options = {
                  name          : 'name_123'
                  tmServer      : 'http://11111.222'
                  tmConfig_File : tmpConfigFile
                }
      teamMentor_Options = new TeamMentor_Service(options)

      using teamMentor_Options,->
        @.name         .assert_Is(options.name)
        @.tmServer     .assert_Is(options.tmServer)
        @.tmConfig_File.assert_Is(tmpConfigFile)
        @.tmConfig     .assert_Is(tmConfigData)
        #@tmConfig.tm_User.assert_Is(options.tm_User)
        using @.cacheService,->
          @.cacheFolder()       .assert_Folder_Exists()
          @.delete_CacheFolder().assert_True()
          @.cacheFolder()       .assert_Folder_Not_Exists()
          tmpConfigFile.file_Delete().assert_True()

    it 'load_TM_Config', (done)->
      teamMentor.load_TM_Config()
      done();

    it 'tmServerVersion', (done)->
      @timeout(20000)                                       # give target TM time to wake up
      teamMentor.tmServerVersion.assert_Is_Function()
      teamMentor.tmServerVersion (version)->
        version.assert_Is('3.5.0.0')
        done()

    it 'libraries', (done)->
      teamMentor.libraries.assert_Is_Function()
      teamMentor.libraries (libraries)->
        libraries.assert_Is_Object();
        Object.keys(libraries).assert_Size_Is(2)
        libraries['Guidance']     .assert_Is_Object()
        libraries['Guidance'].name.assert_Is('Guidance')
        done()

    it 'library', (done)->
      teamMentor.library.assert_Is_Function()
      teamMentor.library 'Guidance', (library)->
        library.assert_Is_Object()
        library.name = 'Guidance'
        done()

    it 'login_Rest (bad pwd)', (done)->
      teamMentor.login_Rest "graph123","aaaaaa", (data)->
        data.assert_Is('00000000-0000-0000-0000-000000000000')
        done()


  describe 'with valid login',->

    tmConfig_File = '.tm-Config.json'.append_To_Process_Cwd_Path()
    teamMentor    = null

    return if (tmConfig_File.file_Not_Exists())

    @timeout(10000)  # in case the .NET server needs to wake up

    before ->
      teamMentor = new TeamMentor_Service({tmConfig_File : tmConfig_File})

    it 'article', (done)->
      article_Guid = '6cdd9588-3483-4054-8bb7-17f790dedf10'
      teamMentor.article.assert_Is_Function()
      teamMentor.article article_Guid, (article)->
        article.assert_Is_Object()
        article.Metadata      .assert_Is_Object()
        article.Metadata.Id   .assert_Is(article_Guid)
        article.Metadata.Title.assert_Is('Constrain, Reject, And Sanitize Input')
        done()

    it 'whoami', (done)->
      teamMentor.whoami (data)->
        data.assert_Is_Object()
        data.UserName.assert_Is('tm4bot')
        done()

  describe 'asmx',->

    teamMentor = null
    asmx              = null

    before ->
      teamMentor = new TeamMentor_Service()
      asmx              = teamMentor.asmx

    it '.ctor', ->
      asmx.teamMentor  .assert_Is_Equal_To(teamMentor)
      asmx.asmx_BaseUrl.assert_Is_Equal_To(teamMentor.tmServer + '/Aspx_Pages/TM_WebServices.asmx/')

    it '_json_Post', (done)->
      @timeout 10000        # in case the .NET server needs to wake up
      methodName = 'Ping'
      asmx._json_Post methodName, {message:''}, (response)->
        #console.log response
        response.d.assert_Contains('received ping: ')
        done()
    
    it 'article (null)', (done)->
      teamMentor.article null, (result)->
        assert_Is_Null(result)
        done()
        
    it 'ping', (done)->
      value = (5).random_Letters()
      asmx.ping '', (data)->
        data.assert_Contains('received ping: ')
        done()

    it 'getFolderStructure_Libraries', (done)->
      asmx.getFolderStructure_Libraries (data)->
        data.assert_Is_Array()
        data.first().assert_Is_Object()
        data.first().__type       .assert_Is 'TeamMentor.CoreLib.Library_V3'
        data.first().libraryId    .assert_Is 'de693015-55c9-4328-bbc8-42db82ae8b7a'
        data.first().name         .assert_Is 'Gateways'
        data.first().subFolders   .assert_Is_Array()
        data.first().views        .assert_Is_Array()
        data.first().guidanceItems.assert_Is_Array()
        done()

    it 'login (bad pwd)', (done)->
      asmx.login "aaa","bbb", (data)->
        data.assert_Is('00000000-0000-0000-0000-000000000000')
        done()

    it 'whoami', (done)->
      teamMentor.whoami (data)->
        data.assert_Is_Object()
        data.UserName.assert_Is('')
        done()

