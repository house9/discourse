module UseCases
  module Topics
    class Update

      def initialize(context, dependencies = {})
        @context = context
        @guardian = dependencies.fetch(:guardian) { context.guardian }
        @topic_repository = dependencies.fetch(:topic_repository) { context.topic_repository }
        @category_repository = dependencies.fetch(:category_repository) { context.category_repository }
      end

      attr_reader :context, :guardian, :topic_repository, :category_repository

      def run(topic_id, title, archetype, category_name)
        topic = topic_repository.find_by_id(topic_id)
        guardian.ensure_can_edit!(topic)

        set_topic_title(topic, title)
        set_topic_archetype(topic, archetype)

        success = Topic.transaction do
          if topic_repository.save_topic(topic)
            handle_category_changes(topic, category_name)
          end
        end

        success ? context.update_succeeded(topic) : context.update_failed(topic)
      end

      def handle_category_changes(topic, category_name)
        category = selected_category(category_name)

        if category == topic.category
          true
        elsif category.nil?
          false
        else
          # TODO: next refactoring Topic#changed_to_category method to UseCase
          topic.changed_to_category(category)
        end
      end

      private

      def selected_category(category_name)
        if category_name.blank?
          category_repository.default
        else
          category_repository.find_by_name(category_name)
        end
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