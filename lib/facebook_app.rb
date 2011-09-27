class FacebookApp
  attr_accessor :id, :secret, :namespace

  def cookie_name
    @cookies_name ||= :"fbs_#{id}"
  end

  def valid_params? session
    signature = session.delete('sig') || session.delete(:sig)
    return false if signature.nil?

    arg_string = String.new
    session.sort.each { |k, v| arg_string << "#{k}=#{v}" }
    
    Digest::MD5.hexdigest(arg_string + secret) == signature
  end

  class << self
    attr_accessor :current

    def dev
      @dev ||= begin
        fba = new
        fba.id = 201879239874748
        fba.secret = 'ec027d8c174ee2c66e49678dbd6af2e9'
        fba.namespace = 'verdicdev'
        fba
      end
    end

    def prod
      @prod ||= begin
        fba = new
        fba.id = 190477397684803
        fba.secret = '89d4840ab8048f43c5cc2a9ac64632ce'
        fba.namespace = 'verdicapp'
        fba
      end
    end
  end
end
