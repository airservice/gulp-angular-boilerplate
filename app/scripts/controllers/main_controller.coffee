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
    $scope.stack = 'Gulp + AngularJS + Jade + Stylus + CoffeeScript'
