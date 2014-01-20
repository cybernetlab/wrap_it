#
# Helpers for integration testing
#
# @author Alexey Ovchinnikov <alexiss@cybernetlab.ru>
#
module IntegrationExampleGroup
  def self.included(base)
    base.instance_eval do
      metadata[:type] = :integration

      after do
        if Object.const_defined?(:Successor)
          Object.send(:remove_const, :Successor)
        end
        Object.send(:remove_const, :Wrapper) if Object.const_defined?(:Wrapper)
      end

      if WrapIt.rails?
        let(:template) do
          @context ||= ActionView::LookupContext.new(
            RailsApp::Application.root
          )
          template_class.new(ActionView::TemplateRenderer.new(@context))
        end

        let(:template_class) do
          mod = helpers_module
          Class.new(ActionView::Base) do
            include mod
          end
        end
      else
      end

      let(:rendered) { @rendered }

      let(:helpers_module) do
        Object.send(:remove_const, :Helpers) if Object.const_defined?(:Helpers)
        Object.send(:const_set, :Helpers, WrapIt.register_module)
        if described_class.is_a?(Class)
          if Object.const_defined?(:Successor)
            Object.send(:remove_const, :Successor)
          end
          Object.const_set(:Successor, successor_class)
          Helpers.register :helper, 'Successor'
        else
          if Object.const_defined?(:Wrapper)
            Object.send(:remove_const, :Wrapper)
          end
          Object.const_set(:Wrapper, wrapper_class)
          Helpers.register :helper, 'Wrapper'
        end
        Helpers
      end
    end
  end

  def render(code)
    if WrapIt.rails?
      @rendered = template.render(inline: code)
    else
    end
  end

  RSpec.configure do |config|
    config.include(
      self,
      type: :integration,
      example_group: { file_path: /spec\/integration/ }
    )
  end
end
