require "ostruct" # temporary
require "digest/sha3"

class Pusher
  attr_reader :user, :manifest, :message, :code, :mod, :body, :version, :version_id, :size

  def initialize(user, body)
    @user = user
    @body = StringIO.new(body.read)
    @size = @body.size
  end

  def process
    pull_manifest && find && authorize && validate && save
  end

  def authorize
    mod.new_record? ||
      mod.user == user ||
      notify("You do not have permission to push to this mod.", 403)
  end

  def validate
    (mod.valid? && version.valid?) || notify("There was a problem uploading your mod: #{mod.all_errors(version)}", 403)
  end

  def save
    write_mod body, manifest
  rescue ArgumentError => e
    @version.destroy
    notify("There was a problem uploading your mod. #{e}", 400)
  rescue StandardError => e
    @version.destroy
    notify("There was a problem uploading your mod. Please try again. #{e}", 500)
  else
    after_write
    notify("Successfully registered mod: #{version.full_name}", 200)
  end

  def pull_manifest
    @manifest = OpenStruct.new(identifier: "test", version: FoobarMod::Version.new("0.1.0"))
  rescue StandardError => error
    notify t("pusher.could_not_process", message: error.message), 422
  end

  def find
    identifier = manifest.identifier.to_s

    @mod = Mod.find_or_initialize_by(identifier: identifier) { |mod| mod.user = @user }

    unless @mod.new_record?
      if @mod.find_version_from_manifest(manifest)
        notify("Repushing of mod versions is not allowed.", 409)

        return false
      end
    end

    sha256 = Digest::SHA3.hexdigest(body.string, 256)

    @version = @mod.versions.new number: manifest.version.to_s,
                                 size: size,
                                 sha256: sha256

    true
  end

  private

  def after_write
    @version_id = version.id

    # TODO
    @version.download_count = 0
    @version.authors = ["test"]
    @version.licenses = ["MIT"]
    @version.summary = ""
  end

  def write_mod(body, manifest)
    ModFs.instance.store("mods/#{manifest.identifier}-#{manifest.version}.zip", body.string)
  end

  def notify(message, code)
    @message = message
    @code    = code
    false
  end
end
