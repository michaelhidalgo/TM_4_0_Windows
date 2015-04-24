require 'fluentnode'

Guid = require './Guid'

class Vis_Node
  constructor: (id, label, graph)->
    @id = id || new Guid().raw
    if (label)
      @label = label
    @graph = ->
      graph

  add_Edge: (to,label)=>
    @graph().add_Edge(@id,to,label)

  set: (key, value)=>
    @[key]=value
    @
  _color    : (value)=> @set('color'    , value)
  _mass     : (value)=> @set('mass'     , value)
  _fontColor: (value)=> @set('fontColor', value)
  _fontSize : (value)=> @set('fontSize' , value)
  _label    : (value)=> @set('label'    , value)
  _shape    : (value)=> @set('shape'    , value)
  _title    : (value)=> @set('title'    , value)

  #colors
  black       : ()=> @_color('black')._fontColor('white')
  blue        : ()=> @_color('blue')
  green       : ()=> @_color('green')._fontColor('white')
  red         : ()=> @_color('red')._fontColor('white')
  white       : ()=> @_color('white')

  #shapes
  box         : ()-> @_shape('box')
  circle      : ()-> @_shape('circle')
  dot         : ()-> @_shape('dot')
  eclipse     : ()-> @_shape('eclipse')
  database    : ()-> @_shape('database')
  image       : ()-> @_shape('image')
  #label       : ()-> @_shape('label')
  star        : ()-> @_shape('star')
  triangle    : ()-> @_shape('triangle')
  triangleDown: ()-> @_shape('triangleDown')

module.exports = Vis_Node