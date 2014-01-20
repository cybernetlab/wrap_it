module WrapIt
  #
  # TextContainer
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module TextContainer
    def self.included(base)
      base.class_eval do
        default_tag 'p', false

        section :body
        place :body, :before, :content

        after_initialize do
          @body = @arguments.extract_first!(String) || empty_html
          @body += @options[:body] || @options[:text] || empty_html
          @options.delete(:body)
          @options.delete(:text)
        end

        after_capture do
          self[:body] = html_safe(@body) unless @body.nil?
        end
      end
    end

    attr_accessor :body
  end
end
