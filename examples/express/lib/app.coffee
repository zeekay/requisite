connect   = require 'connect'
express   = require 'express'
requisite = require 'requisite'
root      = require('./utils').root
stylus    = require 'stylus'

app = express()

app.set 'views', root '/views'
app.set 'view engine', 'jade'
app.locals.pretty = true

app.use '/static/css', stylus.middleware
  src: root '/assets/css'
  dest: root '/static/css'

app.use express.static root()

app.use '/static/js', requisite.middleware
  export: 'app'
  entry: root '/assets/js/app'
  paths: [root()]

app.use connect.logger 'dev'
app.use connect.errorHandler()

app.get '/', (req, res) ->
  res.render 'index'

module.exports = app
