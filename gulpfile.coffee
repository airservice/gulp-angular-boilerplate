gulp                = require 'gulp'
jade                = require 'gulp-jade'
stylus              = require 'gulp-stylus'
coffee              = require 'gulp-coffee'
inject              = require 'gulp-inject'
protractor          = require 'gulp-protractor'
sourcemaps          = require 'gulp-sourcemaps'
ngAnnotate          = require 'gulp-ng-annotate'
ngFilesort          = require 'gulp-angular-filesort'
ngTemplatecache     = require 'gulp-angular-templatecache'

del                 = require 'del'
open                = require 'open'
karma               = require 'karma'
eventStream         = require 'event-stream'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

DIR =
  tmp:       '.tmp'
  views:     '/views'
  bower:     'bower_components'

FILES =
  index:     'app/index.jade'
  views:     'app/views/**/*.jade'
  styles:    'app/styles/**/*.styl'
  scripts:   'app/scripts/**/*.coffee'

TEMP_DIR =
  views:     '.tmp/views'
  styles:    '.tmp/styles'
  scripts:   '.tmp/scripts'

TEMP_FILES =
  styles:    'styles/**/*.css'
  scripts:   'scripts/**/*.js'

TEST_CONF =
  karma:          "#{__dirname}/karma.conf.coffee"
  protractor:     "#{__dirname}/protractor.conf.coffee"


# -------------------- Development -------------------- #


# Clean tmp
gulp.task 'clean', (cb) ->
  del DIR.tmp, cb


# Compile coffee, generate source maps, reload
gulp.task 'scripts', ->
  gulp.src FILES.scripts
    .pipe sourcemaps.init()
    .pipe coffee bare: yes
    .pipe ngAnnotate single_quotes: yes
    .pipe sourcemaps.write()
    .pipe gulp.dest TEMP_DIR.scripts
    .pipe browserSync.reload stream: yes


# Compile stylus, reload
gulp.task 'styles', ->
  gulp.src FILES.styles
    .pipe stylus()
    .pipe gulp.dest TEMP_DIR.styles
    .pipe browserSync.reload stream: yes


# Compile jade views, reload
gulp.task 'views', ->
  gulp.src FILES.views
    .pipe jade pretty: yes
    .pipe ngTemplatecache root: DIR.views
    .pipe gulp.dest TEMP_DIR.scripts
    .pipe browserSync.reload stream: yes


# Compile jade index, inject styles and scripts, reload
gulp.task 'index', ['scripts', 'styles'], ->
  gulp.src FILES.index
    .pipe jade pretty: yes
    .pipe inject(
      gulp.src(bowerFiles(), read: no), name: 'bower'
    )
    .pipe inject(eventStream.merge(
      gulp.src TEMP_FILES.styles, cwd: DIR.tmp, read: no
    ,
      gulp.src TEMP_FILES.scripts, cwd: DIR.tmp
        .pipe ngFilesort()
    ))
    .pipe gulp.dest DIR.tmp
    .pipe browserSync.reload stream: yes


# Launch browser sync server
gulp.task 'serve', ['compile', 'watch'], ->
  browserSync
    notify: no
    server:
      baseDir: DIR.tmp
      routes:
        '/bower_components': DIR.bower
      middleware: [ historyApiFallback ]


# Launch server for testing
gulp.task 'serve:e2e', ['compile', 'watch'], ->
  browserSync
    notify: no
    open: false
    server:
      baseDir: DIR.tmp
      routes:
        '/bower_components': DIR.bower
      middleware: [ historyApiFallback ]


# e2e test using protractor
gulp.task 'webdriver-update', protractor.webdriver_update
gulp.task 'webdriver_standalone', protractor.webdriver_standalone

gulp.task 'protractor', ['serve:e2e', 'webdriver-update'], ->
  gulp.src 'test/e2e/**/*.coffee'
    .pipe protractor.protractor(
      configFile: TEST_CONF.protractor
      args: [ '--baseUrl', 'http://localhost:3000' ]
    )
    .on 'error', (err) ->
      throw err
    .on 'end', ->
      browserSync.exit()


# Test using karma
gulp.task 'test', ['scripts'], (cb) ->
  karma.server.start {
    singleRun: true
    autoWatch: false
    configFile: TEST_CONF.karma
  }, cb


# Watch for changes
gulp.task 'watch', ->
  gulp.watch FILES.scripts, ['scripts']
  gulp.watch FILES.styles,  ['styles']
  gulp.watch FILES.views,   ['views']
  gulp.watch FILES.index,   ['index']


# Register tasks
gulp.task 'compile', ['clean'], ->
  gulp.start 'scripts', 'styles', 'views', 'index'

gulp.task 'default', ['serve']
