'use strict'

module.exports = (config) ->
  config.set
    autoWatch: false
    frameworks: ['jasmine']
    browsers:   ['PhantomJS']
    files: [
      'bower_components/angular/angular.js'
      'bower_components/jquery/dist/jquery.js'
      'bower_components/angular-*/angular-*.js'

      '.tmp/scripts/**/*.js'
      'test/specs/**/*.coffee'
    ]
    plugins: [
      'karma-jasmine'
      'karma-phantomjs-launcher'
      'karma-coffee-preprocessor'
    ]
    preprocessors: '**/*.coffee': ['coffee']
