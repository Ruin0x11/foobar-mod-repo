module Patterns
  def self.json_or_slug(pattern)
    /#{pattern}(?=\.json\z)|#{pattern}/
  end

  SPECIAL_CHARACTERS    = "_".freeze
  ALLOWED_CHARACTERS    = "[A-Za-z0-9#{Regexp.escape(SPECIAL_CHARACTERS)}]+".freeze
  ROUTE_PATTERN         = /#{ALLOWED_CHARACTERS}/.freeze
  RESERVED_MOD_IDS      = %w[
    core
    base
    script
    console
  ]
end
