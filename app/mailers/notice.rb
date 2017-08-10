class Notice < ApplicationMailer

  def market_report(email,report)
    @msg = report
    mail to: email,subject: "区块链趋势报告"
  end

  def business_notice(email,block)
    @item = item
    mail to: email,subject: "[#{block}]挂单交易详情"
  end

end
