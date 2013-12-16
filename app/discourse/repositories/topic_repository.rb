module Repositories
  module TopicRepository

    def self.find_by_id(id)
      Topic.where(id: id).first
    end

    def self.save_topic(topic)
      topic.save
    end

  end
end