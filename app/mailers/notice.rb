class Notice < ApplicationMailer

  def market_report(email,report)
    @msg = report
    mail to: email,subject: "#{Date.current.to_s}区块链趋势提醒"
  end

  def business_notice(email,order)
    @order = order
    mail to: email,subject: "#{order.block.upcase}挂单通知"
  end

  def info_notice(email,msg)
    @msg = msg
    mail to: email,subject: "#{Date.current.to_s} 系统通知"
  end

end
