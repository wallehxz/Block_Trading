class Trade::BalancesController < Trade::BaseController
  before_action :set_balance, only: [:edit, :update, :destroy]
  # skip_before_filter :verify_authenticity_token
  def index
    @balances = Balance.paginate(page:params[:page])
  end

  def edit
    session[:return_to] = request.referrer
  end

  def update
    if @balance.update(balance_params)
      redirect_to trade_balances_path, notice: '区块余额更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @balance.destroy
    flash[:notice] = "区块余额删除成功"
    redirect_to :back
  end

  private
    def redirect_back_or_default
      redirect_to(session[:return_to] || trade_balances_path)
    end

    def set_balance
       @balance = Balance.find(params[:id])
    end

    def balance_params
      params.require(:balance).permit(:block, :amount, :buy_price, :sell_price)
    end
end
