require 'spec_helper'

describe WrapIt::Base do
  describe 'usage exmaples' do
    describe 'sections_explained' do
      it '#1' do
        successor_class.class_eval do
          section :append, :prepend
          place :prepend, before: :content
          place :append, after: :content
          after_initialize do
            @prepend = options.delete(:prepend)
            @append = options.delete(:append)
          end
          after_capture do
            unless @prepend.nil?
              self[:prepend] = content_tag('span', @prepend,
                                           class: 'input-group-addon')
            end
            unless @append.nil?
              self[:append] = content_tag('span', @append,
                                          class: 'input-group-addon')
            end
            if self[:content].empty?
              options[:type] = 'text'
              add_html_class 'form-control'
              self[:content] = content_tag('input', '', options)
              options.clear
              add_html_class 'input-group'
            end
          end
        end
        render <<-EOL
          <%= helper prepend: '@', placeholder: 'Username' %>
          <%= helper append: '.00' %>
          <%= helper append: '.00', prepend: '$' %>
        EOL
        expect(rendered).to have_tag(
          'div.input-group > span.input-group-addon[text()="@"]' \
          ' + input.form-control[@type="text"][@placeholder="Username"]'
        )
        expect(rendered).to have_tag(
          'div.input-group > input.form-control[@type="text"]' \
          ' + span.input-group-addon[text()=".00"]'
        )
        expect(rendered).to have_tag(
          'div.input-group > span.input-group-addon[text()="$"]' \
          ' + input.form-control[@type="text"]' \
          ' + span.input-group-addon[text()=".00"]'
        )
      end
    end
  end
end
