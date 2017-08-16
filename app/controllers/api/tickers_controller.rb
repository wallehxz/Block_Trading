class Api::TickersController < ApplicationController

  def last_ticker
    tick = get_all_ticker
    Block.all.each do |block|
      if tick[block.english]
        generate_ticker(block.id,tick[block.english]['ticker'])
      end
    end
    quotes_analysis
    focus_extremum_report
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
      balance.update_attributes(amount:amount)
    else
      Balance.create(block:block,amount:amount)
    end
  end

  def market_report
    string = ''
    Block.named.each do |item|
      string << block_analysis(item) rescue ''
    end
    Notice.market_report(Settings.receive_email,string).deliver_now if string.present?
    render json:{code:200,msg:'market report success'}
  end

  def block_analysis(block)
    market = block.tickers.last(24).map {|x| x.last_price}
    if market.max == market[-2] && market[-2] > market[-1]
      return rise_tip(block,market) if block.maximun_24h == market.max
    elsif market.min == market[-2] && market[-1] > market[-2]
      return fall_tip(block,market) if block.minimum_24h == market.min
    end
  end

  def rise_tip(block,market)
    string = ''
    tip = ", 24小时最低价: #{block.minimum_24h}，最高价: #{block.maximun_24h}, 涨幅: #{amplitude(block.minimum_24h,block.maximun_24h)}%"
    if block.yesterday_maximun < market.max
      tip << ", 2天内历史最高价：#{block.yesterday_maximun} 涨幅：#{amplitude(block.yesterday_maximun,market[-1])}%"
    elsif block.three_day_maximun < market.max && block.three_day_maximun < block.yesterday_maximun
      tip << ", 3天内历史最高价：#{block.three_day_maximun} 涨幅：#{amplitude(block.three_day_maximun,market[-1])}%"
    end
    string << rise_template(block.english,market[-1],tip)
  end

  def fall_tip(block,market)
    string = ''
    tip = ", 24小时最高价: #{block.maximun_24h}, 最低价: #{block.minimum_24h}, 涨幅: #{amplitude(block.maximun_24h,block.minimum_24h)}%"
    if block.yesterday_minimum > market.min
      tip << ", 2天内历史最低价： #{block.yesterday_minimum} 跌幅： #{amplitude(block.yesterday_minimum,market.min)}%"
    elsif block.three_day_minimum > market.min && block.three_day_minimum < block.yesterday_minimum
      tip << ", 3天内历史最低价：#{block.yesterday_minimum}  跌幅：#{amplitude(block.three_day_minimum,market.min)}%"
    end
    string << fall_template(block.english,market[-1],tip)
  end

  def quotes_analysis
    FocusBlock.where(activation:true).each do |item|
      market_quotes(item)
    end
  end

  def market_quotes(focus)
    market = focus.tickers.last(24).map {|x| x.last_price}
    inflection_point(focus,market) if market.size > 0
  end

  def inflection_point(focus,market)
    if market.max == market[-2] && market[-2] > market[-1]
      short_sell_block(focus,market) if focus.hight_frequency?
    elsif market.min == market[-2] && market[-1] > market[-2]
      short_buy_block(focus,market) if focus.hight_frequency?
    elsif market.max == market[-1]
      sell_block(focus,1.15) if focus.hight_frequency?
    elsif  market.min == market[-1]
      if focus.hight_frequency? && market.min < focus.block.yesterday_minimum
        buy_block(focus,0.2) if focus.block.orders.where("created_at >= ? and business = ?",Time.now.beginning_of_day,'1').count == 0
      end
    end
  end

  def short_sell_block(focus,market)
    if focus.block.continuous_rise?
      if focus.block.yesterday_maximun < market[-2]
        sell_block(focus,1.15)
      end
    else
      sell_block(focus,1.0618)
    end
  end

  def short_buy_block(focus,market)
    balance = focus.block.balance
    if focus.block.continuous_decline?
      if balance
        if focus.block.yesterday_minimum > market[-2]
          if balance.amount < 1
            buy_block(focus,1.15)
          elsif balance.amount > 1 && balance.buy_price > market[-1] && market[-2] > balance.buy_price * 0.75
            buy_block(focus,0.15) if focus.block.orders.where("created_at >= ? and business = ?",Time.now.beginning_of_day,'1').count == 0 #每天只追买一次
          elsif balance.amount > 1 && balance.buy_price > market[-1] && market[-2] < balance.buy_price * 0.75
            stop_loss_block(focus)
          end
        end
      else
        buy_block(focus,1.15)
      end
    else
      if balance
        if balance.amount < 1
          buy_block(focus,1)
        elsif balance.amount > 1 && balance.buy_price > market[-1] && market[-2] < focus.block.yesterday_minimum
          buy_block(focus,0.1) if focus.block.orders.where("created_at >= ? and business = ?",Time.now.beginning_of_day,'1').count == 0 #每天只追买一次
        elsif balance.amount > 1 && balance.buy_price > market[-1] &&  market[-2] < balance.buy_price * 0.75
          stop_loss_block(focus)
        end
      else
        buy_block(focus,1)
      end
    end
  end

  def sell_block(focus,margin)
    sell_price = focus.tickers.last.buy_price
    if balance = focus.block.balance
      if balance.amount > 1 && sell_price >= balance.buy_price * margin
        generate_order(focus.block.english,2,balance.amount.to_i,sell_price)
      end
    end
  end

  def buy_block(focus,margin)
    buy_price = focus.tickers.last.sell_price
    generate_order(focus.block.english,1,(focus.total_price / buy_price).to_i * margin,buy_price)
  end

  def stop_loss_block(focus)
    sell_price = focus.tickers.last.buy_price
    generate_order(focus.block.english,2,balance.amount.to_i,sell_price)
  end

  def generate_order(block,business,amount,price)
    order = PendingOrder.new
    order.block = block
    order.business = business
    order.amount = amount
    order.price = price
    order.save
  end

  def report_balance
    string = ''
    Balance.named.each do |item|
      string << block_worth_statistical(item) rescue ''
    end
    Notice.report_balance(Settings.receive_email,string).deliver_now if string.present?
    render json:{code:200,msg:'balance report success'}
  end

  def focus_extremum_report
    string = ''
    FocusBlock.where(activation:true).each do |item|
      string << focus_block_analysis(item.block) rescue ''
    end
    Notice.focus_report(Settings.receive_email,string).deliver_now if string.present?
    render json:{code:200,msg:'focus report success'}
  end

  def focus_block_analysis(block)
    quotes = block.tickers.last(96).map{|x| x.last_price}
    if quotes.max == quotes[-1]
      return hight_point_template(block)
    elsif quotes.min == quotes[-1]
      return low_point_template(block)
    end
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

    def hight_point_template(block)
      "<p style='color:#CC0066'>#{block.full_name} 处于最高价值点，当前价格: #{block.tickers.last.last_price}#{', 历史三天连续上涨' if block.ifcontinuous_rise?}#{', 历史三天连续下跌' if block.continuous_decline?}</p>"
    end

    def low_point_template(block)
      "<p style='color:#339966'>#{blockfull_name} 处于最低价值点，当前价格: #{block.tickers.last.last_price}#{', 历史三天连续上涨' if block.ifcontinuous_rise?}#{', 历史三天连续下跌' if block.continuous_decline?}</p>"
    end

    def block_worth_statistical(item)
      color_array = ['#FF9933','#FF6699','#CC66CC','#CC3366','#996666','#6666FF']
      if item.amount > 1 && item.chain.present?
        price = item.chain.tickers.last.last_price
        return "<p style='color:#{color_array[rand(6)]}'>#{item.chain.full_name} 持有数量: #{item.amount}，最新价格: #{price}，价值: ￥#{(item.amount * price).to_i}</p>"
      else
        return "<p style='color:#{color_array[rand(6)]}'>〖#{item.block}〗持有数量: #{item.amount}</p>"
      end
    end
end