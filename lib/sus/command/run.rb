require 'etc'
require 'samovar'

module Sus
	module Command
		class Run < Samovar::Command
			self.description = "Run one or more tests."
			
			options do
				option '-c/--count <n>', "The number of threads to use for running tests.", type: Integer, default: Etc.nprocessors
				option '-r/--require <path>', ""
			end
			
			many :paths
			
			def prepare(registry)
				if paths&.any?
					paths.each do |path|
						registry.load(path)
					end
				else
					Dir.glob("test/**/*.rb").each do |path|
						registry.load(path)
					end
				end
			end
			
			Result = Struct.new(:job, :assertions)
			
			def call
				registry = Sus::Registry.new
				jobs = Thread::Queue.new
				results = Thread::Queue.new

				output = Sus::Output.default
				guard = Thread::Mutex.new
				progress = Sus::Progress.new(output)
				count = @options[:count]

				loader = Thread.new do
					prepare(registry)
					
					registry.each do |child|
						guard.synchronize{progress.expand}
						jobs << child
					end
					
					jobs.close
				end

				aggregation = Thread.new do
					assertions = Sus::Assertions.new(output: output.buffered)
					first = true
					
					while result = results.pop
						guard.synchronize{progress.increment}
						
						if result.assertions.failed?
							if first
								first = false
							else
								assertions.output.print_line
							end
							
							result.assertions.output.append(assertions.output)
						end
						
						assertions.add(result.assertions)
						guard.synchronize{progress.report(count, assertions, :busy)}
					end
					
					guard.synchronize{progress.clear}
					
					assertions.output.print_line unless first
					assertions.output.append(output)
					
					assertions.print(output)
					output.print_line
				end

				workers = count.times.map do |index|
					Thread.new do
						while job = jobs.pop
							guard.synchronize{progress.report(index, job, :busy)}
							
							assertions = Sus::Assertions.new(output: output.buffered)
							job.call(assertions)
							results << Result.new(job, assertions)
							
							guard.synchronize{progress.report(index, "idle", :free)}
						end
					end
				end

				loader.join

				workers.each(&:join)
				results.close

				aggregation.join
			end
		end
	end
end
