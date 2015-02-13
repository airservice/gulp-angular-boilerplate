gulp                = require 'gulp'
jade                = require 'gulp-jade'
stylus              = require 'gulp-stylus'
coffee              = require 'gulp-coffee'
inject              = require 'gulp-inject'
sourcemaps          = require 'gulp-sourcemaps'
ngAnnotate          = require 'gulp-ng-annotate'

del                 = require 'del'
open                = require 'open'
vinylPaths          = require 'vinyl-paths'
eventStream         = require 'event-stream'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

dir =
  cwd: './'
  tmp: './.tmp/'

files =
  index:     'app/index.jade'
  views:     'app/views/**/*.jade'
  styles:    'app/styles/**/*.styl'
  scripts:   'app/scripts/**/*.coffee'

tmpDir =
  root:      '.tmp'
  views:     '.tmp/views'
  styles:    '.tmp/styles'
  scripts:   '.tmp/scripts'

tmpFiles =
  styles:    'styles/**/*.css'
  scripts:   'scripts/**/*.js'


# -------------------- Development -------------------- #


# Clean tmp
gulp.task 'clean', ->
  gulp.src('.tmp/*')
    .pipe vinylPaths(del)


# Compile coffee, generate source maps, reload
gulp.task 'scripts', ->
  gulp.src files.scripts
    .pipe sourcemaps.init()
    .pipe coffee bare: yes
    .pipe ngAnnotate single_quotes: yes
    .pipe sourcemaps.write()
    .pipe gulp.dest tmpDir.scripts
    .pipe browserSync.reload stream: yes


# Compile stylus, reload
gulp.task 'styles', ->
  gulp.src files.styles
    .pipe stylus()
    .pipe gulp.dest tmpDir.styles
    .pipe browserSync.reload stream: yes


# Compile jade views, reload
gulp.task 'views', ->
  gulp.src files.views
    .pipe jade pretty: yes
    .pipe gulp.dest tmpDir.views
    .pipe browserSync.reload stream: yes


# Compile jade index, inject styles and scripts, reload
gulp.task 'index', ['scripts', 'styles'], ->
  gulp.src files.index
    .pipe jade pretty: yes
    .pipe inject(
      gulp.src(bowerFiles(), cwd: dir.cwd, read: no), name: 'bower'
    )
    .pipe inject(eventStream.merge(
      gulp.src(tmpFiles.styles, cwd: dir.tmp, read: no)
    ,
      gulp.src(tmpFiles.scripts, cwd: dir.tmp, read: no)
    ))
    .pipe gulp.dest tmpDir.root
    .pipe browserSync.reload stream: yes


# Launch browser sync server
gulp.task 'serve', ['compile', 'watch'], ->
  browserSync
    notify: no
    server:
      baseDir: '.tmp'
      routes:
        '/bower_components': './bower_components'
      middleware: [ historyApiFallback ]


# Watch for changes
gulp.task 'watch', ->
  gulp.watch files.scripts, ['scripts']
  gulp.watch files.styles,  ['styles']
  gulp.watch files.views,   ['views']
  gulp.watch files.index,   ['index']


# Register tasks
gulp.task 'compile', ['scripts', 'styles', 'views', 'index']
gulp.task 'default', ['serve']
