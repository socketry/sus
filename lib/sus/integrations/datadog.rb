# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'ddtrace'

module Sus
	module Integrations
		module Datadog
			def before_tests(...)
				::Datadog.configure do |configuration|
					# Set the env to test:
					configuration.env = 'test'
					
					# Activate test tracing:
					configuration.tracing.enabled = true
					
					# Configures the tracer to ensure results delivery:
					configuration.ci.enabled = true
					
					# The name of the service or library under test:
					configuration.service = 'sus'
					
					# Disable noisy logging:
					configuration.diagnostics.startup_logs.enabled = false
				end
				
				super
			end
			
			def after_tests(...)
				super
				
				::Datadog.shutdown!
			end
			
			def make_registry
				super.tap do |registry|
					registry.base.include(Instrumentation)
				end
			end
			
			module Instrumentation
				def around
					options = {
						framework: "sus",
						framework_version: Sus::VERSION,
						test_name: self.class.to_s,
						test_suite: self.class.superclass.full_name,
						test_type: 'unit'
					}
					
					options[:span_options] = {
						resource: "#{options[:test_suite]} #{options[:test_name]}",
					}
					
					::Datadog::CI::Test.trace("sus.test", options) do |span|
						span['test.identity'] = self.class.identity.to_s
						
						status = nil
						
						begin
							result = super
							status = :passed
							
							if @__assertions__.passed?
								::Datadog::CI::Test.passed!(span)
							else
								message = @__assertions__.message
								::Datadog::CI::Test.failed!(span, message.text)
							end
							
							return result
						rescue => error
							status = :failed
							::Datadog::CI::Test.failed!(span, error)
							raise
						ensure
							::Datadog::CI::Test.skipped!(span) unless status
						end
					end
				end
			end
		end
	end
end
