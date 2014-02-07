require 'delegate'

module WrapIt
  #
  # Provides hash-like access to HTML data.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class HTMLData < DelegateClass(Hash)
    #
    # Sanitizes html data
    #
    # @overload sanitize(values = {})
    #   @param  values [Hash] hash to sanitize
    #
    # @return [Hash] sanitized hash
    def self.sanitize(**values)
      Hash[values
        .map do |k, v|
          k = k.to_s
          if k.include?('-')
            k, n = k.split(/-/, 2)
            v = sanitize(n.to_sym => v)
          else
            k = k.downcase.gsub(/[^a-z0-9_]+/, '').gsub(/\A\d+/, '')
            v = v.is_a?(Hash) ? sanitize(v) : v.to_s
          end
          k.empty? ? nil : [k.to_sym, v]
        end
        .compact
      ]
    end

    def initialize(**value)
      super(HTMLData.sanitize(**value))
    end
  end
end
