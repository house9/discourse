module UseCases
  module Topics
    class Update

      def initialize(context)
        @context = context
        @guardian = context.guardian
        @topic_repository = context.topic_repository
      end

      attr_reader :context, :guardian, :topic_repository

      def run(params = {})
        topic = topic_repository.find_by_id(params[:topic_id])
        title, archetype = params[:title], params[:archetype]
        guardian.ensure_can_edit!(topic)

        topic.title = params[:title] if title.present?
        # TODO: we may need smarter rules about converting archetypes
        topic.archetype = "regular" if context.current_user.admin? && archetype == 'regular'

        success = topic_repository.save topic do
          topic.change_category(params[:category])
        end

        success ? context.update_succeeded(topic) : context.update_failed(topic)
      end

    end
  end
end