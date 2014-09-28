class PeopleController < ShikimoriController
  respond_to :html, only: [:show, :tooltip]
  respond_to :html, :json, only: :index
  respond_to :json, only: :autocomplete

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: -> { @resource }
  before_action :set_title, if: -> { @resource }
  before_action :role_redirect, if: :resource_id

  helper_method :search_url
  #caches_action :index, :page, :show, :tooltip, CacheHelper.cache_settings

  def index
    page_title search_title
    page_title SearchHelper.unescape(params[:search])

    @collection = postload_paginate(params[:page], 48) { search_query.fetch }
  end

  def show
    @itemtype = @resource.itemtype
  end

  def works
    page_title 'Участие в проектах'
  end

  def comments
    redirect_to @resource.url if @resource.main_thread.comments_count.zero?
    page_title 'Обсуждение'
  end

  def tooltip
  end

  def autocomplete
    @collection = PeopleQuery.new(params).complete
  end

private
  def set_title
    page_title @resource.name
  end

  def fetch_resource
    @resource = Person.find(resource_id).decorate
  end

  def search_title
    if params[:kind] == 'producer'
      'Поиск режиссёров'
    elsif params[:kind] == 'mangaka'
      'Поиск мангак'
    else
      'Поиск людей'
    end
  end

  def search_url *args
    if params[:kind] == 'producer'
      search_producers_url(*args)
    elsif params[:kind] == 'mangaka'
      search_mangakas_url(*args)
    else
      search_people_url(*args)
    end
  end

  def search_query
    PeopleQuery.new params
  end

  def role_redirect
    if @resource.seyu
      redirect_to seyu_url(@resource)
    end
  end
end
