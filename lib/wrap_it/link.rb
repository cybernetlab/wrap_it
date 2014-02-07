module WrapIt
  #
  # HTML link element
  #
  # You can specify link by `link`, `href` or `url` option or by first String
  # argument. Also includes {TextContainer} module, so you can specify link
  # body with `text` or `body` option or by second String argument or inside
  # block.
  #
  # @example usage
  #   link = WrapIt::Link.new(template, 'http://some.url', 'text')
  #   link.render # => '<a href="http://some.url">test</a>'
  #   link = WrapIt::Link.new(template, link: 'http://some.url', text: 'text')
  #   link.render # => '<a href="http://some.url">test</a>'
  #   link = WrapIt::Link.new(template, 'text', link: http://some.url')
  #   link.render # => '<a href="http://some.url">test</a>'
  #
  # @example in template
  #   <%= link 'http://some.url' do %>text<% end %>
  #
  # @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
  #
  class Link < Base
    include TextContainer

    default_tag 'a'

    option :link, if: %i(link href url)

    # extract first string argument as link only if it not specified in options
    argument(:link, first_only: true, after_options: true,
             if: String, and: ->{ !option_provided?(:link, :href, :url) }
    ) do |_, v|
      self.href = v
    end

    #
    # Retrieves current link
    #
    # @return [String] link
    def href
      html_attr[:href]
    end

    #
    # Sets link
    # @param  value [String] link
    #
    # @return [String] setted link
    def href=(value)
      if value.is_a?(Hash)
        WrapIt.rails? || fail(
          ArgumentError,
          'Hash links supported only in Rails env'
        )
        value = @template.url_for(value)
      end
      value.is_a?(String) || fail(ArgumentError, 'Wrong link type')
      html_attr[:href] = value
    end
    alias_method :link=, :href=
    alias_method :url=, :href=
  end
end
