require 'fluentnode'
Vis_Node    = require('./Vis-Node')
Vis_Edge    = require('./Vis-Edge')
Vis_Options = require('./Vis-Options')

class Vis_Graph

  constructor:->
    @nodes       = []
    @edges       = []
    @options     = new Vis_Options()
    @nodes_Ids   = []

  add_Node: (id, label)=>
    if id not in @nodes_Ids
      new_Node = new Vis_Node(id, label,@)
      @nodes_Ids.push(new_Node.id)
      @nodes    .push new_Node
      new_Node
    else
      @node(id)

  add_Nodes: (ids...)=>
    for id in ids
      @add_Node(id)
    @

  add_Edge: (from, to, label)=>
    new_Edge = new Vis_Edge(from, to, label,@)
    @add_Node(new_Edge.from)
    @add_Node(new_Edge.to)
    @edges.push(new_Edge)
    new_Edge

  node: (id)=>
    for node in @nodes
      if node.id is id
        return node
    return null

  nodes_By_Id: ->
    nodesById = {}
    for node in @nodes
      nodesById[node.id] = node
    return nodesById

module.exports = Vis_Graph