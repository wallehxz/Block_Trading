class Api::QuotesController < ApplicationController

  def hit_tickers
    Quote.where(state:true).each do |item|
      sync_quote(item) rescue nil
    end
    quotes_report
    render json:{code:200}
  end

  def sync_quote(block)
    # price = Nokogiri::HTML(open(block.source)).at_css(block.anchor).children.text
    price = block.sync_price rescue 0
    local_ticker(block,price) if price && price.to_f > 0
  end

  def local_ticker(block,price)
    QuoteTicker.create(quote_id: block.id, last_price:price, that_date: Date.current.to_s)
  end

  def quotes_report
    current_hour = Time.now.hour
    string = ''
    Quote.where(state:true).each do |item|
      string << quote_analysis(item) rescue ''
    end
    if string.present?
      User.sms_yunpian(string) if current_hour > 8 #白天发送短信
      Notice.quotes_report(Settings.receive_email,string).deliver_now if current_hour < 9 #夜晚推送邮件
    end
  end

  def quote_analysis(block)
    tip = ''
    quote_24h = block.tickers.last(48).map {|x| x.last_price}  #24小时数据点
    quote_12h = block.tickers.last(24).map {|x| x.last_price}  #12小时数据点
    return '' if quote_12h.size < 20
    if quote_24h.max == quote_24h[-1]
      tip << ",最高点,涨幅#{amplitude(quote_24h.min,quote_24h[-1])}%"
    elsif quote_24h.max == quote_24h[-2]
      tip << ",涨跌点,跌幅#{amplitude(quote_24h.min,quote_24h[-1])}%"
    elsif quote_24h.min == quote_24h[-1]
      tip << ",最低点,跌幅#{amplitude(quote_24h.max,quote_24h[-1])}%"
    elsif quote_24h.min == quote_24h[-2]
      tip << ",跌涨点,跌幅#{amplitude(quote_24h.max,quote_24h[-1])}%"
    elsif quote_12h[-1] > quote_12h[-2] && quote_12h[-1] > block.ma5_one && quote_12h[-2] < block.ma5_two && quote_12h[-3] < block.ma5_three
      tip << ",MA5买入点,涨幅#{amplitude(quote_12h.min,quote_12h[-1])}%"
    elsif quote_12h[-1] < quote_12h[-2] && quote_12h[-1] < block.ma5_one && quote_12h[-2] > block.ma5_two && quote_12h[-3] > block.ma5_three
      tip << ",MA5卖出点,跌幅#{amplitude(quote_12h.max,quote_12h[-1])}%"
    end
    color_array = ['#FF9933','#FF6699','#CC66CC','#CC3366','#996666','#6666FF']
    return "<p style='color:#{color_array[rand(6)]}'>#{block.block},价格 #{quote_12h[-1]}#{tip}</p>" if tip.present?
    tip
  end

private

  def amplitude(old_price,new_price)
    return ((new_price - old_price) / old_price * 100).to_i
  end

end