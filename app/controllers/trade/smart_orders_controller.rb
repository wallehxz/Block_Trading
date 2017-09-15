class Trade::SmartOrdersController < Trade::BaseController
  before_action :set_focus
  before_action :set_order, only: [:edit, :update, :destroy]

  def index
    @orders = SmartOrder.where(focus_id:@focus.id).stated.paginate(page:params[:page])
  end

  def new
    @order = SmartOrder.new
    @order.state = false
  end

  def create
    @order = SmartOrder.new(smart_order_params)
    if @order.save
      redirect_to trade_focus_block_smart_orders_path(@focus), notice: '智能空单添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end

  def edit
    session[:return_to] = request.referrer
  end

  def update
    if @order.update(smart_order_params)
      redirect_to trade_focus_block_smart_orders_path(@focus), notice: '智能空单更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @order.destroy
    flash[:notice] = "智能空单删除成功"
    redirect_to :back
  end

  private
    def redirect_back_or_default
      redirect_to(session[:return_to] || trade_block_block_tickers_path(@block))
    end

    def set_order
      @order = SmartOrder.find(params[:id])
    end

    def set_focus
       @focus = FocusBlock.find(params[:focus_block_id])
    end

    def smart_order_params
      params.require(:smart_order).permit(:focus_id, :business, :factor, :scale, :amount,
        :expect, :state)
    end
end
