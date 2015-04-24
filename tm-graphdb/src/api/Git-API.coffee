require 'fluentnode'

child_process = require('child_process')

class Git_API
    constructor: (options)->
      @.options        = options || {}
      @.swaggerService = @options.swaggerService

      @commands =
            status: { name: 'status' , params: ['status']}
            head  : { name: 'head'   , params: ['log', '-1', '--pretty=%H' ]}
            remote: { name: 'remote' , params: ['remote', '-v']}
            log   : { name: 'log'    , params: ['log', '--graph', '--pretty=oneline', '-15']}
            pull  : { name: 'pull'   , params: ['pull', 'origin']}

    git_Exec_Method : (command)=>
      (req,res)=>
          result = ''
          options = { cwd : __dirname}
          using child_process.spawn('git', command.params),->
              @.stdout.on 'data', (data)->
                result += data.str()
              @.stderr.on 'data', (data)->
                result += data.str()
              @.on 'exit'       , ()->
                res.send JSON.stringify(result)
              @.on 'error'       , (err)->
                log err
                res.send JSON.stringify(result)

    add_Git_Command: (command)=>
      get_Command =
            spec   : { path : "/git/#{command.name}/", nickname : command.name}
            action : @git_Exec_Method(command)


      @.swaggerService.addGet(get_Command)

    add_Methods: ()=>
      @add_Git_Command(@.commands.status)
      @add_Git_Command(@.commands.head)
      @add_Git_Command(@.commands.remote)
      @add_Git_Command(@.commands.log)
      @add_Git_Command(@.commands.pull)


module.exports = Git_API