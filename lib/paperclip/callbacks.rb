module Paperclip
  module Callbacks
    def self.included(base)
      base.extend(Defining)
      base.send(:include, Running)
    end

    module Defining
      def define_paperclip_callbacks(*callbacks)
        define_callbacks(*[callbacks, {:terminator => callback_terminator}].flatten)
        callbacks.each do |callback|
          eval <<-end_callbacks
            def before_#{callback}(*args, &blk)
              set_callback(:#{callback}, :before, *args, &blk)
            end
            def after_#{callback}(*args, &blk)
              set_callback(:#{callback}, :after, *args, &blk)
            end
          end_callbacks
        end
      end

      private

      def callback_terminator
        # if ::ActiveSupport::VERSION::STRING >= '4.1'
        #   lambda { |target, result| result == false }
        # else
        #   'result == false'
        # end
        lambda do |_, result|
          if result.respond_to?(:call)
            result.call == false
          else
            result == false
          end
        end
      end
    end

    module Running
      def run_paperclip_callbacks(callback, &block)
        run_callbacks(callback, &block)
      end
    end
  end
end
