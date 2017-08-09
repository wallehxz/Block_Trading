class Trade::PendingOrdersController < Trade::BaseController
  before_action :set_order, only:[:edit, :update, :destroy]

  def index
    @orders = PendingOrder.all.paginate(page:params[:page])
  end

  def new
    @order = PendingOrder.new
  end

  def edit
  end

  def create
    @order = PendingOrder.new(pending_order_params)
    if @order.save
      redirect_to trade_pending_orders_path, notice: '买卖挂单添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end

  def update
    if @order.update(pending_order_params)
      redirect_to trade_pending_orders_path, notice: '买卖挂单更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @order.destroy
    flash[:notice] = "买卖挂单删除成功"
    redirect_to :back
  end

  private
    def set_order
      @order = PendingOrder.find(params[:id])
    end

    def pending_order_params
      params.require(:pending_order).permit(:block,:business,:amount,:price,
        :consume,:state)
    end
end