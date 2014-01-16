#
# Helpers for Rails-specific testing
#
# @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
#
module RailsExampleGroup
  def self.included(base)
    base.instance_eval do
      metadata[:type] = :rails

      before(:all) { RailsExampleGroup.init_rails }
      after(:all) do
        Object.send(:remove_const, :Rails) if Object.const_defined?(:Rails)
      end

      after :each do
        WrapIt.unregister :wrapper, :successor
        Object.send(:remove_const, :Wrapper) if Object.const_defined?(:Wrapper)
        if Object.const_defined?(:Successor)
          Object.send(:remove_const, :Successor)
        end
      end

      let(:template) do
        instance_eval(&RailsExampleGroup.register_helper)
        template_class.new.extend WrapIt.helpers
      end

      let(:template_class) { Class.new(ActionView::Base) }

      let(:rendered) { @rendered }
    end
  end

  def self.init_rails
    require 'rails'
    require 'active_support/dependencies'
    require 'action_controller/railtie'
    require 'action_view/railtie'
    I18n.enforce_available_locales = true
    path = File.expand_path(
      File.join('..', '..', '..', '..', 'lib', 'wrap_it'),
      __FILE__
    )
    WrapIt.send(:remove_const, :Renderer)
    load File.join(path, 'rails.rb')
    WrapIt::Base.send(:include, WrapIt::Renderer)
  end

  def self.register_helper
    proc do
      if described_class.is_a?(Class)
        if Object.const_defined?(:Successor)
          Object.send(:remove_const, :Successor)
        end
        Object.const_set(:Successor, successor_class)
        WrapIt.unregister :successor_helper
        WrapIt.register :successor_helper, 'Successor'
      else
        Object.sned(:remove_const, :Wrapper) if Object.const_defined?(:Wrapper)
        Object.const_set(:Wrapper, wrapper_class)
        WrapIt.unregister :wrapper_helper
        WrapIt.register :wrapper_helper, 'Wrapper'
      end
    end
  end

  def render(code)
    @rendered = template.render(inline: code)
  end

  RSpec.configure do |config|
    config.include(
      self,
      type: :rails,
      example_group: { file_path: /spec\/rails/ }
    )
  end
end
