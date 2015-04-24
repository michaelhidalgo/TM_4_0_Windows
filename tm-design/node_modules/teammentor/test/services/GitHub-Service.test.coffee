require ('fluentnode')
GitHub_Service = require('../../src/services/GitHub-Service')
expect         = require('chai').expect

describe 'services | test-GitHub-Service |', ->

  @.timeout(3500)
  gitHubService          = new GitHub_Service()
  gitHubService.useCache = true

  it 'test constructor', ->
    expect(GitHub_Service).to.be.an('Function')
    #gitHubService = new GitHub_Service()
    expect(gitHubService         ).to.be.an('Object')
    expect(gitHubService.key     ).to.be.an('String')
    expect(gitHubService.secret  ).to.be.an('String')
    expect(gitHubService.version ).to.be.an('String')
    expect(gitHubService.debug   ).to.be.an('boolean')
    expect(gitHubService.useCache).to.be.an('boolean')
    expect(gitHubService.github  ).to.be.an('object')

  it 'enableCache',->
    expect(gitHubService.useCache).to.be.true
    gitHubService.useCache = false
    expect(gitHubService.useCache).to.be.false
    expect(gitHubService.enableCache()).to.equal(gitHubService)
    expect(gitHubService.useCache).to.be.true

  it 'cacheService (when cache disabled)', (done)->
      using new GitHub_Service(),->
        @useCache.assert_Is_False()
        @cacheService null,
                      (data)-> data.assert_Is({a:24}); done(),   #main_callback
                      (next)-> next({a:24})                      #noData_callback


  it 'authenticate',->
    expect(gitHubService.authenticate  ).to.be.an('Function')
    expect(gitHubService.authenticate()).to.equal(gitHubService)
    expect(gitHubService.github        ).to.not.equal (null)
    expect(gitHubService.github.auth   ).to.be.an('Object')

    expect(gitHubService.github.auth.type  ).to.equal('oauth')
    expect(gitHubService.github.auth.key   ).to.equal(gitHubService.key)
    expect(gitHubService.github.auth.secret).to.equal(gitHubService.secret)


  it 'rateLimit', (done)->
    expect(gitHubService.rateLimit  ).to.be.an('Function')
    gitHubService.rateLimit (data)->
        expect(data                     ).to.be.an('Object')
        expect(data.resources           ).to.be.an('Object')
        expect(data.resources.core      ).to.be.an('Object')
        expect(data.resources.core.limit).to.be.an('number')
        #console.log(data.resources.core)
        #console.log("\n remaining : " + data.resources.core.remaining)
        #console.log(" next reset: " + new Date(data.resources.core.reset * 1000).toLocaleTimeString())
        done()

  it 'gist_Raw', (done)->
    expect(gitHubService.gist_Raw  ).to.be.an('Function')
    gistId = "ad328585205f67569e0d"
    gitHubService.gist_Raw gistId, (data)->
        expect(data                     ).to.be.an('Object')
        files = Object.keys(data.files)
        expect(files).to.be.an("Array")
        expect(files).to.contain('Search_Data_Validation.json' )
        expect(files).to.contain('Search_Input_Validation.json')
        done()

  it 'gist_Raw (bad gistOd)', (done)->
    expect(gitHubService.gist  ).to.be.an('Function')
    gistId = "ad328585205f67569e0d_AAAA"

    gitHubService.gist_Raw gistId, (data)->
      assert_Is_Null(data)
      done()

  it 'gist', (done)->
    expect(gitHubService.gist  ).to.be.an('Function')
    gistId = "ad328585205f67569e0d"
    file   = 'Search_Data_Validation.json'

    gitHubService.gist gistId, file, (data)->
      expect(data).to.be.an('Object')
      searchData = JSON.parse(data.content)

      expect(searchData      ).to.be.an('Object')
      expect(searchData.title).to.equal('Data Validation')

      #check that value is in cache
      gitHubService.gist gistId, file, (data_fromCache)->
        data.assert_Is(data_fromCache)
        done()

  it 'gist (bad file)', (done)->
    expect(gitHubService.gist  ).to.be.an('Function')
    gistId = "ad328585205f67569e0d"
    file   = 'Search_Data_Validation_AAAA.json'

    gitHubService.gist gistId, file, (data)->
      assert_Is_Null(data)
      done()

  it 'gist (bad gistId)', (done)->
    expect(gitHubService.gist  ).to.be.an('Function')
    gistId = "ad328585205f67569e0d_AAAA"
    file   = 'Search_Data_Validation.json'

    gitHubService.gist gistId, file, (data)->
      assert_Is_Null(data)
      done()


  it 'repo_Raw', (done)->
    expect(gitHubService.repo_Raw).to.be.an('Function')
    user = "TMContent"
    repo = "TM_Test_GraphData"
    gitHubService.repo_Raw user, repo, (data)->
        #console.log(data)
        expect(data).to.be.an('Object')
        done()

  it 'tree_Raw', (done)->
    expect(gitHubService.tree_Raw).to.be.an('Function')
    user   = "TMContent"
    repo   = "TM_Test_GraphData"
    sha    = 'master'
    gitHubService.tree_Raw user, repo, sha, (data)->
        #console.log(data)
        files = (item.path for item in data.tree)
        #console.log(files)
        #console.log("There were #{files.length} files")
        expect(data).to.be.an('Object')
        done()

  it 'file', (done)->
    expect(gitHubService.file).to.be.an('Function')
    user   = "TMContent"
    repo   = "TM_Test_GraphData"
    sha    = 'SearchData/Data_Validation.json'
    gitHubService.file user, repo, sha, (data)->
        expect(data).to.be.an('String')
        searchData = JSON.parse(data)
        expect(searchData      ).to.be.an('Object')
        expect(searchData.title).to.equal('Data Validation')
        done()
