# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

describe Sus::Clock do
	let(:clock) {subject.new}
	
	it "should measure the time between start and stop" do
		clock.start!
		sleep 0.001
		clock.stop!
		
		expect(clock.duration).to be > 0.001
	end
	
	it "can format the duration using seconds" do
		expect(Sus::Clock.new(1.123).to_s).to be == "1.1s"
	end
	
	it "can format the duration using milli-seconds" do
		expect(Sus::Clock.new(0.123).to_s).to be == "123.0ms"
	end
	
	it "can format the duration using micro-seconds" do
		expect(Sus::Clock.new(0.000123).to_s).to be == "123.0µs"
	end
	
	it "can convert to a float" do
		expect(Sus::Clock.new(1.123).to_f).to be == 1.123
	end
	
	it "can be compared" do
		expect(Sus::Clock.new(1.123) <=> Sus::Clock.new(1.123)).to be == 0
		expect(Sus::Clock.new(1.123) <=> Sus::Clock.new(1.124)).to be == -1
		expect(Sus::Clock.new(1.123) <=> Sus::Clock.new(1.122)).to be == 1
	end
	
	with '.start!' do
		let(:clock) {Sus::Clock.start!}
		it 'can start instance of clock' do
			sleep(0.005)
			expect(clock.stop!).to be > 0.0
		end
		
		it 'can accumulate duration' do
			sleep(0.005)
			expect(clock.duration).to be > 0.0
		end
	end
end
