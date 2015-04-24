require 'fluentnode'
Vis_Node = require('./Vis-Node')
Vis_Edge = require('./Vis-Edge')

class Vis_Options
  constructor: ()->
    @nodes = new Vis_Node()
    @edges = new Vis_Edge()
    delete @nodes.id
    delete @edges.from
    delete @edges.to

  _width: (value)->
    @['width'] = value
    @

  _height: (value)->
    @['height'] = value
    @

  _stabilizationIterations: (value)->
    @['stabilizationIterations'] = value
    @

  _smoothCurves: (value)=>
    @['smoothCurves']=value
    @

module.exports = Vis_Options