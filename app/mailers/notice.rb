class Notice < ApplicationMailer

  def market_report(email,report)
    @msg = report
    mail to: email,subject: "区块链趋势报告"
  end

  def business_notice(email,order)
    @order = order
    mail to: email,subject: "#{order.block.upcase}挂单通知"
  end

  def info_notice(email,msg)
    @msg = msg
    mail to: email,subject: "系统通知"
  end

  def report_balance(email,msg)
    @msg = msg
    mail to: email,subject: "区块链余额报告"
  end

  def focus_report(email,report)
    @msg = report
    mail to: email,subject: "区块链极值通知"
  end

end
