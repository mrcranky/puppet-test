require_relative 's3sign'

module Puppet::Parser::Functions
  newfunction(:s3getcurl, :type => :rvalue) do |args|
    bucket   = args[0]
    key      = args[1]
    filename = args[2]
    expires  = args[3] # in seconds from Time.now.to_i
    headers = { }
    s3 = S3Sign.new('AKIAJQGZHGFW2O7XVM7A', 'j8GjAXlbzKn61Fp6017neoHvkQ9wFdFVW1UYt2fg' )
    url = s3.get(bucket, key, expires, headers)
    heads = headers.map{|k,v| "-H '#{k}: #{v}'"}.join(' ')
    cmd = "#{heads} --create-dirs -s -f -o #{filename} 'https://s3.amazonaws.com#{url}'"
    return cmd
  end
end
