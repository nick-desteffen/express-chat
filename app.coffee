express = require('express')
routes  = require('./routes')
chat    = require('./routes/chat')
http    = require('http')
path    = require('path')
redis   = require('redis')

app = express()
db = redis.createClient()

app.set('port', process.env.PORT || 3000)
app.set('views', __dirname + '/views')
app.set('view engine', 'ejs')
app.use(express.favicon())
app.use(express.logger('dev'))
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.cookieParser('your secret here'))
app.use(express.session())
app.use(app.router)
app.use(require('less-middleware')({ src: __dirname + '/public' }))
app.use(express.static(path.join(__dirname, 'public')))

if 'development' is app.get('env')
  app.use(express.errorHandler())

app.get('/', routes.index)
app.post('/chat', chat.index)

http.createServer(app).listen app.get('port'), ()->
  console.log("Express server listening on port #{app.get('port')}")

