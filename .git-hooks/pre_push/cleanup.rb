# frozen_string_literal: true

module Overcommit::Hook::PrePush
  # Runs bin/cleanup before pushing (tests, brakeman, bundle-audit, rubocop)
  class Cleanup < Base
    def run
      result = execute(config[:command])
      return :fail, result.stdout + result.stderr unless result.success?

      :pass
    end
  end
end

