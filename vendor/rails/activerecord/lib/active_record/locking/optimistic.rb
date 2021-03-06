module ActiveRecord
  module Locking
    # Active Records support optimistic locking if the field <tt>lock_version</tt> is present.  Each update to the
    # record increments the lock_version column and the locking facilities ensure that records instantiated twice
    # will let the last one saved raise a StaleObjectError if the first was also updated. Example:
    #
    #   p1 = Person.find(1)
    #   p2 = Person.find(1)
    #   
    #   p1.first_name = "Michael"
    #   p1.save
    #   
    #   p2.first_name = "should fail"
    #   p2.save # Raises a ActiveRecord::StaleObjectError
    #
    # You're then responsible for dealing with the conflict by rescuing the exception and either rolling back, merging,
    # or otherwise apply the business logic needed to resolve the conflict.
    #
    # You must ensure that your database schema defaults the lock_version column to 0.
    #
    # This behavior can be turned off by setting <tt>ActiveRecord::Base.lock_optimistically = false</tt>.
    # To override the name of the lock_version column, invoke the <tt>set_locking_column</tt> method.
    # This method uses the same syntax as <tt>set_table_name</tt>
    module Optimistic
      def self.included(base) #:nodoc:
        super
        base.extend ClassMethods

        base.cattr_accessor :lock_optimistically
        base.lock_optimistically = true

        base.alias_method_chain :update, :lock
        base.alias_method_chain :attributes_from_column_definition, :lock
        
        class << base
          alias_method :locking_column=, :set_locking_column
        end
      end

      def locking_enabled? #:nodoc:
        lock_optimistically && respond_to?(self.class.locking_column)
      end

      def attributes_from_column_definition_with_lock
        result = attributes_from_column_definition_without_lock
        
        # If the locking column has no default value set,
        # start the lock version at zero.  Note we can't use
        # locking_enabled? at this point as @attributes may
        # not have been initialized yet
        
        if lock_optimistically && result.include?(self.class.locking_column)
          result[self.class.locking_column] ||= 0
        end
        
        return result
      end

      def update_with_lock #:nodoc:
        return update_without_lock unless locking_enabled?

        lock_col = self.class.locking_column
        previous_value = send(lock_col)
        send(lock_col + '=', previous_value + 1)

        affected_rows = connection.update(<<-end_sql, "#{self.class.name} Update with optimistic locking")
          UPDATE #{self.class.table_name}
          SET #{quoted_comma_pair_list(connection, attributes_with_quotes(false))}
          WHERE #{self.class.primary_key} = #{quote_value(id)}
          AND #{self.class.quoted_locking_column} = #{quote_value(previous_value)}
        end_sql

        unless affected_rows == 1
          raise ActiveRecord::StaleObjectError, "Attempted to update a stale object"
        end

        return true
      end

      module ClassMethods
        DEFAULT_LOCKING_COLUMN = 'lock_version'

        # Set the column to use for optimistic locking. Defaults to lock_version.
        def set_locking_column(value = nil, &block)
          define_attr_method :locking_column, value, &block
          value
        end

        # The version column used for optimistic locking. Defaults to lock_version.
        def locking_column
          reset_locking_column
        end

        # Quote the column name used for optimistic locking.
        def quoted_locking_column
          connection.quote_column_name(locking_column)
        end

        # Reset the column used for optimistic locking back to the lock_version default.
        def reset_locking_column
          set_locking_column DEFAULT_LOCKING_COLUMN
        end
      end
    end
  end
end
