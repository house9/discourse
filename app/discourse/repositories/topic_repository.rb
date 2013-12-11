module Repositories
  module TopicRepository

    def self.find_by_id(id)
      Topic.where(id: id).first
    end

    def self.save(topic, &block)
      # TODO: refactor transaction handling to common structure
      save_success = false
      block_success = false

      Topic.transaction do
        save_success = topic.save

        if block
          if save_success
            block_success = block.call(topic)
          end
        else
          block_success = true
        end

        raise ActiveRecord::Rollback unless save_success && block_success
      end

      save_success && block_success
    end

  end
end