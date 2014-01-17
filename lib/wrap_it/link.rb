module WrapIt
  #
  # Link
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class Link < Base
    include TextContainer

    default_tag 'a'

    def href
      @options[:href]
    end

    def href=(value)
      if value.is_a?(Hash)
        defined?(Rails) || fail(
          ArgumentError,
          'Hash links supported only in Rails env'
        )
        value = @template.url_for(value)
      end
      value.is_a?(String) || fail(ArgumentError, 'Wrong link type')
      @options[:href] = value
    end

    before_initialize do
      link = @options[:link] || @options[:href] || @options[:url]
      @options.delete(:link)
      @options.delete(:href)
      @options.delete(:url)
      unless link.is_a?(String) || link.is_a?(Hash)
        @block.nil? && tmp = @arguments.extract_first!(String)
        link = @arguments.extract_first!(String)
        tmp.nil? || @arguments.unshift(tmp)
      end
      link.nil? || self.href = link
    end
  end
end
