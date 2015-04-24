fs     = require('fs')
path   = require('path')
jade   = require('jade')
#Config = require('../Config');

class Config
  constructor: (cache_folder, enable_Jade_Cache)->
    @cache_folder      = path.join(process.cwd(), cache_folder || ".tmCache")
    @jade_Compilation  = path.join(@cache_folder, "jade_Compilation")
    #@library_Data      = path.join(@cache_folder, "library_Data")
    @version           = '0.1.1'
    @enable_Jade_Cache = enable_Jade_Cache || false

class JadeService
  constructor: (config)->
    @config = config || new Config()
    @targetFolder = @.config.jade_Compilation

  enableCache : (value)->

    if(value != undefined)
      this.config.enable_Jade_Cache = value;
    else
      this.config.enable_Jade_Cache = true
    @

  cacheEnabled: ()=>
    @config.enable_Jade_Cache

  calculateTargetPath: (fileToCompile)=>
    return null if not fileToCompile
    filename = fileToCompile.replace(/\//g,'_').replace(/\./g,'_') + '.txt'
    @config.cache_folder.folder_Create()
    @targetFolder.folder_Create().path_Combine(filename)


  compileJadeFileToDisk: (fileToCompile)=>
    fileToCompile_Path = path.join(process.cwd(), fileToCompile)

    if (fs.existsSync(fileToCompile_Path)==false)
      return false

    targetFile_Path = this.calculateTargetPath(fileToCompile);

    if (fs.existsSync(targetFile_Path))
      fs.unlinkSync(targetFile_Path)

    fileContents = fs.readFileSync(fileToCompile_Path,  "utf8");
    file_Compiled = jade.compileClient fileContents , { filename:fileToCompile_Path, compileDebug : false}

    exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' +
                  'module.exports = ' + file_Compiled;


    fs.writeFileSync(targetFile_Path, exportCode);
    return fs.existsSync(targetFile_Path);


  renderJadeFile: (jadeFile, params)=>
    targetFile_Path = @calculateTargetPath(jadeFile)
    return "" if not targetFile_Path

    if (not @cacheEnabled())
      targetFile_Path.delete_File() if targetFile_Path.file_Exists()
      jadeFile_Path = process.cwd().path_Combine(jadeFile)
      if jadeFile_Path.file_Exists()
        return jade.renderFile(jadeFile_Path,params)
      return "";

    if targetFile_Path.file_Not_Exists()
      return "" if not @compileJadeFileToDisk(jadeFile)

    return require(targetFile_Path)(params)

#  @.config.createCacheFolders();                   # ensure cache folders exists

module.exports = JadeService