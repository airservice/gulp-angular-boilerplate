'use strict'

###*
 # @ngdoc overview
 # @name AppModule
 # @description
 # # AppModule
 #
 # Module of the application.
###

angular.module 'templates', []
angular.module 'AppModule', ['ngRoute', 'templates']


angular.module('AppModule')
  .config ($routeProvider, $locationProvider) ->

    $locationProvider.html5Mode true
    $locationProvider.hashPrefix '!'

    $routeProvider
      .when '/',
        templateUrl: '/templates/main.html'
        controller: 'MainController'
      .otherwise
        redirectTo: '/404'
        templateUrl: '/templates/404.html'
