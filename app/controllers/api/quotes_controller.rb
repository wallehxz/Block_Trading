class Api::QuotesController < ApplicationController

  def hit_tickers
    Quote.where(state:true).each do |item|
      sync_quote(item)
    end
    quotes_report
    render json:{code:200}
  end

  def sync_quote(block)
    price = Nokogiri::HTML(open(block.source)).at_css(block.anchor).children.text
    local_ticker(block,price) if price && price.to_f > 0
  end

  def local_ticker(block,price)
    QuoteTicker.create(quote_id: block.id, last_price:price, that_date: Date.current.to_s)
  end

  def quotes_report
    string = ''
    Quote.where(state:true).each do |item|
      string << quote_analysis(item) rescue ''
    end
    Notice.quotes_report(Settings.receive_email,string).deliver_now if string.present?
  end

  def quote_analysis(block)
    tip = ''
    quote_24h = block.tickers.last(24).map {|x| x.last_price}
    if quote_24h.max == quote_24h[-1]
      tip << "，处于最高卖出点，涨幅#{amplitude(quote_24h[0],quote_24h[-1])}%"
    elsif quote_24h.min == quote_24h[-1]
      tip << "，处于最高买入点，跌幅#{amplitude(quote_24h[0],quote_24h[-1])}%"
    elsif quote_24h[-1] > quote_24h[-2] && quote_24h[-1] > block.ma5_recent && quote_24h[-2] < block.ma5_previous
      tip << "，处于MA5买入点，涨幅#{amplitude(quote_24h[0],quote_24h[-1])}%"
    elsif quote_24h[-1] < quote_24h[-2] && quote_24h[-1] < block.ma5_recent && quote_24h[-2] > block.ma5_previous
      tip << "，处于MA5卖出点，跌幅#{amplitude(quote_24h[0],quote_24h[-1])}%"
    end
    color_array = ['#FF9933','#FF6699','#CC66CC','#CC3366','#996666','#6666FF']
    return "<p style='color:#{color_array[rand(6)]}'>#{block.platform} - #{block.block}, 最新价格 #{quote_24h[-1]}#{tip}</p>" if tip.present?
    tip
  end

private
  def amplitude(old_price,new_price)
    return ((new_price - old_price) / old_price * 100).to_i
  end

end