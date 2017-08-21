class Trade::QuotesController < Trade::BaseController
  before_action :set_quote, only:[:edit, :update, :destroy]

  def index
    @quotes = Quote.paginate(page:params[:page])
  end

  def new
    @quote = Quote.new
  end

  def create
    @quote = Quote.new(quote_params)
    if @quote.save
      redirect_to trade_quotes_path, notice: '新区块链添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end


  def edit
  end

  def update
    if @quote.update(quote_params)
      redirect_to trade_quotes_path, notice: '区块链更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @quote.destroy
    flash[:notice] = "区块链删除成功"
    redirect_to :back
  end

  def change_state
    if @quote.state
      @quote.state = false
      @quote.save
    else
      @quote.state = true
      @quote.save
    end
    render json:{code:200}
  end

  private
    def set_quote
      @quote = Quote.find(params[:id])
    end

    def quote_params
      params.require(:quote).permit(:platform,:block,:source,:anchor,:increase,:decline,:state)
    end
end
