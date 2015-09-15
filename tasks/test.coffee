config              = require './config.json'

gulp                = require 'gulp'
loadPlugins         = require 'gulp-load-plugins'

karma               = require 'karma'
runSequence         = require 'run-sequence'
browserSync         = require 'browser-sync'
bowerFiles          = require 'main-bower-files'
historyApiFallback  = require 'connect-history-api-fallback'

$                   = loadPlugins()
history             = historyApiFallback()


# -------------------- TASKS -------------------- #


# Copy bower test files
gulp.task 'bower:karma', ->
  gulp.src bowerFiles '**/*.js', includeDev: true
    .pipe $.concat('vendors.js')
    .pipe gulp.dest config.tmpDir.vendorScripts


# Launch server for testing
gulp.task 'serve:protractor', ->
  runSequence 'clean', [
    'index'
    'bower'
    'styles'
    'scripts'
    'templates'
  ], 'inject', 'watch', ->
    browserSync
      open: no
      notify: no
      port: 8082
      ui: port: 8092
      server:
        baseDir: config.dir.tmp
        middleware: [ history ]


# Karma unit testing
gulp.task 'karma', (cb) ->
  runSequence [
    'scripts'
    'bower:karma'
  ], ->
    karma.server.start {
      singleRun: true
      autoWatch: false
      configFile: "#{__dirname}/../#{config.sourceFiles.karma}"
    }, cb


# Protractor e2e testing
gulp.task 'webdriver:update',     $.protractor.webdriver_update
gulp.task 'webdriver:standalone', $.protractor.webdriver_standalone

gulp.task 'protractor:setup', ->
  gulp.src 'test/e2e/**/*.coffee'
    .pipe $.protractor.protractor(
      configFile: config.sourceFiles.protractor
      args: [ '--baseUrl', 'http://localhost:8082' ]
    )
    .on 'error', (err) ->
      throw err
    .on 'end', ->
      browserSync.exit()

gulp.task 'protractor', ->
  runSequence 'serve:protractor', 'webdriver:update', 'protractor:setup'

# Test
gulp.task 'test', ['karma']
