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


# Clean build
gulp.task 'clean:build', (cb) ->
  del config.dir.build, cb


# Compile coffee
gulp.task 'scripts:build', ->
  gulp.src config.files.scripts
    .pipe $.coffee bare: yes
    .pipe $.ngAnnotate single_quotes: yes
    .pipe $.uglify()
    .pipe $.concat('app.js')
    .pipe $.rev()
    .pipe $.rename extname: '.min.js'
    .pipe gulp.dest config.buildDir.scripts


# Copy bower files
gulp.task 'bower:build', ->
  gulp.src bowerFiles()
    .pipe $.uglify()
    .pipe $.concat('vendors.js')
    .pipe $.rev()
    .pipe $.rename extname: '.min.js'
    .pipe gulp.dest config.buildDir.scripts


# Compile stylus, reload
gulp.task 'styles:build', ->
  gulp.src config.files.styles
    .pipe $.stylus compress: true
    .pipe $.rev()
    .pipe $.rename extname: '.min.css'
    .pipe gulp.dest config.buildDir.styles


# Compile jade templates, reload
gulp.task 'templates:build', ->
  gulp.src config.files.templates
    .pipe $.jade()
    .pipe $.angularTemplatecache root: config.dir.templates
    .pipe $.uglify()
    .pipe $.rev()
    .pipe $.rename extname: '.min.js'
    .pipe gulp.dest config.buildDir.scripts


# Compile jade index, inject styles and scripts, reload
gulp.task 'index:build', ['bower:build', 'scripts:build', 'styles:build'], ->
  gulp.src config.files.index
    .pipe $.jade()
    .pipe $.inject(eventStream.merge(
      gulp.src config.outputFiles.styles, cwd: config.dir.build, read: no
    ,
      gulp.src config.outputFiles.scripts, cwd: config.dir.build
        .pipe $.angularFilesort()
    ))
    .pipe $.htmlmin removeComments: true
    .pipe gulp.dest config.dir.build
    .pipe browserSync.reload stream: yes

# Launch browser sync server
gulp.task 'serve:build', ['build', 'watch:build'], ->
  browserSync
    notify: no
    server:
      baseDir: config.dir.build
      middleware: [ historyApiFallback ]

# Watch for changes
gulp.task 'watch:build', ->
  gulp.watch config.files.index,       ['index:build']
  gulp.watch config.files.styles,      ['styles:build']
  gulp.watch config.files.scripts,     ['scripts:build']
  gulp.watch config.files.templates,   ['templates:build']

# Register tasks
gulp.task 'build', ['clean:build'], ->
  gulp.start 'scripts:build', 'styles:build', 'templates:build', 'index:build'
