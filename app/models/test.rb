class Test < ActiveRecord::Base
  def self.anemone
    # 'http://frenchweb.fr/'
    urls = ['https://www.meetboxon.com/', 'https://www.octobat.com']
    Anemone.crawl(urls, {obey_robots_txt: true, depth_limit: 3, user_agent: 'Jarvis', threads: 4}) do |anemone|
      anemone.storage = Anemone::Storage.Redis
      anemone.on_every_page do |page|
        ap page.url
        if include_stripe?(page)
          ap "HAHAHA!!! Stripe detected BITCH!"
        else
          ap "Where are you hiding?"
        end
      end
    end
  end


  def self.include_stripe?(page)
    unless page.doc.nil?
      !page.doc.at('script')['src'].nil? && page.doc.at('script')['src'].include?('stripe.com') ? true : false
    end
  end

end
