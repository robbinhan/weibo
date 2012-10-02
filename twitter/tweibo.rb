#done
#1.http访问twitter
#2.http需要代理
#3.代理需要通过ssh协议实现
#undo
#4.访问成功后需要OAuth授权
#5.授权后调用twitter接口取数据
#question
#1.是否需要authoritaction请求授权
#2.是否singnature生成错误

require 'net/https'
require 'socksify/http'
require "awesome_print"
require 'digest/hmac'
require 'base64'
require 'openssl'
require 'timezone'

def escape(value)
    URI::escape(value.to_s, RESERVED_CHARACTERS)
rescue ArgumentError
    URI::escape(value.to_s.force_encoding(Encoding::UTF_8), RESERVED_CHARACTERS)
end

HOST = 'localhost'
PORT = 7070
KEY = 'cW6YJ48wm3owinobuO4Mg';
SECRET = 'jtmBvZB7ZsrQuyalBlOLmk3PL2092CPaa7lODITY';
TOKEN = '134037251-7gYJkcgQAA24MWeWsSKm4xBMPJu8Yy3IibtS9DFJ';
TOKEN_SECRET = 'KffqwK6uwJNfPGUgPOuma64dMyNFiCizDTzvEUmQBM'
RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/
#nonce
oauth_nonce = Base64.encode64(OpenSSL::Random.random_bytes(32)).gsub(/\W/, '')
ap oauth_nonce

oauth_signature = '';
oauth_signature_method = 'HMAC-SHA1';

#twitter服务器时间同步
timezone = Timezone::Zone.new :zone => 'Etc/GMT'
datetime = timezone.time Time.now
datetime = datetime.to_s
ap datetime
oauth_timestamp = Time.parse(datetime).to_i.to_s
ap oauth_timestamp

oauth_version   = '1.0';
api_host = 'api.twitter.com';
http_protocol = 'https';
uri = URI.parse(http_protocol+'://'+api_host)

http = Net::HTTP.SOCKSProxy(HOST, PORT).new(uri.host, uri.port)
#ap http
http.use_ssl = true if uri.scheme == 'https'
#ap http

http.start do
    #puts http.get(http_protocol+'://'+api_host)
    #exit
    http_method = 'get'.upcase;
    #api_method = '/1/account/rate_limit_status.json';
    #api_method = '/1/statuses/home_timeline.json';
    #api_method = '/1/statuses/mentions.json';
    #api_method = '/1/account/totals.json';
    #api_method = '/1/help/test.json';
    api_method = '/1/account/verify_credentials.json';
    base_url = http_protocol+'://'+api_host+api_method;
    status = '';
    include_entities = '';
    params = {
        'oauth_consumer_key'=>KEY,
        'oauth_nonce'=>oauth_nonce,
        'oauth_signature_method'=>oauth_signature_method,
        'oauth_timestamp'=>oauth_timestamp,
        'oauth_token'=>TOKEN,
        'oauth_version'=>oauth_version
    }
    parameters = params.sort.map{|k,v| "#{escape(k)}=#{escape(v)}"}.join('&')
    ap parameters
    signature_base_string = escape(http_method)+"&"+escape(base_url)+"&"+escape(parameters)
    ap signature_base_string
    signing_key = escape(SECRET)+'&'+escape(TOKEN_SECRET)

    oauth_signature = escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1',signature_base_string, signing_key)}\n"));
    ap oauth_signature;

    herders = {
        'Authorization'=>'OAuth oauth_consumer_key="'+KEY+'", oauth_nonce="'+oauth_nonce+'",
                          oauth_signature="'+oauth_signature+'", oauth_signature_method="'+oauth_signature_method+'", 
                          oauth_timestamp="'+oauth_timestamp+'",oauth_token="'+TOKEN+'", oauth_version="'+oauth_version+'"',
        'Host'=> api_host
    }
    ap herders
    ap http.head(api_method, herders);
    ap http.get(api_method, herders).body;
end

