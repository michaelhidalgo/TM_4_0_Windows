require('fluentnode')

node_uuid = require('node-uuid')

class Guid
  constructor: (title, guid)->
    @raw   = guid || node_uuid.v4()
    @short = (if (title) then title + "-" else "") +  @raw.split('-').last()

module.exports = Guid