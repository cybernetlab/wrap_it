module WrapIt
  #
  # Provides functionality for text-contained components.
  #
  # Text can be captured from `:text` or `:body` option, or as first unparsed
  # String argument, or in block, provided to constructor.
  #
  # If block given, text will be captured from it in priority, so String
  # arguments and options will not parsed. You can cancel this manner by
  # calling {ClassMethods#text_in_block text_in_block(false)} method.
  #
  # This module adds `body` section before base `content` section.
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  module TextContainer
    #
    def self.included(base)
      base.class_eval do
        extend ClassMethods

        default_tag 'p', false

        option(:body, if: %i(body text)) { |_, v| body << v }
        argument(:body, first_only: true, after_options: true,
                 if: String,
                 and: ->{ !block_provided? || !text_in_block? }) do |_, v|
          self.class.html_safe? && v = html_safe(v)
          body << v
        end

        section :body
        place :body, :before, :content

        after_capture do
          self[:body] = html_safe(@body) unless @body.nil? || @body.empty?
        end
      end
    end

    #
    # Retrieves body text
    #
    # @return [String] text
    def body
      @body ||= empty_html
    end

    module ClassMethods
      #
      # Sets priotiy of text source
      #
      # @param  value [Boolean] `true` means if block present - text will
      #   be captured from there. `false` means first to inspect arguments and
      #   options and if it ommited retirieve text from block.
      #
      # @return [Boolean] current value
      def text_in_block(value = nil)
        if value.nil?
          @text_in_block.nil? && @text_in_block = true
          @text_in_block
        else
          @text_in_block = value == true
        end
      end

      #
      # Retrieves block priority
      #
      # @return [Boolean] current value
      def text_in_block?
        @text_in_block.nil? && @text_in_block = true
        @text_in_block
      end

      #
      # Sets whether text from arguments are html-safe
      # @param value [Boolean] `true` means that text from arguments have
      #   proper markup and component will mark it as save via html_safe
      #   method. `flase` means, that this values can contain unsafe content,
      #   so user should make html-safe string by itself.
      #
      # @return [Boolean] current value
      def html_safe(value = nil)
        if value.nil?
          @html_safe.nil? && @html_safe = true
          @html_safe
        else
          @html_safe = value == true
        end
      end

      #
      # Retrieves whether text from attributes are html-safe
      #
      # @return [Boolean] current value
      def html_safe?
        @html_safe.nil? && @html_safe = true
        @html_safe
      end
    end
  end
end
