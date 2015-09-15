'use strict'

###*
 # @ngdoc function
 # @name AppModule.controller:MainController
 # @description
 # # MainController
 # Controller of the AppModule
###

angular.module('AppModule')
  .controller 'MainController', ($scope) ->
    $scope.stackList = [
      'title':        'Gulp'
      'website':      'http://gulpjs.com/'
      'description':  'The streaming build system'
    ,
      'title':        'AngularJS'
      'website':      'https://angularjs.org/'
      'description':  'HTML enhanced for web apps!'
    ,
      'title':        'Jade'
      'website':      'http://jade-lang.com/'
      'description':  'Clean, whitespace sensitive syntax for writing HTML'
    ,
      'title':        'Stylus'
      'website':      'http://learnboost.github.io/stylus/'
      'description':  'Expressive, robust, feature-rich CSS preprocessor'
    ,
      'title':        'CoffeeScript'
      'website':      'http://coffeescript.org/'
      'description':  'A little language that compiles into JavaScript'
    ]
