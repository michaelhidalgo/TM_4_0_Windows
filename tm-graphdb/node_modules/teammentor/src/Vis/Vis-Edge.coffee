require 'fluentnode'

Guid = require './Guid'

class Vis_Edge
  constructor: (from, to, label, graph) ->
    @from  = from  || new Guid().raw
    @to    = to    || new Guid().raw
    if (label)
      @label = label
    @graph = ->
      graph

  from_Node: =>
    return null if not @graph()
    return @graph().node(@from)

  to_Node: =>
    return null if not @graph()
    return @graph().node(@to)


  set: (key, value)=>
    @[key]=value
    @

  _color   : (value)=> @set('color'    , value)
  _label   : (value)=> @set('label'    , value)
  _style   : (value)=> @set('style'    , value)

  #colors
  black       : ()=> @_color('black')
  blue        : ()=> @_color('blue')
  green       : ()=> @_color('green')
  red         : ()=> @_color('red')
  white       : ()=> @_color('white')

  #styles
  line        : ()-> @_style('line')
  arrow       : ()-> @_style('arrow')
  arrow_center: ()-> @_style('arrow-center')
  dash_line   : ()-> @_style('dash-line')

module.exports = Vis_Edge