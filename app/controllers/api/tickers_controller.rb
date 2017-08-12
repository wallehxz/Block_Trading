class Api::TickersController < ApplicationController

  def last_ticker
    tick = get_all_ticker
    Block.all.each do |block|
      if tick[block.english]
        generate_ticker(block.id,tick[block.english]['ticker'])
      end
    end
    quotes_analysis
    market_report
  end

  def get_all_ticker
    yzmb_url = 'http://api.btc38.com/v1/ticker.php'
    res = Faraday.get do |req|
      req.url yzmb_url
      req.params['c'] = 'all'
      req.params['mk_type'] = 'cny'
    end
    tick = JSON.parse(res.body) rescue nil
  end

  def generate_ticker(block,tick)
    ticker = BlockTicker.new
    ticker.block_id = block
    ticker.last_price = tick['last']
    ticker.buy_price = tick['buy']
    ticker.sell_price = tick['sell']
    ticker.that_date = Date.current.to_s
    ticker.save
  end

  def sync_balance
    if balances = remote_balance
      balances.each do |k,v|
        if v.to_f > 0 && !k.include?('_balance_')
          sync_local(k.chomp('_balance'),v)
        end
      end
    end
    render json:{code:200,msg:'sync success'}
  end

  def remote_balance
    time = Time.now.to_i
    body_hash = {}
    body_hash['key'] = Settings.btc_key
    body_hash['skey'] = Settings.btc_secret
    body_hash['time'] = time
    body_hash['md5'] = Block.generate_md5(time)
    res = Faraday.post do |req|
      req.url 'http://api.btc38.com/v1/getMyBalance.php'
      req.body = body_hash
    end
    puts res
    JSON.parse(res.body)
  end

  def sync_local(block,amount)
    balance = Balance.find_by_block(block)
    if balance
      blance.update_attributes(amount:amount)
    else
      Balance.create(block:block,amount:amount)
    end
  end

  def quotes_analysis
    FocusBlock.where(activation:true).each do |item|
      market_quotes(item) rescue nil
    end
  end

  def market_report
    string = ''
    Block.named.each do |item|
      string << block_analysis(item) rescue ''
    end
    Notice.market_report(Settings.receive_email,string).deliver_now if string.present?
    render json:{code:200,msg:'report success'}
  end

  def block_analysis(block)
    market = block.tickers.last(12).map {|x| x.last_price}
    if market.max == market[-2] && market[-2] > market[-1]
      return rise_tip(block,market)
    elsif market.min == market[-2] && market[-1] > market[-2]
      return fall_tip(block,market)
    end
  end

  def rise_tip(block,market)
    tip = ''
    string = ''
    if block.maximun_24h == market.max
      tip << ", 24小时最低价: #{block.minimum_24h}，最高价: #{block.maximun_24h}, 涨幅: #{amplitude(block.minimum_24h,block.maximun_24h)}%"
    elsif block.yesterday_maximun < market.max
      tip << ", 2天内历史最高价：#{block.yesterday_maximun} 涨幅：#{amplitude(block.yesterday_maximun,market[-1])}%"
    elsif block.three_day_maximun < market.max && block.three_day_maximun < block.yesterday_maximun
      tip << ", 3天内历史最高价：#{block.three_day_maximun} 涨幅：#{amplitude(block.three_day_maximun,market[-1])}%"
    end
    string << rise_template(block.english,market[-1],tip)
  end

  def fall_tip(block,market)
    tip = ''
    string = ''
    if block.minimum_24h == market.min
      tip << ", 24小时最高价: #{block.maximun_24h}, 最低价: #{block.minimum_24h}, 涨幅: #{amplitude(block.maximun_24h,block.minimum_24h)}%"
    elsif block.yesterday_minimum > market.min
      tip << ", 2天内历史最低价： #{block.yesterday_minimum} 跌幅： #{amplitude(block.yesterday_minimum,market.min)}%"
    elsif block.three_day_minimum > market.min && block.three_day_minimum < block.yesterday_minimum
      tip << ", 3天内历史最低价：#{block.yesterday_minimum}  跌幅：#{amplitude(block.three_day_minimum,market.min)}%"
    end
    string << fall_template(block.english,market[-1],tip)
  end

  def market_quotes(focus)
    market = focus.tickers.last(12).map {|x| x.last_price}
    inflection_point(focus,market) if market.size == 12
  end

  def inflection_point(focus,market)
    if market.max == market[-2] && market[-2] > market[-1]
      short_sell_block(focus,market)
    elsif market.min == market[-2] && market[-1] > market[-2]
      short_buy_block(focus,market)
    end
  end

  def short_sell_block(focus,market)
    if focus.block.maximun_24h == market[-2]
      sell_price = focus.tickers.last.buy_price
      if balance = focus.block.balance
        if balance.amount > 1 && sell_price > balance.buy_price
          generate_order(focus.block.english,2,balance.amount,sell_price)
        end
      end
    end
  end

  def short_buy_block(focus,market)
    if focus.block.minimum_24h == market[-2]
      buy_price = focus.tickers.last.sell_price
      balance = focus.block.balance
      if balance.nil? || (balance && balance.amount < 1)
        generate_order(focus.block.english,1,focus.total_price / buy_price,buy_price)
      end
    end
  end

  def sell_block(focus)
    sell_price = focus.tickers.last.buy_price
    balance = focus.block.balance
    if balance.amount > 0 && sell_price > (balance.buy_price * focus.sell_amplitude)
      generate_order(focus.block.english,2,balance.amount * focus.sell_weights,sell_price)
    end
  end

  def buy_block(focus,market)
    buy_price = focus.tickers.last.sell_price
    if focus.block.yesterday_minimum > buy_price && focus.block.yesterday_minimum < buy_price
      generate_order(focus.block.english,1,focus.buy_amount * 0.3,buy_price)
    elsif focus.block.three_day_minimum > buy_price
      generate_order(focus.block.english,1,focus.buy_amount * 0.5,buy_price)
    elsif minimum_24h == market.min
      generate_order(focus.block.english,1,focus.buy_amount * 0.1,buy_price)
    end
  end

  def generate_order(block,business,amount,price)
    order = PendingOrder.new
    order.block = block
    order.business = business
    order.amount = amount
    order.price = price
    order.save
  end

  private

    def amplitude(old_price,new_price)
      return ((new_price - old_price) / old_price * 100).to_i
    end

    def rise_template(block,last_price,opt)
      "<p style='color:#CC0066'>〖#{block}〗处于涨跌点，当前价格: #{last_price}#{opt}</p>"
    end

    def fall_template(block,last_price,opt)
      "<p style='color:#339966'>〖#{block}〗处于跌涨点，当前价格: #{last_price}#{opt}</p>"
    end
end