# frozen_string_literal: true

# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'io/console'

require_relative 'text'

module Sus
	# Styled output output.
	module Output
		class XTerm < Text
			COLORS = {
				black: 0,
				red: 1,
				green: 2,
				yellow: 3,
				blue: 4,
				magenta: 5,
				cyan: 6,
				white: 7,
				default: 9,
			}
			
			ATTRIBUTES = {
				normal: 0,
				bold: 1,
				bright: 1,
				faint: 2,
				italic: 3,
				underline: 4,
				blink: 5,
				reverse: 7,
				hidden: 8,
			}
			
			def colors?
				true
			end
			
			def size
				@io.winsize
			end
			
			def style(foreground, background = nil, *attributes)
				tokens = []
				
				if foreground
					tokens << 30 + COLORS.fetch(foreground)
				end
				
				if background
					tokens << 40 + COLORS.fetch(background)
				end
				
				attributes.each do |attribute|
					tokens << ATTRIBUTES.fetch(attribute){attribute.to_i}
				end
				
				return "\e[#{tokens.join(';')}m"
			end
			
			def reset
				"\e[0m"
			end
		end
	end
end
