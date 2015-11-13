module Setup
  class CollectionData
    include CenitScoped

    BuildInDataType.regist(self).excluding(:data_type).and('properties' => {'name' => {'type' => 'string'},
                                                                            'library' => {'$ref' => Setup::Library.to_s,
                                                                                          'referenced' => true},
                                                                            'records' => {'type' => 'array'}})

    embedded_in :setup_collection, class_name: Setup::Collection.to_s, inverse_of: :data

    belongs_to :data_type, class_name: Setup::DataType.to_s, inverse_of: nil

    validates_presence_of :data_type

    def label
      data_type && data_type.custom_title
    end

    def name
      data_type && data_type.name
    end

    def library
      data_type && data_type.library
    end

    def records
      case data_type
      when Setup::SchemaDataType
        data_type.records_model.all.collect { |record| record.to_hash(ignore: :id) }
      when Setup::FileDataType
        data_type.records_model.all.collect do |record|
          record_hash = record.default_hash(only: [:filename, :contentType])
          record_hash['content'] = record.to_hash
          record_hash
        end
      else
        nil
      end
    end

    class << self
      def stored_properties_on(record)
        %w(name library records)
      end
    end
  end
end