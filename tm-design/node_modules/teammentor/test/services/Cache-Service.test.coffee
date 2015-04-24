require 'fluentnode'
Cache_Service = require('../../src/services/Cache-Service')
expect        = require('chai').expect
cheerio       = require('cheerio')

describe 'services | test-Cache-Service |', ->

  describe 'core',->

    cacheService = new Cache_Service()

    it 'Cache-Service ctor',->
      expect(Cache_Service).to.be.an('Function')

      expect(cacheService               ).to.be.an('Object')
      expect(cacheService._cacheFolder  ).to.be.an('String')

      expect(cacheService._cacheFolder   ).to.equal('./.tmCache')
      expect(cacheService._forDeletionTag).to.equal('.deleteCacheNext')
      expect(cacheService.area).to.equal(null)
      expect(cacheService.cacheFolder()  ).to.equal('./.tmCache'.realPath())
      expect(new  Cache_Service('aaaa').area).to.equal('aaaa')

    it 'cacheFolder', ->
      expect(cacheService.cacheFolder).to.be.an('Function')
      expect(cacheService.cacheFolder()).to.equal(process.cwd().path_Combine(cacheService._cacheFolder))

    it 'delete', ->
        expect(cacheService.delete).to.be.an('Function')

    it 'path_Key',->
      expect(cacheService.path_Key('aa')).to.equal(cacheService.cacheFolder().path_Combine('aa'))
      expect(cacheService.path_Key(null)).to.equal(null)

    it 'put, get',->
      key_Name  = 'key_'.add_Random_String(5)
      key_Value = 'value_'.add_Random_String(5)
      key_Path  = cacheService.path_Key(key_Name);

      key_Path                            .assert_File_Not_Exists()
      cacheService.put(key_Name,key_Value).assert_Is(key_Value)
      key_Path                            .assert_File_Exists()
      cacheService.get(key_Name)          .assert_Is(key_Value)
      key_Path    .file_Delete()          .assert_Is_True()

    it 'put, get (bad values)', ->
      using cacheService.put,->
        assert_Is_Null(@(null,'a' ))
        assert_Is_Null(@('a' ,null))
        assert_Is_Null(@(null,null))
        assert_Is_Null(@())
      using cacheService.get,->
        assert_Is_Null(@(null))
        assert_Is_Null(@())
      using cacheService.delete,->
        @(null).assert_Is_False()
        @().assert_Is_False()

    it 'has_Key, delete',->
      key_Name  = 'key_'.add_Random_String(5)
      using cacheService,->
        @has_Key(key_Name).assert_Is_False()
        @has_Key(null    ).assert_Is_False()
        @has_Key(''      ).assert_Is_False()
        @put(key_Name,'a').assert_Is('a')
        @has_Key(key_Name).assert_Is_True()
        @delete(key_Name ).assert_Is_True()
        @has_Key(key_Name).assert_Is_False()

    it 'setup', ->
      expect(cacheService.setup).to.be.an('Function')
      expect(cacheService.cacheFolder().file_Exists()).to.be.true

  describe 'HTTP requests |', ->
    area         = "_tmp_Http";
    cacheService = null
    cacheFolder  = null

    before ->
      cacheService = new Cache_Service(area)
      cacheFolder  = cacheService.cacheFolder()

    after ->
      #expect(cacheFolder.delete_Folder()).to.be.true

    it 'http_GET', (done)->
      cacheService.http_GET 'http://www.google.co.uk/aaa', (data, response)->
        $ = cheerio.load(data)
        (typeof(response)).                  assert_Is_Equal_To("object")
        $('title')                          .assert_Is_Object()
        $('title').html()                   .assert_Is('Error 404 (Not Found)!!1')
        response.statusCode.str()           .assert_Is('404')
        response.headers['x-xss-protection'].assert_Is('1; mode=block')
        response.request.uri.hostname       .assert_Is('www.google.co.uk')
        response.body                       .assert_Is(data)

        cacheService.http_GET 'http://www.google.co.uk/aaa', (data_From_Cache, response_From_Cache)->
          data.assert_Is(data_From_Cache)
          response.body.assert_Is(response_From_Cache.body)
          done()

    it 'json_GET', (done)->
      cacheService.json_GET 'https://github.com/status.json', (json, response)->
        (typeof(json)    )                  .assert_Is_Equal_To("object")
        (typeof(response))                  .assert_Is_Equal_To("object")
        json.status                         .assert_Is('ok')
        response.headers['x-xss-protection'].assert_Equals('1; mode=block')
        response.request.uri.hostname       .assert_Equals('github.com')
        response.request.method             .assert_Is('GET')
        cacheService.json_GET 'https://github.com/status.json', (json_From_Cache, response_From_Cache)->
          json.assert_Is(json_From_Cache)
          response.body.assert_Is(response_From_Cache.body)
          done()

    it 'json_POST', (done)->
      cacheService.json_POST 'https://teammentor.net/Aspx_Pages/TM_WebServices.asmx/Ping', {message: 'a'}, (json, response)->
        (typeof(json)    )                  .assert_Is_Equal_To("object")
        (typeof(response))                  .assert_Is_Equal_To("object")
        json.d                              .assert_Is('received ping: a')
        response.headers['x-xss-protection'].assert_Is('1; mode=block')
        response.request.uri.hostname       .assert_Is('teammentor.net')
        response.request.method             .assert_Is('POST')

        done()

  describe 'separate Cache_Service |', ->

    it 'customArea', ->
      area = "_tmp_area_".add_5_Random_Letters()
      cacheService = new Cache_Service(area)
      cacheFolder  = cacheService.cacheFolder()
      expect(cacheService.area      ).to.equal(area)
      expect(cacheFolder            ).to.contain('.tmCache')
      expect(cacheFolder            ).to.contain(cacheService.area)
      expect(cacheFolder.file_Name()).to.equal(area)
      expect(cacheFolder.exists()   ).to.be.true
      expect(cacheFolder.delete_Folder()).to.be.true


    it 'markForDeletion and delete', ->
      cacheService = new Cache_Service()

      expect(cacheService.delete         ).to.be.an('Function')
      expect(cacheService.markForDeletion).to.be.an('Function')

      cacheService._cacheFolder = "./.tmCache".add_Random_String(5)
      expect(cacheService.cacheFolder().exists()).to.be.false
      cacheService.setup()
      expect(cacheService.cacheFolder().exists()).to.be.true


      forDeleleTag_File = cacheService.cacheFolder().path_Combine(cacheService._forDeletionTag)
      expect(forDeleleTag_File).to.not.equal(cacheService.cacheFolder())
      forDeleleTag_File.file_Delete()
      expect(forDeleleTag_File             .exists()      ).to.equal(false)
      expect(cacheService.cacheFolder()    .exists()      ).to.equal(true)
      expect(cacheService.markForDeletion().file_Exists() ).to.equal(true)
      expect(forDeleleTag_File             .exists()      ).to.equal(true, 'forDeleleTag_File should exist')
      expect(cacheService.cacheFolder()    .files().size()).to.be.above(0)

      cacheService.setup()
      expect(cacheService.cacheFolder()    .exists()      ).to.equal(true)
      expect(cacheService.cacheFolder()    .files().size()).to.equal(0)

      cacheService.setup()
      expect(cacheService.cacheFolder()    .exists()      ).to.equal(true)
      expect(cacheService.cacheFolder().folder_Delete_Recursive()).to.equal.true