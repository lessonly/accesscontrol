require "accesscontrol/permitted_action_on_object_query"
require "accesscontrol/permitted_action_query"

module AccessControl
  # AccessControl::Query is the interface that hides the implementation
  # of the data layer. Tell AccessControl::Query when to grant and revoke
  # permissions, ask it whether an actor has permission on a
  # record, ask it for a list of permitted records for the record
  # type, and ask it whether an actor has a general permission not
  # related to any certain record or record type.
  class Query

    # Create an instance of AccessControl::Query.
    # Lookups are cached in the object to prevent redundant calls to the database.
    # Pass in an array or ActiveRecord::Relation for actor_groups if the actor
    # inherits some permissions from other actors in the system. This may happen
    # when you have a user in one or more groups or organizations with their own
    # access control permissions.
    #
    # @param actor [Hash, ActiveRecord::Base] The actor(s) we're checking for permission on
    def initialize(actors)
      @actors = case actors
      when Hash
        actors
      else
        { actors.class.name => actors.id }
      end
    end

    # Check whether an actor has a given permission.
    # @return [Boolean]
    # @overload can?(actor, action_id, namespace)
    #   Ask whether the actor has permission to perform action_id
    #   in the given namespace. Multiple actions can have the same id
    #   as long as their namespace is different. The namespace can be
    #   any String. We recommend using namespace to group a class of
    #   permissions, such as to group parts of a particular feature
    #   in your application.
    #
    #   @param action_id [Integer, Array<Integer>] The action or actions we're checking whether the actor has. If this is an array, then the check is ORed.
    #   @param namespace [String] The namespace of the given action_id.
    #   @return [Boolean] Returns true if actor has been granted the permission, false otherwise.
    #
    #   @example
    #     # Can the user perform the action with id 3 for posts?
    #     AccessControl.can?(user, 3, "posts")
    #
    # @overload can?(actor, action_id, object_type, object_id)
    #   Ask whether the actor has permission to perform action_id
    #   on a given record.
    #
    #   @param action_id [Integer, Array<Integer>] The action or actions we're checking whether the actor has. If this is an array, then the check is ORed.
    #   @param object_type [ActiveRecord::Base] The ActiveRecord model which we're checking for permission on.
    #   @param object_id [Integer] The id of the ActiveRecord object which we're checking for permission on.
    #   @return [Boolean] Returns true if actor has been granted the permission on the specified record, false otherwise.
    #
    #   @example
    #     # Can the user perform the action with id 5 for the Post with id 7?
    #     AccessControl.can?(user, 5, Post, 7)
    def can?(action_id, object_type, object_id = nil)
      if object_id.nil?
        permitted_action_query.can?(action_id, object_type)
      else
        permitted_action_on_object_query.can?(action_id, object_type, object_id)
      end
    end

    def list(action_id, object_type)
    end

    def grant(action_id, object_type, object_id = nil)
    end

    def revoke(action_id, object_type, object_id = nil)
    end

    private

    def permitted_action_query
      @_permitted_action_query ||= PermittedActionQuery.new(@actors)
    end

    def permitted_action_on_object_query
      @_permitted_action_on_object_query ||= PermittedActionOnObjectQuery.new(@actors)
    end

  end
end
