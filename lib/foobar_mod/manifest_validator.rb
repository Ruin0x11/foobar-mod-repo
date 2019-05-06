class FoobarMod::ManifestValidator

  REQUIRED_ATTRIBUTES = [:identifier,
                         :name,
                         :version,
                         :summary]

  def initialize(manifest)
    @manifest = manifest
  end

  def validate
    validate_required_attributes
  end

  private

  def validate_required_attributes
    REQUIRED_ATTRIBUTES.each do |symbol|
      unless @manifest.send symbol
        error "missing value for attribute #{symbol}"
      end
    end
  end

  def error(statement) # :nodoc:
    raise FoobarMod::InvalidManifestException, statement
  end
end
