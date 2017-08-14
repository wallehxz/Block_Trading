class Trade::FocusBlocksController < Trade::BaseController
  before_action :set_focus, only: [:edit, :update, :destroy]
  def index
    @focus = FocusBlock.all.paginate(page:params[:page])
  end

  def new
    @focus = FocusBlock.new
  end

  def edit
    session[:return_to] = request.referrer
  end

  def create
    @focus = FocusBlock.new(focus_block_params)
    if @focus.save
      redirect_to trade_focus_blocks_path, notice: '关注区块添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end

  def update
    if @focus.update(focus_block_params)
      redirect_to trade_focus_blocks_path, notice: '关注区块更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @focus.destroy
    flash[:notice] = "关注区块删除成功"
    redirect_to :back
  end

  private
    def redirect_back_or_default
      redirect_to(session[:return_to] || trade_focus_blocks_path)
    end

    def set_focus
      @focus = FocusBlock.find(params[:id])
    end

    def focus_block_params
      params.require(:focus_block).permit(:block_id, :activation, :buy_amount,
        :total_price, :sell_weights, :sell_amplitude, :frequency)
    end
end
