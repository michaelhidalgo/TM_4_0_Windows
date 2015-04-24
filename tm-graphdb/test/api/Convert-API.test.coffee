TM_Server        = require '../../src/TM-Server'
Swagger_Service  = require '../../src/services/rest/Swagger-Service'
Convert_API      = require '../../src/api/Convert-API'

describe '| api | Convert-API.test', ->

  describe '| via web api',->

      tmServer       = null
      swaggerService = null
      clientApi      = null
      convertApi     = null

      before (done)->
        tmServer  = new TM_Server({ port : 12345}).configure()
        options = { app: tmServer.app ,  port : tmServer.port}
        swaggerService = new Swagger_Service(options)
        swaggerService.set_Defaults()

        convertApi = new Convert_API({swaggerService: swaggerService}).add_Methods()
        swaggerService.swagger_Setup()
        tmServer.start()

        swaggerService.get_Client_Api 'convert', (swaggerApi)->
            clientApi = swaggerApi
            done()

      after (done)->
        tmServer.stop ->
          done()

      it 'constructor', ->
        convertApi.assert_Is_Object()
        convertApi.swaggerService.assert_Is swaggerService
        convertApi.options.area.assert_Is 'convert'


      it 'check convert section exists', (done)->
        swaggerService.url_Api_Docs.GET_Json (docs)->
          api_Paths = (api.path for api in docs.apis)
          api_Paths.assert_Contains('/convert')

          swaggerService.url_Api_Docs.append("/convert").GET_Json (data)->
            data.apiVersion    .assert_Is('1.0.0')
            data.swaggerVersion.assert_Is('1.2')      # ERROR IS HERE
            data.resourcePath  .assert_Is('/convert')
            clientApi.assert_Is_Object()
            done()

      it 'to_ids (bad data)', (done)->

        check = (send, expect, next)->
          clientApi.to_ids {values: send }, (data)->
            data.obj.assert_Is expect
            next()

        check 'abcdefg' , { abcdefg : { } }, ->
          check 'abcdefg , 123456 ' , { abcdefg: {} , 123456: {} }, ->
            done()

      it 'to_Ids (one value)', (done)->
        values = 'Technology'
        clientApi.to_ids {values: values }, (data)->
          using data.obj[values], ->
            @.id.assert_Is_String()
            @.title.assert_Is values
            query_Id = @.id
            clientApi.to_ids {values: query_Id }, (data)->
              using data.obj[query_Id], ->
                @.id.assert_Is query_Id
                @.title.assert_Is values
                done()

      it 'to_Ids (multiple values data)', (done)->
        values = 'aaa, Technology, Type, Category, Phase, bbb'
        clientApi.to_ids {values: values }, (data)->
          result = data.obj
          result.keys().assert_Size_Is values.split(',').size()
          result['aaa'].assert_Is {}
          result['bbb'].assert_Is {}
          result['Technology'].title.assert_Is    ('Technology')
          result['Phase'     ].title.assert_Is_Not('Technology')
          done()

      it 'wikitext_to_html', (done)->
        clientApi.wikitext_to_html { wikitext:'==h2 heading'}, (data)->
          data.obj.wikitext.assert_Is '==h2 heading'
          data.obj.html.assert_Is '<h2>h2 heading</h2>'
          done()

      it 'markdown_to_html', (done)->
        clientApi.markdown_to_html { markdown:'## h2 heading'}, (data)->
          using data.obj,->
            @.markdown.assert_Is '## h2 heading'
            @.html.assert_Is '<h2>h2 heading</h2>\n'
            #@.tokens.assert_Is [  { type: 'heading_open', hLevel: 2, lines: [ 0, 1 ], level: 0 },
            #                      { type: 'inline',content: 'h2 heading', level: 1, lines: [ 0, 1 ], children: [{"type": "text","content": "h2 heading","level": 0}] },
            #                      { type: 'heading_close', hLevel: 2, level: 0 } ]

            @.tokens.assert_Is [ {
                                    "attrs": null , "block": true , "children": null , "content": ""
                                    "hidden": false, "info": "", "level": 0, "map": [ 0 , 1 ], "markup": "##"
                                    "meta": null, "nesting": 1, "tag": "h2", "type": "heading_open"
                                  }
                                  {
                                    "attrs": null
                                    "block": true
                                    "children": [
                                      {
                                        "attrs": null
                                        "block": false
                                        "children": null
                                        "content": "h2 heading"
                                        "hidden": false
                                        "info": ""
                                        "level": 0
                                        "map": null
                                        "markup": ""
                                        "meta": null
                                        "nesting": 0
                                        "tag": ""
                                        "type": "text"
                                      }
                                    ]
                                    "content": "h2 heading"
                                    "hidden": false
                                    "info": ""
                                    "level": 1
                                    "map": [
                                      0
                                      1
                                    ]
                                    "markup": ""
                                    "meta": null
                                    "nesting": 0
                                    "tag": ""
                                    "type": "inline"
                                  }
                                  {
                                    "attrs": null
                                    "block": true
                                    "children": null
                                    "content": ""
                                    "hidden": false
                                    "info": ""
                                    "level": 0
                                    "map": null
                                    "markup": "##"
                                    "meta": null
                                    "nesting": -1
                                    "tag": "h2"
                                    "type": "heading_close"
                                  }
                                ]
            done()