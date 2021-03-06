module WrapIt
  #
  # Provides render function for Rails
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module Renderer
    def self.included(base)
      base == Base || fail(
        TypeError,
        "#{self.class.name} can be included only into WrapIt::Base"
      )
    end

    protected

    def empty_html
      ''.html_safe
    end

    def html_safe(text)
      text.html_safe
    end

    def html_safe?(text)
      text.html_safe?
    end

    def superhtml(text)
      text.to_s
    end

    def capture(*args, &block)
      @template.capture(*args, &block)
    end

    def concat(*args, &block)
      @template.concat(*args, &block)
    end

    def content_tag(*args, &block)
      @template.content_tag(*args, &block)
    end

    def output_buffer(*args, &block)
      @template.output_buffer(*args, &block)
    end


#    def self.included(base)
#      puts "LOADED"
#      base.class_eval do
#        delegate :capture, :concat, :content_tag,
#                 :output_buffer, to: :@template
#        protected :capture, :concat, :content_tag,
#                  :output_buffer
#      end
#    end
  end
end
