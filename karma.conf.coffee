'use strict'

module.exports = (config) ->
  config.set
    autoWatch: false
    frameworks: ['jasmine']
    browsers:   ['PhantomJS']
    files: [
      '.tmp/scripts/vendors/vendors.js'

      '.tmp/scripts/**/*.js'
      'test/specs/**/*.coffee'
    ]
    plugins: [
      'karma-jasmine'
      'karma-phantomjs-launcher'
      'karma-coffee-preprocessor'
    ]
    preprocessors: '**/*.coffee': ['coffee']
