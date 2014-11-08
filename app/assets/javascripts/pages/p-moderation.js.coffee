# получение комментария
$comment = (node) ->
  $(node).closest('.b-abuse_request').find('.b-comment')

$moderation = (node) ->
  $(node).closest('.b-abuse_request').find('.b-request_resolution .moderation')

@on 'page:load', 'bans_index', ->
  # сокращение высоты инструкции
  $('.b-brief').check_height(150)

  # принятие или отказ запроса
  $('.moderation .take, .moderation .deny').on 'ajax:success', ->
    $comment(@).data('object')._reload()
    $moderation(@).hide()

  ## NOTE: порядок следования функций ajax:success важен
  ## редактирвоание коммента
  #$(document.body).on 'ajax:success', '.shiki-editor', (e, data) ->
    #$(".comment-#{data.id}").replaceWith data.html

  ## принятие или отказ запроса
  #$(document.body).on 'ajax:success', '.request-control .take, .request-control .deny', ->
    #reload $comment(@)

  ## сабмит формы бана пользователю
  #$(document.body).on 'ajax:success', 'form.ban', (e, data) ->
    #e.stopImmediatePropagation()
    #$(".comment-#{data.comment_id}").html data.comment_html
    #hide_actions @

  # кнопка бана или предупреждения
  $('.moderation .ban, .moderation .warn').on 'ajax:success', (e, html) ->
    e.stopImmediatePropagation()
    $moderation(@).find('.moderation-buttons').hide()

    $form = $(@).closest('.b-abuse_request').find('.ban-form')
    $form.html html
    if $(@).hasClass 'warn'
      $form.find('#ban_duration').val '0m'

      if $(@).closest('.b-abuse_request').find('.b-spoiler_marker').length
        $form.find('#ban_reason').val 'спойлеры'

    # закрытие формы бана
    $('.form-cancel', $form).on 'click', ->
      $moderation(@).find('.moderation-buttons').show()
      $(@).closest('.ban-form').empty()

