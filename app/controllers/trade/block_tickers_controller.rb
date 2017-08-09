class Trade::BlockTickersController < Trade::BaseController
  before_action :set_block
  before_action :set_ticker, only: [:edit, :update, :destroy]
  def index
    @tickers = BlockTicker.where(block_id:@block).latest.paginate(page:params[:page])
  end

  def edit
    session[:return_to] = request.referrer
  end

  def update
    if @ticker.update(block_ticker_params)
      redirect_to redirect_back_or_default, notice: '价格行情更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @ticker.destroy
    flash[:notice] = "价格行情删除成功"
    redirect_to :back
  end

  private
    def redirect_back_or_default
      redirect_to(session[:return_to] || trade_block_block_tickers_path(@block))
    end

    def set_block
      @block = Block.find(params[:block_id])
    end

    def set_ticker
       @ticker = BlockTicker.find(params[:id])
    end

    def block_ticker_params
      params.require(:block_ticker).permit(:block_id, :last_price,:buy_price,:sell_price)
    end
end
