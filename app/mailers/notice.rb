class Notice < ApplicationMailer

  def market_report(email,report)
    @msg = report
    mail to: email,subject: "区块链行情"
  end

  def business_notice(email,order)
    @order = order
    mail to: email,subject: "#{order.block.upcase}挂单买卖"
  end

  def info_notice(email,msg)
    @msg = msg
    mail to: email,subject: "系统通知"
  end

  def report_balance(email,msg)
    @msg = msg
    mail to: email,subject: "区块链余额通知"
  end

  def focus_report(email,msg)
    @msg = msg
    mail to: email,subject: "区块链极值通知"
  end

  def quotes_report(email,msg)
    @msg = msg
    mail to: email,subject: "代币买卖通知"
  end
end
