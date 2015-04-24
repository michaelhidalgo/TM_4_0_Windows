Vis_Options  = require('./../../src/Vis/Vis-Options')

String::remove = (value)-> @.replace value, ''

describe 'Vis | Vis_Options',->

  visOptions =  Vis_Options.ctor()

  it 'ctor',->
    Vis_Options.assert_Is_Function().ctor().assert_Is_Object()
    #console.log visOptions
    visOptions.nodes.json_pretty().assert_Is("{}")
    visOptions.edges.json_pretty().assert_Is("{}")
    #visOptions.edges.assert_Is_Equal_To({})

  #properties
  properties = ['_width', '_height','_stabilizationIterations','_smoothCurves']
  for property in properties
    do ->
      _property = property.str()
      it "property: #{property}",()->
        visOptions[_property]('abc')[_property.replace('_','')].assert_Is('abc')
