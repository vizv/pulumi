# frozen_string_literal: true

if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7.0') && RUBY_ENGINE == 'ruby'
  desc = defined?(RUBY_DESCRIPTION) ? RUBY_DESCRIPTION : "ruby #{RUBY_VERSION} (#{RUBY_RELEASE_DATE})"
  abort <<-ABORT_MESSAGE

    Ruby 2.7.0 or newer is requied.

    You're running
      #{desc}

    Please upgrade to Ruby 2.7.0 or newer to continue.

  ABORT_MESSAGE
end
