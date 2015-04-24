Config_Service = require '../../../src/services/utils/Config-Service'

describe '| services | utils | Config-Service.test', ->

  options       = null
  configService = null

  beforeEach ->
    options = { config_File: '_tmp-tm-Config.json'}
    configService = new Config_Service(options)
    configService.config_File_Path().assert_File_Not_Exists()

  afterEach ->
    configService.config_File_Path()
                 .file_Delete().assert_Is_True()

  it 'construtor',->
    using new Config_Service(), ->
      @.options    .assert_Is {}
      @.config_File.assert_Is '.tm.config.json'

  it 'construtor (with params)',->
    configService.assert_Is_Object()
    configService.options.assert_Is(options)    # set in beforeEach

  it 'config_File_Path', ->
    using configService.config_File_Path(), ->
      @.file_Name()    .assert_Is(options.config_File)
      process.cwd()    .assert_Contains(@.parent_Folder())

  it 'get_Config', (done)->
    using configService, ->
      @.get_Config (config)=>
        @.config_File_Path().assert_File_Exists()
        config.assert_Is_Object()
        done()

  it 'get_Defaults', ()->
    using configService.get_Defaults(), ->
      @.tm_3_5_Server  .assert_Is 'https://tmdev01-uno.teammentor.net'
      @.content_Folder .assert_Is './.tmCache/_TM_3_5_Content'
      @.default_Repo   .assert_Is 'https://github.com/TMContent/Lib_Vulnerabilities.git'
      @.current_Library.assert_Is 'Lib_Vulnerabilities'

  it 'save_Config', (done)->
    done()