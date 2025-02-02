module ShikimoriDomain
  RU_HOSTS = %w[shikimori.one shikimori.org] + (
    Rails.env.development? ? %w[shikimori.local localhost] : []
  )
  EN_HOSTS = %w[] # + (
    # Rails.env.development? ? %w[en.shikimori.local] : []
  # )
  CLEAN_HOST = 'shikimori.one'

  HOSTS = RU_HOSTS + EN_HOSTS

  def self.matches? request
    HOSTS.include? request.host
  end
end
