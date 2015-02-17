'use strict'

describe 'stackList', ->
  page = undefined

  beforeEach ->
    browser.get '/'
    page = require './main_po'

  it 'displays the stack list', ->
    expect(page.list.count()).toEqual(5)
