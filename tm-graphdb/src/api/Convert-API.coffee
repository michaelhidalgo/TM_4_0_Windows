Swagger_GraphDB      = require './base-classes/Swagger-GraphDB'
Wiki_Service          = require '../services/render/Wiki-Service'
Markdown_Service      = require '../services/render/Markdown-Service'

class Convert_API extends Swagger_GraphDB
    constructor: (options)->
      @.options      = options || {}
      @.options.area = 'convert'
      super(@.options)

    to_ids: (req,res)=>
      values = req.params.values              #cache_Key = "to_ids_#{values}.json"
      @.using_Graph_Find res, null, (send)->
        @.convert_To_Ids values, send

    wikitext_to_html:(req,res)=>
      wikitext = req.params.wikitext
      new Wiki_Service().to_Html wikitext, (html)->
        res.send { wikitext: wikitext, html : html}

    markdown_to_html:(req,res)=>
      markdown = req.params.markdown
      new Markdown_Service().to_Html markdown, (html,tokens)->
        res.send { markdown: markdown, html : html, tokens:tokens}

    add_Methods: ()=>
      @.add_Get_Method 'to_ids'          , ['values']
      @.add_Get_Method 'wikitext_to_html', ['wikitext']
      @.add_Get_Method 'markdown_to_html', ['markdown']
      @

module.exports = Convert_API
