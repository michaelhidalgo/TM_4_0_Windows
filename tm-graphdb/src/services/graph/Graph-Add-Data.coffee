Guid               = require('teammentor').Guid
Data_Import_Util   = require '../data/Data-Import-Util'

class Graph_Add_Data

  constructor: (graph)->
    @.graph = graph

  add_Db: (type, guid, data, callback)=>
    id = @new_Short_Guid(type,guid)
    importUtil = @new_Data_Import_Util()
    importUtil.add_Triplets(id, data)
    @.graph.db.put importUtil.data, -> callback(id)

  add_Db_Contains: (source, target, callback)=>
    @.graph.add(source, 'contains', target, callback)

  add_Db_using_Type_Guid_Title: (type, guid, title, callback)=>
    @add_Db type.lower(), guid, {'guid' : guid, 'is' :type, 'title': title}, callback

  add_Is: (id, is_Value, callback)=>
    @.graph.add id,'is',is_Value, callback

  add_Title: (id, title_Value, callback)=>
    @.graph.add id,'title',title_Value, callback

  #new object Utils
  new_Short_Guid: (title, guid)->
    new Guid(title, guid).short

  new_Data_Import_Util: (data)->
    new Data_Import_Util(data)



module.exports = Graph_Add_Data