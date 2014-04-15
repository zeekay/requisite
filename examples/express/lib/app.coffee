connect   = require 'connect'
express   = require 'express'
requisite = require 'requisite'
root      = require('./utils').root
stylus    = require 'stylus'

app = express()

app.set 'views', root '/views'
app.set 'view engine', 'jade'
app.locals.pretty = true

# Stylus middleware. Serves bunlded CSS/Stylus files from assets/css at
# static/css.
app.use '/static/css', stylus.middleware
  src: root 'assets/css'
  dest: root 'static/css'

# Express static middleware. Having this first in the middleware stack ensures
# that static js files are still served normally, instead of being bunlded by
# requisite.
app.use express.static root()

# Requisite middleware. Takes an entry module and bundles all dependencies
# required from there. Serves bundled JavaScript files from assets/js at
# static/js.
app.use '/static/js', requisite.middleware
  # Entry point for our client-side code is assets/js/app.coffee. The extension
  # is optional, requisite will figure it out.
  entry: root 'assets/js/app'

  # Export entry module globally as 'app'
  export: 'app'

  # Additional paths to look for required modules in
  paths: [root()]

app.use connect.logger 'dev'
app.use connect.errorHandler()

app.get '/', (req, res) ->
  res.render 'index'

module.exports = app
