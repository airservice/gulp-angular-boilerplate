gulp                = require 'gulp'
loadPlugins         = require 'gulp-load-plugins'

del                 = require 'del'
karma               = require 'karma'
eventStream         = require 'event-stream'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

$                   = loadPlugins()
reload              = browserSync.reload


# -------------------- PATHS -------------------- #


DIR =
  tmp:              '.tmp'
  templates:        '/templates'

FILES =
  index:            'app/index.jade'
  styles:           'app/styles/**/*.styl'
  scripts:          'app/scripts/**/*.coffee'
  templates:        'app/templates/**/*.jade'

TEMP_DIR =
  styles:           '.tmp/styles'
  scripts:          '.tmp/scripts'
  vendors:          '.tmp/scripts/vendors'

TEMP_FILES =
  styles:           'styles/**/*.css'
  vendors:          'scripts/vendors/*.js'
  scripts:          ['scripts/**/*.js', '!scripts/vendors/*.js']

TEST_CONF =
  karma:            "#{__dirname}/karma.conf.coffee"
  protractor:       "#{__dirname}/protractor.conf.coffee"


# -------------------- TASKS -------------------- #


# Clean tmp
gulp.task 'clean', (cb) ->
  del DIR.tmp, cb


# Compile coffee, generate source maps, reload
gulp.task 'scripts', ->
  gulp.src FILES.scripts
    .pipe $.sourcemaps.init()
    .pipe $.coffee bare: yes
    .pipe $.ngAnnotate single_quotes: yes
    .pipe $.sourcemaps.write()
    .pipe gulp.dest TEMP_DIR.scripts
    .pipe reload stream: yes


# Copy bower files
gulp.task 'bower', ->
  gulp.src bowerFiles()
    .pipe gulp.dest TEMP_DIR.vendors


# Copy bower test files
gulp.task 'bower:karma', ->
  gulp.src bowerFiles includeDev: true
    .pipe gulp.dest TEMP_DIR.vendors


# Compile stylus, reload
gulp.task 'styles', ->
  gulp.src FILES.styles
    .pipe $.stylus()
    .pipe gulp.dest TEMP_DIR.styles
    .pipe reload stream: yes


# Compile jade templates, reload
gulp.task 'templates', ->
  gulp.src FILES.templates
    .pipe $.jade pretty: yes
    .pipe $.angularTemplatecache root: DIR.templates
    .pipe gulp.dest TEMP_DIR.scripts
    .pipe reload stream: yes


# Compile jade index, inject styles and scripts, reload
gulp.task 'index', ['bower', 'scripts', 'styles'], ->
  gulp.src FILES.index
    .pipe $.jade pretty: yes
    .pipe $.inject(
      gulp.src TEMP_FILES.vendors, cwd: DIR.tmp
        .pipe $.angularFilesort()
      name: 'bower'
    )
    .pipe $.inject(eventStream.merge(
      gulp.src TEMP_FILES.styles, cwd: DIR.tmp, read: no
    ,
      gulp.src TEMP_FILES.scripts, cwd: DIR.tmp
        .pipe $.angularFilesort()
    ))
    .pipe gulp.dest DIR.tmp
    .pipe reload stream: yes


# Launch browser sync server
gulp.task 'serve', ['compile', 'watch'], ->
  browserSync
    notify: no
    server:
      baseDir: DIR.tmp
      middleware: [ historyApiFallback ]


# Launch server for testing
gulp.task 'serve:protractor', ['compile', 'watch'], ->
  browserSync
    notify: no
    open: false
    server:
      baseDir: DIR.tmp
      middleware: [ historyApiFallback ]


# Karma unit testing
gulp.task 'karma', ['bower:karma', 'scripts'], (cb) ->
  karma.server.start {
    singleRun: true
    autoWatch: false
    configFile: TEST_CONF.karma
  }, cb


# Protractor e2e testing
gulp.task 'webdriver-update',     $.protractor.webdriver_update
gulp.task 'webdriver_standalone', $.protractor.webdriver_standalone

gulp.task 'protractor', ['serve:protractor', 'webdriver-update'], ->
  gulp.src 'test/e2e/**/*.coffee'
    .pipe $.protractor.protractor(
      configFile: TEST_CONF.protractor
      args: [ '--baseUrl', 'http://localhost:3000' ]
    )
    .on 'error', (err) ->
      throw err
    .on 'end', ->
      browserSync.exit()


# Watch for changes
gulp.task 'watch', ->
  gulp.watch FILES.index,       ['index']
  gulp.watch FILES.styles,      ['styles']
  gulp.watch FILES.scripts,     ['scripts']
  gulp.watch FILES.templates,   ['templates']


# Register tasks
gulp.task 'compile', ['clean'], ->
  gulp.start 'scripts', 'styles', 'templates', 'index'

gulp.task 'default', ['serve']
