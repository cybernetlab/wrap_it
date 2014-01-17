module WrapIt
  #
  # Provides methods related to HTML `data` attribute
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module HTMLData
    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
    end

    def set_html_data(name, value)
      @options[:data] ||= {}
      @options[:data][name.to_sym] = value
    end

    def remove_html_data(name)
      return unless @options[:data].is_a?(Hash)
      @options[:data].delete(name.to_sym)
    end
  end
end
