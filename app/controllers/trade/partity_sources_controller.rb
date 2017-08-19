class Trade::PartitySourcesController < Trade::BaseController
  before_action :set_block
  before_action :set_source, only: [:edit, :update, :destroy]

  def index
    @sources = PartitySource.where(block_parity_id:@block).paginate(page:params[:page])
  end

  def new
    @source = PartitySource.new
  end

  def create
    @source = PartitySource.new(partity_source_params)
    if @source.save
      redirect_to trade_block_parity_partity_sources_path(@block), notice: '价格来源添加成功'
    else
      flash[:warn] = "请完善表单信息"
      render :new
    end
  end

  def edit
    session[:return_to] = request.referrer
  end

  def update
    if @source.update(partity_source_params)
      redirect_to redirect_back_or_default, notice: '价格来源更新成功'
    else
      flash[:warn] = "请完善表单信息"
      render :edit
    end
  end

  def destroy
    @source.destroy
    flash[:notice] = "价格来源删除成功"
    redirect_to :back
  end

  private
    def redirect_back_or_default
      session[:return_to] || trade_block_parity_partity_sources_path(@block)
    end

    def set_block
      @block = BlockParity.find(params[:block_parity_id])
    end

    def set_source
      @source = PartitySource.find(params[:id])
    end

    def partity_source_params
      params.require(:partity_source).permit(:block_parity_id, :platform, :ticker_url, :css_anchor, :last_price)
    end
end
