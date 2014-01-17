
methods = Hash.public_instance_methods(true)
unless methods.include?(:extractable_options?)
  Hash.send(:define_method, :extractable_options?, proc do
    instance_of?(Hash)
  end)
end

unless methods.include?(:symbolize_keys!)
  Hash.send(:define_method, :symbolize_keys!, proc do
    keys.each do |key|
      next unless key.respond_to?(:to_sym)
      self[key.to_sym] = delete(key)
    end
    self
  end)
end

methods = Array.public_instance_methods(true)
unless methods.include?(:extract_options!)
  Array.send(:define_method, :extract_options!, proc do
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end)
end

module WrapIt
  #
  # Non rails render implementation
  #
  module Renderer
    protected

    def empty_html
      ''
    end

    def capture(text = nil)
      block_given? ? yield : text
    end

    def concat(text)
      @buffer ||= empty_html
      @buffer << text
    end

    def output_buffer
      @buffer
    end

    def content_tag(tag, body, options = {})
      arr = [tag]
      options.each { |o, v| arr << "#{o}=\"#{v.to_s}\"" }
      "<#{arr.join(' ')}>#{body}</#{tag}>"
    end

    def html_safe(text)
      text
    end

    def html_safe?(text)
      true
    end
  end
end
