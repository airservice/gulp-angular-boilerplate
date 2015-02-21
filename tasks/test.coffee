config              = require './config.json'

gulp                = require 'gulp'
loadPlugins         = require 'gulp-load-plugins'

karma               = require 'karma'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

$                   = loadPlugins()


# -------------------- TASKS -------------------- #


# Copy bower test files
gulp.task 'bower:karma', ->
  gulp.src bowerFiles includeDev: true
    .pipe gulp.dest config.tmpDir.vendors


# Launch server for testing
gulp.task 'serve:protractor', ['compile', 'watch'], ->
  browserSync
    notify: no
    open: false
    server:
      baseDir: config.dir.tmp
      middleware: [ historyApiFallback ]


# Karma unit testing
gulp.task 'karma', ['bower:karma', 'scripts'], (cb) ->
  karma.server.start {
    singleRun: true
    autoWatch: false
    configFile: "#{__dirname}/../#{config.files.karma}"
  }, cb


# Protractor e2e testing
gulp.task 'webdriver-update',     $.protractor.webdriver_update
gulp.task 'webdriver_standalone', $.protractor.webdriver_standalone

gulp.task 'protractor', ['serve:protractor', 'webdriver-update'], ->
  gulp.src 'test/e2e/**/*.coffee'
    .pipe $.protractor.protractor(
      configFile: config.files.protractor
      args: [ '--baseUrl', 'http://localhost:3000' ]
    )
    .on 'error', (err) ->
      throw err
    .on 'end', ->
      browserSync.exit()
