Guid = require('../../src/Vis/Guid')


describe 'Vis | test-Guid |', ->

  it 'check ctor',->
    Guid.assert_Is_Function()
    guid = new Guid()
    guid.assert_Is_Object()
    guid.raw.assert_Is_Object()
    guid.short.assert_Is_Object()
    (typeof(guid.raw )).assert_Is_Equal_To('string')
    (typeof(guid.short)).assert_Is_Equal_To('string')

    guid.raw  .assert_Length_Is(36)
    guid.short.assert_Length_Is(12)
    guid.raw  .assert_Contains(guid.short)

  it 'check ctor (title)',->
    title = (5).random_Letters()
    guid = new Guid(title)
    guid.short.split('-')         .assert_Size_Is(2)
    guid.short.split('-').first() .assert_Equals(title)
    guid.short.split('-').second().assert_Equals(guid.raw.split('-').last())


  it 'check ctor (title,guid)',->
    title = (5).random_Letters()
    guid = new Guid(title)
    new Guid(title, guid.raw).raw.assert_Is_Equal_To(guid.raw)




