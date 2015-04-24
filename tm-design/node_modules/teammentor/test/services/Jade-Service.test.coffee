require 'fluentnode'
fs            = require('fs')
expect        = require('chai'         ).expect
Jade_Service  = require('../../src/services/Jade-Service')

describe 'services | test-Jade-Service |', ->

  it 'check ctor', ->
    jadeService  = new Jade_Service()
    expect(Jade_Service      ).to.be.an  ('Function')
    expect(jadeService       ).to.be.an  ('Object'  )
    expect(jadeService.config               ).to.be.an('Object');
    expect(jadeService.targetFolder         ).to.be.an('String');

    expect(jadeService.compileJadeFileToDisk).to.be.an('function');
    expect(jadeService.calculateTargetPath  ).to.be.an('function');
    expect(jadeService.enableCache          ).to.be.an('function');
    expect(jadeService.cacheEnabled         ).to.be.an('function');

    expect(jadeService.targetFolder         ).to.equal(jadeService.config.jade_Compilation)


  it 'enableCache , cacheEnabled', ->
    jadeService = new Jade_Service();
    expect(jadeService.cacheEnabled()    ).to.be.false
    expect(jadeService.enableCache()     ).to.equal(jadeService)
    expect(jadeService.cacheEnabled()    ).to.be.true
    expect(jadeService.enableCache(false)).to.equal(jadeService)
    expect(jadeService.cacheEnabled()    ).to.be.false
    expect(jadeService.enableCache (true )).to.equal(jadeService)
    expect(jadeService.cacheEnabled()    ).to.be.true


  it 'calculateTargetPath', ->
    jadeService = new Jade_Service();
    targetFolder        = jadeService.targetFolder;

    expect(targetFolder                   ).to.equal(jadeService.config.jade_Compilation);
    expect(jadeService.calculateTargetPath).to.be.an('Function');
    expect(jadeService.calculateTargetPath('aaa'             )).to.equal(targetFolder.path_Combine('aaa.txt'             ));
    expect(jadeService.calculateTargetPath('aaa/bbb'         )).to.equal(targetFolder.path_Combine('aaa_bbb.txt'         ));
    expect(jadeService.calculateTargetPath('aaa/bbb/ccc'     )).to.equal(targetFolder.path_Combine('aaa_bbb_ccc.txt'     ));
    expect(jadeService.calculateTargetPath('aaa/bbb.jade'    )).to.equal(targetFolder.path_Combine('aaa_bbb_jade.txt'    ));
    expect(jadeService.calculateTargetPath('aaa/bbb.ccc.jade')).to.equal(targetFolder.path_Combine('aaa_bbb_ccc_jade.txt'));
    expect(targetFolder.folder_Exists()).to.be.true

  describe 'with tmp jade file |',->
    jade_File     = '_tmp_index.jade'
    jade_Code     = "h2#title this is a an h2 title"
    expected_Html = '<h2 id=\"title\">this is a an h2 title</h2>'

    before ->
      jade_Code.saveAs(jade_File)
      jade_File.assert_File_Exists();

    after ->
      jade_File.file_Delete().assert_Is_True();

    it 'compileJadeFileToDisk', ()->
      using new Jade_Service(),->
        @compileJadeFileToDisk('a').assert_Is_False()
        targetPath = @calculateTargetPath(jade_File);
        if (targetPath.file_Not_Exists())
          @compileJadeFileToDisk(jade_File).assert_Is_True()
        jadeTemplate  = require(targetPath)
        expect(jadeTemplate  ).to.be.an('function')
        expect(jadeTemplate()).to.be.an('string')

        html = jadeTemplate()
        expect(html).to.contain expected_Html

    it 'compileJadeFileToDisk (confirm re-creation)', ()->
      using new Jade_Service(),->
        targetPath = @calculateTargetPath(jade_File);
        compiled_Jade = targetPath.file_Contents()
        "aaaa".saveAs(targetPath)
        @compileJadeFileToDisk(jade_File).assert_Is_True()
        targetPath.file_Contents().assert_Is(compiled_Jade)

    it 'renderJadeFile', ()->
      jadeService = new Jade_Service().enableCache();

      renderedJade = jadeService.renderJadeFile(jade_File);

      renderedJade.assert_Is_Not '';
      renderedJade.assert_Is     expected_Html

      expect(jadeService.renderJadeFile('a')).to.equal    ("");

    it 'renderJadeFile (cache disabled)', ()->
      using new Jade_Service(),->
        @.renderJadeFile(jade_File).assert_Is expected_Html
        @.renderJadeFile('aa')     .assert_Is('')