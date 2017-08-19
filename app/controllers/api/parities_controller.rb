class Api::ParitiesController < ApplicationController

  def last_parity
    BlockParity.where(state:true).each do |item|
      block_sources(item)
    end
  end

  def block_sources(block)
    block.sources.each do |source|
      price = Nokogiri::HTML(open(source.ticker_url)).at_css(source.css_anchor).children.text
      source.update_attributes(last_price:price) if price && price.to_f > 0
    end
    render json:{code:200}
  end

end