class Trade::QuoteTickersController < Trade::BaseController
  before_action :set_quote
  before_action :set_ticker, only: [:edit, :update, :destroy]
  def index
    @tickers = QuoteTicker.where(quote_id:@quote).paginate(page:params[:page])
  end

  def edit
    session[:return_to] = request.referrer
  end

  def update
    if @ticker.update(quote_ticker_params)
      redirect_to redirect_back_or_default, notice: '历史价格更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @ticker.destroy
    flash[:notice] = "历史价格删除成功"
    redirect_to :back
  end

  private
    def redirect_back_or_default
      session[:return_to] || trade_block_block_tickers_path(@quote)
    end

    def set_quote
      @quote = Quote.find(params[:quote_id])
    end

    def set_ticker
       @ticker = QuoteTicker.find(params[:id])
    end

    def quote_ticker_params
      params.require(:quote_ticker).permit(:quote_id, :last_price, :ma5_price, :that_date)
    end
end
