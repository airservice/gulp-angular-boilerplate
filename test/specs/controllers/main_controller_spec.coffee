'use strict'

describe 'controllers', ->
  scope = undefined
  controller = undefined

  beforeEach module('AppModule')
  beforeEach inject ($controller, $rootScope) ->
    scope      = $rootScope.$new()
    controller = $controller 'MainController', $scope: scope

  it 'should define more than 5 awesome things', ->
    expect(scope.stack).toEqual('Gulp + AngularJS + Jade + Stylus + CoffeeScript')
