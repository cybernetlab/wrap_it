require 'spec_helper'

describe WrapIt::Base do
  describe 'usage exmaples' do
    describe 'sections_explained' do
      it '#1' do
        successor_class.class_eval do
          section :append, :prepend
          place :prepend, before: :content
          place :append, after: :content

          option :prepend do |_, value|
            self[:prepend] = content_tag('span', value,
                                         class: 'input-group-addon')
          end

          option :append do |_, value|
            self[:append] = content_tag('span', value,
                                        class: 'input-group-addon')
          end

          after_capture do
            if self[:content].empty?
              html_attr[:type] = 'text'
              html_class << 'form-control'
              options = html_attr
                .merge(class: html_class.to_html)
                .merge(html_data)
              self[:content] = content_tag('input', '', options)
              self.html_class = 'input-group'
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
