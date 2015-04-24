
## Run the code below using 'Run in Atom'
require 'fluentnode'
fs = require 'fs'

project_Folder = atom.project.path
coverage_file = project_Folder.path_Combine('coverage/lcov.info')

watcher_Src =null
watcher_Test =null
watcher_Cov =null

create_Coverage = ->
  spawn = require('child_process').spawn
  proc = spawn( 'bin/lcov-code-coverage.sh',['node_modules'],{cwd:project_Folder} )
  proc.stdout.on 'data' , (data) -> console.log('stdout: ' + data)
  proc.stderr.on 'data' , (data) -> console.log('stderr: ' + data)
  proc.on 'close', (code) -> console.log(' process exited with code ' + code);

set_Code_Watcher = ->
  watch_Folder = (folder)->
    fs.watch folder, ()->
      console.log "Folder watch on #{folder} triggered, creating code coverage"
      create_Coverage();
  watcher_Src  = watch_Folder(project_Folder.path_Combine('src'))
  watcher_Test = watch_Folder(project_Folder.path_Combine('test'))

set_Watchers = (watch_Code)->
  if (set_Code_Watcher)
    set_Code_Watcher()

  watcher_Cov = fs.watchFile coverage_file, ()->
    console.log "lcov file was changed, reloading data"
    atom.workspaceView.trigger('lcov-info:toggle')
  "done"

close_Watchers = ->
  watcher_Cov.stop()
  watcher_Src.stop()
  watcher_Test.stop()

set_Watchers(false)


##simpler version (just reload)

project_Folder = atom.project.path
coverage_file = project_Folder.path_Combine('coverage/lcov.info')

set_Watchers = ()->
  watcher_Cov = fs.watchFile coverage_file, ()->
    console.log "lcov file was changed, reloading data"
    atom.workspaceView.trigger('lcov-info:toggle')
  "done"

close_Watchers = ->
  watcher_Cov.stop()


set_Watchers


###

__dirname
fs = require 'fluentnode'

console.log "open".start_Process('.')

['123'].size()

##using set Interval
action = ->
  console.log 'refreshing lcov'
  atom.workspaceView.trigger('lcov-info:toggle');

trigger = -> setInterval(action,1000)

global.loop = trigger()

#clearInterval(loop)
##




#
atom.workspaceView.trigger('lcov-info:toggle');

'done'


activePane = atom.workspaceView.getActivePaneView()
atom.project.open().then (editor) ->
  console.log editor
###
