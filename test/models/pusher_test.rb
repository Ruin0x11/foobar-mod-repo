require "test_helper"

class PusherTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, email: "user@example.com")
    @mod_file = mod_file
    @pusher = Pusher.new(@user, @mod_file)
  end

  context "creating a new pusher" do
    should "have some state" do
      assert @pusher.respond_to?(:user)
      assert @pusher.respond_to?(:version)
      assert @pusher.respond_to?(:version_id)
      assert @pusher.respond_to?(:manifest)
      assert @pusher.respond_to?(:message)
      assert @pusher.respond_to?(:code)
      assert @pusher.respond_to?(:mod)
      assert @pusher.respond_to?(:body)

      assert_equal @user, @pusher.user
    end

    should "initialize size from the mod" do
      assert_equal @mod_file.size, @pusher.size
    end

    context "processing incoming mods" do
      should "work normally when things go well" do
        @pusher.stubs(:pull_manifest).returns true
        @pusher.stubs(:find).returns true
        @pusher.stubs(:authorize).returns true
        @pusher.stubs(:validate).returns true
        @pusher.stubs(:save)

        @pusher.process
      end

      should "not attempt to find mod if manifest can't be pulled" do
        @pusher.stubs(:pull_manifest).returns false
        @pusher.stubs(:find).never
        @pusher.stubs(:authorize).never
        @pusher.stubs(:save).never
        @pusher.process
      end

      should "not attempt to authorize if not found" do
        @pusher.stubs(:pull_manifest).returns true
        @pusher.stubs(:find)
        @pusher.stubs(:authorize).never
        @pusher.stubs(:save).never

        @pusher.process
      end

      should "not attempt to validate if not authorized" do
        @pusher.stubs(:pull_manifest).returns true
        @pusher.stubs(:find).returns true
        @pusher.stubs(:authorize).returns false
        @pusher.stubs(:validate).never
        @pusher.stubs(:save).never

        @pusher.process
      end

      should "not attempt to save if not validated" do
        @pusher.stubs(:pull_manifest).returns true
        @pusher.stubs(:find).returns true
        @pusher.stubs(:authorize).returns true
        @pusher.stubs(:validate).returns false
        @pusher.stubs(:save).never

        @pusher.process
      end
    end
  end

  context "initialize new mod with find if one does not exist" do
    setup do
      manifest = mock
      manifest.expects(:identifier).returns "test"
      manifest.expects(:version).returns "0.1.0"
      @pusher.stubs(:manifest).returns manifest
      @pusher.stubs(:size).returns 5
      @pusher.stubs(:body).returns StringIO.new("dummy body")

      assert @pusher.find
    end

    should "set mod" do
      assert_equal "test", @pusher.mod.identifier
    end

    should "set version" do
      assert_equal "0.1.0", @pusher.version.number
    end

    should "set mod version size" do
      assert_equal 5, @pusher.version.size
    end

    should "set sha256" do
      expected_sha = Digest::SHA3.hexdigest(@pusher.body.string, 256)
      assert_equal expected_sha, @pusher.version.sha256
    end
  end

  context "finding an existing mod" do
    should "bring up existing mod with matching manifest" do
      @mod = create(:mod)
      manifest = mock
      manifest.stubs(:identifier).returns @mod.identifier
      manifest.stubs(:version).returns "0.1.0"
      @pusher.stubs(:manifest).returns manifest
      @pusher.find

      assert_equal @mod, @pusher.mod
      assert_not_nil @pusher.version
    end

    should "refuse upload if the same version exists" do
      @mod = create(:mod)
      create(:version, mod: @mod, number: "0.1.0")
      manifest = mock
      manifest.stubs(:identifier).returns @mod.identifier
      manifest.stubs(:version).returns "0.1.0"
      @pusher.stubs(:manifest).returns manifest
      refute @pusher.find
      assert_equal "Repushing of mod versions is not allowed.", @pusher.message
      assert_equal 409, @pusher.code
    end
  end

  context "checking if the mod can be pushed to" do
    should "be true if mod is new" do
      @pusher.stubs(:mod).returns Mod.new
      assert @pusher.authorize
    end

    context "with a existing mod" do
      setup do
        @mod = create(:mod, identifier: "the_mod")
        @pusher.stubs(:mod).returns @mod
      end

      should "be true if owned by the user" do
        @mod.user = @user
        assert @pusher.authorize
      end

      should "be false if no versions exist" do
        refute @pusher.authorize
      end

      should "be false if not owned by user and a version exists" do
        create(:version, mod: @mod, number: '0.1.1')
        refute @pusher.authorize
        assert_equal "You do not have permission to push to this mod.", @pusher.message
        assert_equal 403, @pusher.code
      end
    end
  end
end

