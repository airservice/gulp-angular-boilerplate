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
      'title': 'Gulp'
      'url': 'http://gulpjs.com/'
      'description': 'The streaming build system'
    ,
      'title': 'AngularJS'
      'url': 'https://angularjs.org/'
      'description': 'HTML enhanced for web apps!'
    ,
      'title': 'Jade'
      'url': 'http://jade-lang.com/'
      'description': 'Clean, whitespace sensitive syntax for writing HTML'
    ,
      'title': 'Stylus'
      'url': 'http://learnboost.github.io/stylus/'
      'description': 'Expressive, robust, feature-rich CSS preprocessor'
    ,
      'title': 'CoffeeScript'
      'url': 'http://coffeescript.org/'
      'description': 'A little language that compiles into JavaScript'
    ]
