# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

SteamSauna = SteamSauna || {}

class SteamSauna.Welcome
  selectedFriends: []

  constructor: () ->
    @listenForClicks()
    @listenForSubmit()

  listenForClicks: () ->
    $('ul').on 'click', 'li a', (event) =>
      event.preventDefault()

      @toggleFriend $(event.target).parents('li')

  listenForSubmit: () ->
    $('#submit').on 'click', () ->
      console.log @selectedFriends

  toggleFriend: ($li) ->
    id = $li.attr('id')
    index = @selectedFriends.indexOf(id)

    if index != -1
      @selectedFriends.splice(index, 1)
      $li.one 'mouseleave', -> $li.removeClass 'selected'
    else
      @selectedFriends.push(id)
      $li.one 'mouseleave', -> $li.addClass 'selected'

$(document).ready ->
  new SteamSauna.Welcome()

