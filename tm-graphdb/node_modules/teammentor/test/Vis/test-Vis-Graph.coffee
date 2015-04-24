Vis_Graph = require('./../../src/Vis/Vis-Graph')

describe 'Vis | test-Vis_Graph |', ->

  it 'ctor',->
    visGraph = Vis_Graph.ctor().assert_Is_Object()
    visGraph.nodes      .assert_Is_Array()
    visGraph.edges      .assert_Is_Array()
    visGraph.options    .assert_Is_Object()._width.assert_Is_Function()
    #visGraph.nodes_By_Id.assert_Is_Object()

  it 'add_Node, nodes_Ids',->
    visGraph = Vis_Graph.ctor()
    visGraph.add_Node('a' ).assert_Is_Object().id.assert_Is('a')
    visGraph.nodes.assert_Size_Is(1)
    visGraph.add_Node('a' ).id.assert_Is('a')
    visGraph.add_Node(    ).id.assert_Is_String()
    (visGraph.add_Node(null) == null).assert_Is_False()
    visGraph.add_Node('b' ).assert_Is_Object().id.assert_Is('b')
    visGraph.nodes_Ids.assert_Contains    ('a' )
    visGraph.nodes_Ids.assert_Contains    ('b')
    visGraph.nodes_Ids.assert_Not_Contains('c' )

  it 'add_Nodes, nodes_Ids',->
    Vis_Graph.ctor().add_Nodes('a','b','c','a')
                    .nodes_Ids.assert_Is_Equal_To(['a','b','c'])

  it 'add_Edge',->
    visGraph = Vis_Graph.ctor()
    visGraph.add_Edge.assert_Is_Function().invoke('a','b','c' ).assert_Is_Object()
    visGraph.nodes.assert_Size_Is     (2)
    visGraph.edges.assert_Size_Is     (1)
    visGraph.nodes_Ids.assert_Contains('a' )
    visGraph.nodes_Ids.assert_Contains('b')
    edge = visGraph.add_Edge('a','b','c' )
    edge.from .assert_Is('a')
    edge.to   .assert_Is('b')
    edge.label.assert_Is('c')
    edge.arrow .assert_Is_Function()
    edge._color.assert_Is_Function()
    edge._style.assert_Is_Function()

    visGraph.nodes.assert_Size_Is     (2)
    visGraph.edges.assert_Size_Is     (2)

  it 'node',->
    node = Vis_Graph.new().add_Node('a').assert_Is_Object()
    node.id.assert_Is('a')
    node.box  .assert_Is_Function()
    node._color.assert_Is_Function()
    node._shape.assert_Is_Function()
    assert_Is_Null(Vis_Graph.new().node('asd'))

  it 'nodes_By_Id',->
    visGraph = Vis_Graph.ctor()
    visGraph.add_Node('a')
    visGraph.nodes_By_Id()['a'].assert_Is_Object()

  it 'Vis_Edge - from_Node,to_Node',->
    visGraph = Vis_Graph.ctor()
    edge = visGraph.add_Edge('a','b')
    edge.graph().assert_Is_Equal_To(visGraph)
    edge.from_Node().id.assert_Is('a')
    edge.to_Node()  .id.assert_Is('b')

