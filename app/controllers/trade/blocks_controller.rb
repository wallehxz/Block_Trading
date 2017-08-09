class Trade::BlocksController < Trade::BaseController
  before_action :set_block, only:[:edit, :update, :destroy]

  def index
    @blocks = Block.all.paginate(page:params[:page])
  end

  def new
    @block = Block.new
  end

  def edit
  end

  def create
    @block = Block.new(block_params)
    if @block.save
      redirect_to trade_blocks_path, notice: '新区块链添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end

  def update
    if @block.update(block_params)
      redirect_to trade_blocks_path, notice: '区块链更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @block.destroy
    flash[:notice] = "区块链删除成功"
    redirect_to :back
  end

  private
    def set_block
      @block = Block.find(params[:id])
    end

    def block_params
      params.require(:block).permit(:chinese,:english)
    end
end
