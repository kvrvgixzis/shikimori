require_dependency 'traffic_entry'
require_dependency 'calendar_entry'
require_dependency 'site_statistics'

class PagesController < ShikimoriController
  include CommentHelper
  include Sidekiq::Paginator

  respond_to :html, except: [:news]
  respond_to :rss, only: [:news]

  # график онгоингов
  def ongoings
    @page_title = 'Календарь онгоингов'

    @ongoings = CalendarsQuery.new.fetch_grouped
    @topic = Topic.find(94879).decorate
  end

  # о сайте
  def about
    @page_title = 'О сайте'
    @statistics = SiteStatistics.new
    @topic = Topic.find(84739).decorate
  end

  # rss с новостями
  def news
    @topics = if params[:kind] == 'anime'
      AnimeNews
        .where.not(action: AnimeHistoryAction::Episode)
        .joins('inner join animes on animes.id=linked_id and animes.censored=false')
        .order(created_at: :desc)
        .limit(15)
        .to_a
    else
      Entry
        .where(type: Topic.name, broadcast: true)
        .order(created_at: :desc)
        .limit(10)
        .to_a
    end

    response.headers['Content-Type'] = 'application/rss+xml; charset=utf-8'
  end

  # пользовательское соглашение
  def user_agreement
    @page_title = 'Пользовательское соглашение'
  end

  # 404 страница
  def page404
    @page_title = "Страница не найдена"
    render 'pages/page404', layout: false, status: 404, formats: :html
  end

  # страница с ошибкой
  def page503
    @page_title = "Ошибка"
    render 'pages/page503', layout: false, status: 503, formats: :html
  end

  # страница обратной связи
  def feedback
    @feedback_message = Message.new from_id: (current_user.try(:id) || User::GuestID), to_id: User::Admins.first, kind: MessageType::Private
  end

  # отображение юзер-агента пользователя
  def user_agent
    render text: request.user_agent
  end

  # тестовая страница
  def test
    @traffic = Rails.cache.fetch("traffic_#{Date.today}") { YandexMetrika.new.traffic_for_months 18 }
  rescue Faraday::ConnectionFailed
  end

  # страница для теста эксепшенов
  def raise_exception
    raise 'test'
  end

  # информация закрытии регистрации с гугла и яндекса
  def disabled_registration
  end

  # статистика сервера
  def admin_panel
    raise Forbidden unless user_signed_in? && current_user.admin?
    df = %x{df | head -n 2 | tail -n 1}.strip.split(/\s+/)
    disk_total = df[1].to_f
    disk_free = df[3].to_f
    @disk_space = (((disk_total-disk_free) / disk_total)*100).round(2)

    mem = %x(free -m).try :split, /\s+/

    if mem
      mem_total = mem[8].to_f
      mem_free = mem[17].to_f
      @mem_space = (((mem_total-mem_free) / mem_total)*100).round(2)
      @mem_space = 99 if @mem_space.nan?

      swap_total = mem[19].to_f
      swap_free = mem[21].to_f
      @swap_space = (((swap_total-swap_free) / swap_total)*100).round(2)
      @swap_space = 99 if @swap_space.nan?
    end

    @calendar_update = AnimeCalendar.last.try :created_at
    @last_episodes_message = Message.where(kind: :episode).last.try :created_at
    @calendar_unrecognized = Rails.cache.read 'calendar_unrecognized'

    @proxies_count = Proxy.count

    socket = TCPSocket.open 'localhost', '11211'
    socket.send "stats\r\n", 0

    statistics = []
    loop do
      data = socket.recv(4096)
      if !data || data.length == 0
        break
      end
      statistics << data
      if statistics.join.split(/\n/)[-1] =~ /END/
        break
      end
    end
    stat = statistics.join.split("\r\n").select {|v| v =~ /STAT (?:bytes|limit_maxbytes) / }.map {|v| v.match(/\d+/)[0].to_f }
    @memcached_space = ((stat[0]/stat[1]) * 100).round(2) # ((1 - (stat[0]-stat[1]) / stat[0])*100).round(2)

    @redis_keys = ($redis.info['db0'] || 'keys=0').split(',')[0].split('=')[1].to_i

    unless Rails.env.test?
      @sidkiq_stats = Sidekiq::Stats.new
      @sidkiq_enqueued = Sidekiq::Queue
        .all
        .map {|queue| page "queue:#{queue.name}", queue.name, 100 }
        .map {|data| data.third }
        .flatten
        .map {|v| JSON.parse v }
        .sort_by {|v| Time.at v['enqueued_at'] }

      @sidkiq_busy = Sidekiq::Workers.new.to_a.map {|v| v[2]['payload'] }.sort_by {|v| Time.at v['enqueued_at'] }

      @sidkiq_retries = page('retry', 'retries', 100)[2]
        .flatten
        .select {|v| v.kind_of? String }
        .map {|v| JSON.parse v }
        .sort_by {|v| Time.at v['enqueued_at'] }
    end

    @animes_to_import = Anime.where(imported_at: nil).count
    @mangas_to_import = Manga.where(imported_at: nil).count
    @characters_to_import = Character.where(imported_at: nil).count
    @people_to_import = Person.where(imported_at: nil).count
  end

  def tableau
    render json: {
      messages: user_signed_in? ? current_user.unread_count : 0
    }
  end

  def bb_codes
  end
end
