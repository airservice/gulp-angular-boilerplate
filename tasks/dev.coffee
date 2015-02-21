config              = require './config.json'

gulp                = require 'gulp'
loadPlugins         = require 'gulp-load-plugins'

del                 = require 'del'
eventStream         = require 'event-stream'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

$                   = loadPlugins()
reload              = browserSync.reload


# -------------------- TASKS -------------------- #


# Clean tmp
gulp.task 'clean', (cb) ->
  del config.dir.tmp, cb


# Compile coffee, generate source maps, reload
gulp.task 'scripts', ->
  gulp.src config.files.scripts
    .pipe $.changed config.tmpDir.scripts, extension: '.js'
    .pipe $.sourcemaps.init()
    .pipe $.coffee bare: yes
    .pipe $.ngAnnotate single_quotes: yes
    .pipe $.sourcemaps.write()
    .pipe gulp.dest config.tmpDir.scripts
    .pipe reload stream: yes


# Copy bower files
gulp.task 'bower', ->
  gulp.src bowerFiles()
    .pipe gulp.dest config.tmpDir.vendors


# Compile stylus, reload
gulp.task 'styles', ->
  gulp.src config.files.styles
    .pipe $.changed config.tmpDir.styles, extension: '.css'
    .pipe $.stylus()
    .pipe gulp.dest config.tmpDir.styles
    .pipe reload stream: yes


# Compile jade templates, reload
gulp.task 'templates', ->
  gulp.src config.files.templates
    .pipe $.changed config.tmpDir.scripts, extension: '.js'
    .pipe $.jade pretty: yes
    .pipe $.angularTemplatecache root: config.dir.templates
    .pipe gulp.dest config.tmpDir.scripts
    .pipe reload stream: yes


# Compile jade index, inject styles and scripts, reload
gulp.task 'index', ['bower', 'scripts', 'styles'], ->
  gulp.src config.files.index
    .pipe $.jade pretty: yes
    .pipe $.inject(
      gulp.src config.tmpFiles.vendors, cwd: config.dir.tmp
        .pipe $.angularFilesort()
      name: 'bower'
    )
    .pipe $.inject(eventStream.merge(
      gulp.src config.tmpFiles.styles, cwd: config.dir.tmp, read: no
    ,
      gulp.src config.tmpFiles.scripts, cwd: config.dir.tmp
        .pipe $.angularFilesort()
    ))
    .pipe gulp.dest config.dir.tmp
    .pipe reload stream: yes


# Launch browser sync server
gulp.task 'serve', ['compile', 'watch'], ->
  browserSync
    notify: no
    server:
      baseDir: config.dir.tmp
      middleware: [ historyApiFallback ]


# Watch for changes
gulp.task 'watch', ->
  gulp.watch config.files.index,       ['index']
  gulp.watch config.files.styles,      ['styles']
  gulp.watch config.files.scripts,     ['scripts']
  gulp.watch config.files.templates,   ['templates']


# Register tasks
gulp.task 'compile', ['clean'], ->
  gulp.start 'scripts', 'styles', 'templates', 'index'

gulp.task 'default', ['serve']
