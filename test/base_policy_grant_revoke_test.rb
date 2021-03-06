require "test_helper"
require "accessly/policy/base"

describe Accessly::Policy::Base do

  class GrantRevokePolicy < Accessly::Policy::Base

    actions(
      view: 1,
      edit_basic_info: 2,
      change_role: 3,
      destroy: 4
    )

    actions_on_objects(
      view: 1,
      edit_basic_info: 2,
      change_role: 3,
      email: 4
    )

    def self.namespace
      User.name
    end
  end

  it "grants the actor a general permission" do
    user = User.create!
    _(GrantRevokePolicy.new(user).view?).must_equal false

    GrantRevokePolicy.new(user).grant!(:view)
    _(GrantRevokePolicy.new(user).view?).must_equal true
  end

  it "grants the actor permission on an object" do
    user = User.create!
    other_user = User.create!
    _(GrantRevokePolicy.new(user).view?(other_user)).must_equal false

    GrantRevokePolicy.new(user).grant!(:view, other_user)
    _(GrantRevokePolicy.new(user).view?(other_user)).must_equal true
  end

  it "revokes a general permission from the actor" do
    user = User.create!
    GrantRevokePolicy.new(user).grant!(:view)
    _(GrantRevokePolicy.new(user).view?).must_equal true

    GrantRevokePolicy.new(user).revoke!(:view)
    _(GrantRevokePolicy.new(user).view?).must_equal false
  end

  it "revokes a permission on an object from the actor" do
    user = User.create!
    other_user = User.create!
    GrantRevokePolicy.new(user).grant!(:view, other_user)
    _(GrantRevokePolicy.new(user).view?(other_user)).must_equal true

    GrantRevokePolicy.new(user).revoke!(:view, other_user)
    _(GrantRevokePolicy.new(user).view?(other_user)).must_equal false
  end

  it "revokes a permission from all actors" do
    user = User.create!
    other_user = User.create!

    GrantRevokePolicy.new(user).grant!(:edit_basic_info)
    GrantRevokePolicy.new(other_user).grant!(:edit_basic_info)

    GrantRevokePolicy.revoke_all!(:edit_basic_info)
    _(GrantRevokePolicy.new(user).edit_basic_info?).must_equal false
    _(GrantRevokePolicy.new(other_user).edit_basic_info?).must_equal false
  end
end
