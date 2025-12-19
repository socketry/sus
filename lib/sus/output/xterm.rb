# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021-2024, by Samuel Williams.

require "io/console"

require_relative "text"

module Sus
	module Output
		# Represents an XTerm-compatible output handler with color and style support.
		class XTerm < Text
			# Color codes for ANSI terminal colors.
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
			
			# Style attribute codes for ANSI terminal attributes.
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
			
			# @returns [Boolean] Always returns true, as XTerm output supports colors.
			def colors?
				true
			end
			
			# @returns [Array(Integer)] The terminal size [height, width].
			def size
				@io.winsize
			end
			
			# Create an ANSI escape sequence for styling.
			# @parameter foreground [Symbol, nil] The foreground color name.
			# @parameter background [Symbol, nil] The background color name.
			# @parameter attributes [Array] Additional style attributes.
			# @returns [String] An ANSI escape sequence.
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
			
			# @returns [String] The ANSI reset sequence.
			def reset
				"\e[0m"
			end
		end
	end
end
