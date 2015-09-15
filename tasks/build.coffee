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


# Clean build
gulp.task 'clean:build', (cb) ->
  del config.dir.build, cb


# Copy bower styles
gulp.task 'bower:styles:build', ->
  gulp.src bowerFiles('**/*.css')
    .pipe $.concat('vendors.css')
    .pipe $.minifyCss()
    .pipe $.rev()
    .pipe $.rename extname: '.min.css'
    .pipe gulp.dest config.buildDir.styles


# Copy bower scripts
gulp.task 'bower:scripts:build', ->
  gulp.src bowerFiles('**/*.js')
    .pipe $.concat('vendors.js')
    .pipe $.uglify()
    .pipe $.rev()
    .pipe $.rename extname: '.min.js'
    .pipe gulp.dest config.buildDir.scripts


# Copy bower files
gulp.task 'bower:build', (cb) ->
  runSequence ['bower:styles:build', 'bower:scripts:build'], cb


# Compile coffee
gulp.task 'scripts:build', ->
  gulp.src config.sourceFiles.scripts
    .pipe $.coffee bare: yes
    .pipe $.ngAnnotate single_quotes: yes
    .pipe $.concat('app.js')
    .pipe $.uglify()
    .pipe $.rev()
    .pipe $.rename extname: '.min.js'
    .pipe gulp.dest config.buildDir.scripts


# Compile stylus
gulp.task 'styles:build', ->
  gulp.src config.sourceFiles.styleRoot
    .pipe $.stylus compress: true
    .pipe $.minifyCss()
    .pipe $.rev()
    .pipe $.rename extname: '.min.css'
    .pipe gulp.dest config.buildDir.styles


# Compile jade templates, reload
gulp.task 'templates:build', ->
  gulp.src config.sourceFiles.templates
    .pipe $.jade()
    .pipe $.angularTemplatecache root: config.dir.templates
    .pipe $.uglify()
    .pipe $.rev()
    .pipe $.rename extname: '.min.js'
    .pipe gulp.dest config.buildDir.scripts


# Compile jade index, inject styles and scripts
gulp.task 'index:build', ->
  gulp.src config.sourceFiles.index
    .pipe $.jade()
    .pipe $.inject(eventStream.merge(
      gulp.src config.outputFiles.styles, cwd: config.dir.build, read: no
    ,
      gulp.src config.outputFiles.scripts, cwd: config.dir.build
        .pipe $.angularFilesort()
    ))
    .pipe $.htmlmin removeComments: true
    .pipe gulp.dest config.dir.build


# Watch for changes
gulp.task 'watch:build', ->
  gulp.watch config.sourceFiles.index,       ['index:build']
  gulp.watch config.sourceFiles.styles,      ['styles:build']
  gulp.watch config.sourceFiles.scripts,     ['scripts:build']
  gulp.watch config.sourceFiles.templates,   ['templates:build']


# Register tasks
gulp.task 'build', (cb) ->
  runSequence 'clean:build', [
    'bower:build'
    'styles:build'
    'scripts:build'
    'templates:build'
  ], 'index:build', cb


# Launch browser sync server
gulp.task 'serve:build', ->
  runSequence 'build', 'watch', ->
    browserSync
      notify: no
      port: 8081
      ui: port: 8091
      server:
        baseDir: config.dir.build
        middleware: [ history ]
