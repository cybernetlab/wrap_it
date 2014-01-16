module WrapIt
  #
  # TextContainer
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module TextContainer
    def self.included(base)
      base.class_eval do
        default_tag 'p'

        after_initialize do
          @body = @arguments.extract_first!(String) || empty_html
          @body += @options[:body] || @options[:text] || empty_html
          @options.delete(:body)
          @options.delete(:text)
        end

        after_capture do
          @content = html_safe(@body) + @content unless @body.nil?
        end
      end
    end
  end
end
