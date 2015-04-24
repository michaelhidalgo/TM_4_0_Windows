Vis_Node  = require('./../../src/Vis/Vis-Node')

describe 'Vis | Vis-Node',->

  visNode =  Vis_Node.ctor('a','b')

  it 'ctor',->
    Vis_Node.assert_Is_Function().ctor().assert_Is_Object()
                                 .id    .assert_Is_String()
    Vis_Node.ctor('abc').id.assert_Is("abc")
    Vis_Node.ctor(     ).id.assert_Contains("-")
    Vis_Node.ctor('abc').json_pretty().assert_Is("{\n  \"id\": \"abc\"\n}")
    visNode.id   .assert_Is('a')
    visNode.label.assert_Is('b')
    Vis_Node.ctor(null,null,'the-graph').graph().assert_Is('the-graph')

  it 'add_Edge',->
    _from  = null
    _to    = null
    _label = null
    graph = {}
    graph.add_Edge = (from,to,label)->
      _from  = from
      _to    = to
      _label = label
    Vis_Node.ctor('from','label_node',graph).add_Edge('to','label_edge')
    _from .assert_Is('from')
    _to   .assert_Is('to')
    _label.assert_Is('label_edge')

  it 'set'       ,-> visNode.set('key','---').key     .assert_Is('---')
  it '_color'    ,-> visNode._color(   'abc').color   .assert_Is('abc')
  it '_mass'     ,-> visNode._mass(    '10' ).mass    .assert_Is('10' )
  it '_fontSize' ,-> visNode._fontSize('11' ).fontSize.assert_Is('11' )
  it '_fontSize' ,-> visNode._fontSize('12' ).fontSize.assert_Is('12' )
  it '_label'    ,-> visNode._label(   'dfg').label   .assert_Is('dfg')
  it '_shape'    ,-> visNode._shape(   'hij').shape   .assert_Is('hij')
  it '_title'    ,-> visNode._title(   'klm').title   .assert_Is('klm')


  #colors
  colors = ['black','blue','green','red','white']
  for color in colors
    do (color)->
      it "color: #{color}", ->
       visNode[color]().color.assert_Is(color)

  #shapes
  shapes = ['box', 'circle','dot','eclipse','database','image','star','triangle','triangleDown']
  for shape in shapes
    do (shape)->
      it "shape: #{shape}", ->
        visNode[shape]().shape.assert_Is(shape)

