TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Git_API = require '../../src/api/Git-API'

describe '| api | Git-API.test', ->

  #describe 'directly',->
  #  it 'git_Exec', (done)->
  #      using new Git_API(), ->
  #          @git_Exec 'status', (result)->
  #              log result
  #              done()

  describe '| via web api',->

      tmServer       = null
      swaggerService =  null
      clientApi      = null

      before (done)->
        tmServer  = new TM_Server({ port : 12345}).configure()
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service options
        swaggerService.set_Defaults()
        #swaggerService.setup()

        new Git_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()
        swaggerService.get_Client_Api 'git', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        Git_API.assert_Is_Function()

      it 'check git section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/git')

          swaggerService.url_Api_Docs.append("/git").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')
            data.resourcePath  .assert_Is('/git')
            clientApi.assert_Is_Object()
            clientApi.status.assert_Is_Function()
            clientApi.remote.assert_Is_Function()
            done()

      it 'status', (done)->
        clientApi.status (data)->
          #log data.obj
          data.obj.assert_Contains('commit')
          done()

      it 'head', (done)->
        clientApi.head (data)->
          data.obj.assert_Is_String()
          done()

      #it 'remote', (done)->
      #  clientApi.remote (data)->
      #    data.obj.assert_Contains(':')     # not a reliable way to confirm this
      #    #log data.obj
      #    done()

      it 'log', (done)->
        clientApi.head (head)->
          clientApi.log (data)->
            data.obj.assert_Contains('*')
                    .assert_Contains(head.obj.trim())
            #log data.obj
            done()

      xit 'pull', (done)->
        @timeout(5000)
        clientApi.pull (data)->
          #data.obj.data.assert_Contains('@')
          #log data.obj
          data.obj.assert_Is_Not(' ')
          done()
