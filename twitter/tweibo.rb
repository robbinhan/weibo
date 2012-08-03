#1.http访问twitter
#2.http需要代理
#3.代理需要通过ssh协议实现
#4.访问成功后需要OAuth授权
#5.授权后调用twitter接口取数据

require 'socksify/http'
require "awesome_print"
require 'digest/hmac'
HOST = 'localhost'
PORT = 7070
KEY = 'cW6YJ48wm3owinobuO4Mg';
SECRET = 'jtmBvZB7ZsrQuyalBlOLmk3PL2092CPaa7lODITY';
TOKEN = '134037251-UOhccCHaJP2QZyOy36GziBWssJIIaVcaOA2AkBbA'
TOKEN_SECRET = 'MvAQyp08LjIXZYWaGJZRMy6pQyvLOztvA7kC151XNSQ'
oauth_nonce = '';
oauth_signature = '';
oauth_signature_method = 'HMAC-SHA1';
oauth_timestamp = Time.now.to_i.to_s
oauth_version   = '1.0';
api_host = 'api.twitter.com';
http_protocol = 'http';
uri = URI.parse(api_host)
Net::HTTP.SOCKSProxy(HOST, PORT).start(uri.host, uri.port) do |http|
    http_method = 'get'.upcase;
    api_method = '/1/account/rate_limit_status.json';
    base_url = http_protocol+'://'+api_host+api_method;
    status = '';
    include_entities = '';
    herders = {
        'Authorization'=>'OAuth oauth_consumer_key="#{KEY}", oauth_nonce="#{oauth_nonce}", 
                          oauth_signature="#{oauth_signature}", oauth_signature_method="#{oauth_signature_method}", 
                          oauth_timestamp="#{oauth_timestamp}",oauth_token="#{TOKEN}", oauth_version="#{oauth_version}"',
        'Host'=> api_host
    }
    params = {
        'oauth_consumer_key'=>KEY,
        'oauth_nonce'=>oauth_nonce,
        'oauth_signature_method'=>oauth_signature_method,
        'oauth_timestamp'=>oauth_timestamp,
        'oauth_token'=>TOKEN,
        'oauth_version'=>oauth_version
    }
    parameters = params.sort.map{|k,v| "#{CGI::escape(k)}=#{CGI::escape(v)}"}.join('&')
    signature_base_string = http_method+"&"+base_url+"&"+parameters
    signing_key = SECRET+TOKEN_SECRET

    oauth_signature = Digest::HMAC.hexdigest(signature_base_string, signing_key, Digest::SHA1)
    ap oauth_signature;
    #puts http.get(api_method, herders).body;
end
