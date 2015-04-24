
supertest = require 'supertest'
express   = require 'express'

describe '| _issues | regresion-tests-1 |',->

  describe 'Issue 421 - Specific search causes Express error', (done)->

    mock_app = null

    before ->
      app      = new express()
      app.get '/', (req,res)-> res.send '42 is the answer'
      app.get '/:id', (req,res)-> res.send 'throws with $%'
      app.use (err, req, res, next)->
          #console.error(err.stack)
          res.status(500)
             .send(err.message)

      mock_app = supertest(app)

    it '/', (done)->
      mock_app.get('/')
              .expect(200)
              .end (err,res)->
                res.text.assert_Is '42 is the answer'
                done()

    it '/$%', (done)->
      mock_app.get('/$%')
              .expect(500)
              .end (err,res)->
                res.text.assert_Is "Failed to decode param '$%'"
                done()