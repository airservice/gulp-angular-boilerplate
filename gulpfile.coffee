gulp                = require 'gulp'
jade                = require 'gulp-jade'
stylus              = require 'gulp-stylus'
coffee              = require 'gulp-coffee'
inject              = require 'gulp-inject'
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
  karma:     "#{__dirname}/karma.conf.coffee"

TEMP_DIR =
  views:     '.tmp/views'
  styles:    '.tmp/styles'
  scripts:   '.tmp/scripts'

TEMP_FILES =
  styles:    'styles/**/*.css'
  scripts:   'scripts/**/*.js'


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


# Test using karma
gulp.task 'test', ['scripts'], (cb) ->
  karma.server.start {
    singleRun: true
    autoWatch: false
    configFile: FILES.karma
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
