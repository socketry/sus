# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'covered/sus'
include Covered::Sus

if ENV['DD_API_KEY']
	require 'sus/integrations/datadog'
	include Sus::Integrations::Datadog
end
