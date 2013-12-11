module UseCases
  module Topics
    class Update

      def initialize(context)
        @context = context
        @guardian = context.guardian
        @topic_repository = context.topic_repository
      end

      attr_reader :context, :guardian, :topic_repository

      def run(topic_id, title, archetype, category)
        topic = topic_repository.find_by_id(topic_id)
        guardian.ensure_can_edit!(topic)

        set_topic_title(topic, title)
        set_topic_archetype(topic, archetype)

        success = topic_repository.save topic do
          topic.change_category(category)
        end

        success ? context.update_succeeded(topic) : context.update_failed(topic)
      end

      def set_topic_title(topic, title)
        if title.present?
          topic.title = title
        end
      end

      def set_topic_archetype(topic, archetype)
        # TODO: we may need smarter rules about converting archetypes
        if context.is_admin? && archetype == 'regular'
          topic.archetype = "regular"
        end
      end
    end
  end
end