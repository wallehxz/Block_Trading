class Api::QuotesController < ApplicationController

  def hit_tickers
    Quote.where(state:true).each do |item|
      sync_quote(item)
    end
    render json:{code:200}
  end

  def sync_quote(block)
    price = Nokogiri::HTML(open(block.source)).at_css(block.anchor).children.text
    local_ticker(block,price) if price && price.to_f > 0
  end

  def local_ticker(block,price)
    QuoteTicker.create(quote_id: block.id, last_price:price, that_date: Date.current.to_s)
  end

end