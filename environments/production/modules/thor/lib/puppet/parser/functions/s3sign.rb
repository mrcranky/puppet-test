require 'digest/sha1'
require 'openssl'
require 'cgi'
require 'base64'

## The S3Sign class generates signed URLs for Amazon S3
class S3Sign

  def initialize(aws_access_key_id, aws_secret_access_key)
    @aws_access_key_id = aws_access_key_id
    @aws_secret_access_key = aws_secret_access_key
  end

  # builds the canonical string for signing.
  def canonical_string(method, path, headers={}, expires=nil)
    interesting_headers = {}
    headers.each do |key, value|
      lk = key.downcase
      if lk == 'content-md5' or lk == 'content-type' or lk == 'date' or lk =~ /^x-amz-/
        interesting_headers[lk] = value.to_s.strip
      end
    end

    # these fields get empty strings if they don't exist.
    interesting_headers['content-type'] ||= ''
    interesting_headers['content-md5'] ||= ''
    # just in case someone used this.  it's not necessary in this lib.
    interesting_headers['date'] = '' if interesting_headers.has_key? 'x-amz-date'
    # if you're using expires for query string auth, then it trumps date (and x-amz-date)
    interesting_headers['date'] = expires if not expires.nil?

    buf = "#{method}\n"
    interesting_headers.sort { |a, b| a[0] <=> b[0] }.each do |key, value|
      buf << ( key =~ /^x-amz-/ ? "#{key}:#{value}\n" : "#{value}\n" )
    end
    # ignore everything after the question mark...
    buf << path.gsub(/\?.*$/, '')
    # ...unless there is an acl or torrent parameter
    if    path =~ /[&?]acl($|&|=)/     then buf << '?acl'
    elsif path =~ /[&?]torrent($|&|=)/ then buf << '?torrent'
    end
    return buf
  end

  def hmac_sha1_digest(key, str)
    #STDERR.puts "SIGN: #{str}"
    OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, key, str)
  end

  # encodes the given string with the aws_secret_access_key, by taking the
  # hmac-sha1 sum, and then base64 encoding it. then url-encodes for query string use
  def encode(str)
    CGI::escape(Base64.encode64(hmac_sha1_digest(@aws_secret_access_key, str)).strip)
  end

  # generate a url to put a file onto S3
  def put(domain, bucket, key, expires_in=0, headers={})
    return generate_url('PUT', domain, bucket, key, expires_in, headers)
  end

  # generate a url to put a file onto S3
  def get(domain, bucket, key, expires_in=0, headers={})
    return generate_url('GET', domain, bucket, key, expires_in, headers)
  end

  # generate a url with the appropriate query string authentication parameters set.
  def generate_url(method, domain, bucket, key, expires_in, headers)
    path = "/#{bucket}/#{key}"
    expires = expires_in.nil? ? 0 : Time.now.to_i + expires_in.to_i
    canonical_string = canonical_string(method, path, headers, expires)
    encoded_canonical = encode(canonical_string)

    arg_sep = key.index('?') ? '&' : '?'
    return "/#{bucket}/#{key}" + arg_sep + "Signature=#{encoded_canonical}&" + 
           "Expires=#{expires}&AWSAccessKeyId=#{@aws_access_key_id}"
  end

end
