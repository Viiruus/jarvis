class Core < ActiveRecord::Base

  @patterns = Array.new

  # A hero in Marvel :-)
  # Spiderman crawl all the web
  def self.spiderman
    # urls = ['http://frenchweb.fr/']
    urls = ['http://www.chimi.co/', 'http://www.greats.com/', 'https://www.azendoo.com/']
    # urls = ['http://www.greats.com/', 'http://calmtheham.com/', 'http://www.sarahandabraham.com/', 'http://eu.shop.fiftythree.com/', 'http://tattly.com/', 'http://shop.eatboutique.com/', 'http://www.leifshop.com/']
    # urls = ['https://twitter.com/chimiapp']
    # urls = ['https://abs.twimg.com/sticky/default_profile_images/default_profile_1_200x200.png']
    # urls = ['http://frenchweb.fr/', 'http://startups.co.uk/', 'https://www.crunchbase.com/', 'http://www.techcityuk.com/', 'http://leweb.co/', 'http://techcrunch.com/']
    # urls = ['https://www.pageyourself.com']
    # urls = ['http://www.thefamily.co/fellowship/']
    # urls = ['http://betalist.com/', 'http://www.moblized.com/', 'http://www.thefamily.co/fellowship/', 'http://frenchweb.fr/', 'http://startups.co.uk/', 'https://www.crunchbase.com/', 'http://www.techcityuk.com/', 'http://leweb.co/', 'http://techcrunch.com/']
    # urls = ['https://angel.co/', 'https://www.reddit.com/']
    Anemone.crawl(urls, {verbose: true, discard_page_bodies: true, obey_robots_txt: true, user_agent: 'Jarvis', threads: 4}) do |anemone|
      try = 0
      hit = 0

      anemone.storage = Anemone::Storage.Redis

      anemone.skip_links_like(%r{.*(jpg|png|svg|gif|jpeg|tiff)$}, %r{.*(twitter|linkedin|facebook|youtube|amazon|pinterest|instagram|viadeo|foursquare|yelp|google|bing|yahoo|vimeo)\..*})

      anemone.on_every_page do |page|
        try += 1
        @patterns = Array.new

        stripe = include_stripe?(page)
        shopify = include_shopify?(page)

        ap @patterns

        unless @patterns.empty?
          ap 'stripe: '+stripe.to_s
          ap 'shopify: '+shopify.to_s
          if !host_already_saved?(page.url.host)
            host = Host.new(host: page.url.host)
            host.save

            @patterns.each do |pattern|
              p = Pattern.find_by_name(pattern)
              unless p.nil?
                ap p.name
                match = host.matches.build(match_date: Date.now, pattern_id: p.id)
                match.save
              end
            end

            hit += 1
          else
            host = Host.find_by_host(page.url.host)
            unless host.nil?
              @patterns.each do |pattern|
                p = Pattern.find_by_name(pattern)
                unless p.nil?
                  ap p.name

                  if !match_already_saved?(host, p)
                    match = host.matches.build(match_date: Date.now, pattern_id: p.id)
                    match.save
                  end
                end
              end
            end
          end
        end

        ap try.to_s
        ap hit.to_s
      end

      # anemone.focus_crawl do |page|
      #   # ap page.links.slice(0..50)
      #   page.links.slice(0..50)
      # end

      anemone.after_crawl do
        ap 'Nombre total de pages parsées: '+try.to_s
        ap 'Nombre total de pages touchées: '+hit.to_s
      end

    end
  end

  # Return +true+ if this page is saved in the table hosts
  # else +false+
  def self.host_already_saved?(host)
    !Host.find_by_host(host).nil?
  end

  # Return +true+ if a match is saved with this host and this pattern
  # else +false+
  def self.match_already_saved?(host, pattern)
    Match.where(host_id: host.id, pattern_id: pattern.id).any?
  end

  # Return +true+ if the card exist in Trello
  # else +false+
  def self.already_saved_in_trello?(host)
    Host.where(host: host, added_to_trello: true).any?
  end


  # Return +true+ if 'stripe.com' match with the attribute src of the script element of the page
  # else +false+
  def self.include_stripe?(page)
    _include = false
    unless page.doc.nil?
      unless page.doc.css('script').nil?
        page.doc.css('script').find do |el|
          if !el['src'].nil?
            if !(%r{.*(stripe.com).*} =~ el['src']).nil?
              _include = true
              @patterns.push('stripe')
            end
          end
        end
      end
    end

    return _include
  end


  # Return +true+ if '.myshopify.com' match with the attribute src of the script element of the page
  # else +false+
  def self.include_shopify?(page)
    _include = false
    unless page.doc.nil?
      unless page.doc.css('script').nil?
        page.doc.css('script').find do |el|
          if !el.content.blank?
            if !(%r{.*\.(myshopify.com)} =~ el.content).nil?
              _include = true
              @patterns.push('shopify')
            end
          end
        end
      end
    end

    return _include
  end


  # Add a card to Trello (Jarvis list)
  def self.add_stripe_website_to_trello(uri, host)
    # Trello -> Jarvis list
    begin
      list = List.find('55757c349b192c1550561d24')
      unless list.nil?
        card = Card.create(list_id: list.id, name: uri.host, desc: "Website:"+uri.to_s, pos: 'bottom')
      end
    rescue Exception => e
      ap 'Problem with Trello'
      puts e.message
      puts e.backtrace.inspect
    else
      host.update_attributes(added_to_trello: true)
    end
  end

end
