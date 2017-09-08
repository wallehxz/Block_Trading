class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    return true if self.role == 0
    return false
  end

  def roles
    {0=>'管理员',2=>'普通用户'}[self.role]
  end

  def self.sms_notice(content)
    yunpian = 'https://sms.yunpian.com/v2/sms/tpl_single_send.json'
    params = {}
    params[:apikey] = Settings.yunpian_key
    params[:tpl_id] = '1950240'
    params[:mobile] = '18211109527'
    params[:tpl_value] = URI::escape('#report#') + '='+ URI::escape(content)
    Faraday.send(:post,yunpian, params)
  end

  def self.sms(content)
    string = "【Block】代币价格通知：#{content}"
    sms_url = 'http://api.smsbao.com/sms'
    res = Faraday.get do |req|
      req.url sms_url
      req.params['u'] = Settings.sms_username
      req.params['p'] = Digest::MD5.hexdigest(Settings.sms_password)
      req.params['m'] = '18211109527'
      req.params['c'] = string
    end
  end

end
