require 'aws-sdk'

Aws.config[:ssl_verify_peer] = false

module Cenit
  module FileStore
    class AwsS3
      class << self
        def label
          'AWS-S3'
        end

        def client
          @client ||= Aws::S3::Client.new(
            region: 'us-west-2',
          # access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          # secret_access_key:  ENV['AWS_SECRET_ACCESS_KEY']
          )
        end

        def bucket
          @resource ||= Aws::S3::Resource.new(client: client)

          _bucket = @resource.bucket("cenit-io-tenant-#{Account.current.id.to_s}")
          _bucket.create unless _bucket.exists?
          _bucket
        end

        def object(file, &block)
          block.call(bucket.object(file.id.to_s))
        end

        def save(file, data, options)
          opts = {
            :content_type => file[:contentType],
            :metadata => {
              :filename => file[:filename],
            }
          }

          object(file) { |obj| data.is_a?(String) ? obj.put(opts.merge(body: data)) : obj.upload_file(data.path, opts) }
        end

        def read(file, *args)
          object(file) { |obj| obj.get.body.read if obj.exists? }
        end

        def destroy(file)
          object(file) { |obj| obj.delete if obj.exists? }
        end
      end
    end
  end
end