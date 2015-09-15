config              = require './config.json'

gulp                = require 'gulp'
loadPlugins         = require 'gulp-load-plugins'

del                 = require 'del'
runSequence         = require 'run-sequence'
eventStream         = require 'event-stream'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

$                   = loadPlugins()
reload              = browserSync.reload
history             = historyApiFallback()


# -------------------- TASKS -------------------- #


# Clean tmp
gulp.task 'clean', (cb) ->
  del config.dir.tmp, cb


# Copy bower styles
gulp.task 'bower:styles', ->
  gulp.src bowerFiles('**/*.css')
    .pipe $.concat('vendors.css')
    .pipe gulp.dest config.tmpDir.vendorStyles


# Copy bower scripts
gulp.task 'bower:scripts', ->
  gulp.src bowerFiles('**/*.js')
    .pipe $.concat('vendors.js')
    .pipe gulp.dest config.tmpDir.vendorScripts


# Copy bower files
gulp.task 'bower', (cb) ->
  runSequence ['bower:styles', 'bower:scripts'], cb


# Compile coffee, generate source maps, reload
gulp.task 'scripts', ->
  gulp.src config.sourceFiles.scripts
    .pipe $.sourcemaps.init()
    .pipe $.coffee bare: yes
    .pipe $.ngAnnotate single_quotes: yes
    .pipe $.sourcemaps.write()
    .pipe gulp.dest config.tmpDir.scripts
    .pipe reload stream: yes


# Compile stylus, reload
gulp.task 'styles', ->
  gulp.src config.sourceFiles.styleRoot
    .pipe $.stylus()
    .pipe gulp.dest config.tmpDir.styles
    .pipe reload stream: yes


# Compile jade templates, reload
gulp.task 'templates', ->
  gulp.src config.sourceFiles.templates
    .pipe $.jade pretty: yes
    .pipe $.angularTemplatecache root: config.dir.templates
    .pipe gulp.dest config.tmpDir.scripts
    .pipe reload stream: yes


# Compile jade index, inject styles and scripts, reload
gulp.task 'index', ->
  gulp.src config.sourceFiles.index
    .pipe $.jade pretty: yes
    .pipe gulp.dest config.dir.tmp
    .pipe reload stream: yes


# Inject styles and scripts, reload
gulp.task 'inject', ->
  gulp.src config.outputFiles.index, cwd: config.dir.tmp
    .pipe $.inject(
      gulp.src config.outputFiles.vendorStyles, cwd: config.dir.tmp, read: no
      name: 'bower'
    )
    .pipe $.inject(
      gulp.src config.outputFiles.vendorScripts, cwd: config.dir.tmp, read: no
      name: 'bower'
    )
    .pipe $.inject(eventStream.merge(
      gulp.src config.outputFiles.styles, cwd: config.dir.tmp, read: no
    ,
      gulp.src config.outputFiles.scripts, cwd: config.dir.tmp
        .pipe $.angularFilesort()
    ))
    .pipe gulp.dest config.dir.tmp
    .pipe reload stream: yes


# Watch for changes
gulp.task 'watch', ->
  gulp.watch config.sourceFiles.index,       ['index']
  gulp.watch config.sourceFiles.styles,      ['styles']
  gulp.watch config.sourceFiles.scripts,     ['scripts']
  gulp.watch config.sourceFiles.templates,   ['templates']


# Launch browser sync server
gulp.task 'serve', ->
  runSequence 'clean', [
    'index'
    'bower'
    'styles'
    'scripts'
    'templates'
  ], 'inject', 'watch', ->
    browserSync
      notify: no
      port: 8080
      ui: port: 8090
      server:
        baseDir: config.dir.tmp
        middleware: [ history ]


# Default
gulp.task 'default', ['serve']
