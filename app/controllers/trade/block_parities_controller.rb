class Trade::BlockParitiesController < Trade::BaseController
  before_action :set_partity, only:[:edit, :update, :destroy, :change_state]

  def index
    @parities = BlockParity.all.paginate(page:params[:page])
  end

  def new
    @partity = BlockParity.new
  end

  def edit
  end

  def create
    @partity = BlockParity.new(block_parity_params)
    if @partity.save
      redirect_to trade_block_parities_path, notice: '区块差价添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end

  def update
    if @partity.update(block_parity_params)
      redirect_to trade_block_parities_path, notice: '区块差价更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @partity.destroy
    flash[:notice] = "区块差价删除成功"
    redirect_to :back
  end

  def change_state
    if @partity.state
      @partity.state = false
      @partity.save
    else
      @partity.state = true
      @partity.save
    end
    render json:{code:200}
  end

  private
    def set_partity
      @partity = BlockParity.find(params[:id])
    end

    def block_parity_params
      params.require(:block_parity).permit(:block,:agio_rate, :agio_price ,:state)
    end
end