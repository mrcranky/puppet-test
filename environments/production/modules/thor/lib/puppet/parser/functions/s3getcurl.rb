require_relative 's3sign'

module Puppet::Parser::Functions
  newfunction(:s3getcurl, :type => :rvalue) do |args|
    domain   = args[0]
    bucket   = args[1]
    key      = args[2]
    filename = args[3]
    expires  = args[4] # in seconds from Time.now.to_i
    headers = { }
    #TODO: get these key values using Heira
    s3 = S3Sign.new('AKIAJQGZHGFW2O7XVM7A', 'j8GjAXlbzKn61Fp6017neoHvkQ9wFdFVW1UYt2fg' )
    url = s3.get(domain, bucket, key, expires, headers)
    heads = headers.map{|k,v| "-H '#{k}: #{v}'"}.join(' ')
    cmd = "'https://#{domain}.amazonaws.com#{url}' #{heads} -OutFile #{filename}"
    return cmd
  end
end
