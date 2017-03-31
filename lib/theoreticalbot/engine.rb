module TheoreticalBot
  class Engine < ::Rails::Engine
    isolate_namespace TheoreticalBot

    config.after_initialize do
  		Discourse::Application.routes.append do
  			mount ::TheoreticalBot::Engine, at: "/theoreticalbot"
  		end

      require_dependency "jobs/base"
      module ::Jobs

        class ReplyToTopic < Jobs::Base
          def execute(args)
            topic = Topic.find_by(id: args[:topic_id])
            bot_categories = SiteSetting.theoreticalbot_categories.split("|").map(&:to_i)
            if bot_categories.include? topic.category_id
              bot_user = User.find_by(username: SiteSetting.theoreticalbot_username)
              bot_responses = I18n.t('theoreticalbot_responses').split("|")
              bot_response = bot_responses.sample
              PostCreator.create(
                bot_user,
                topic_id: topic.id,
                raw: bot_response
              )
            end
          end
        end

      end

    end

  end
end

DiscourseEvent.on(:topic_created) do |topic, _, user|
  Jobs.enqueue(:reply_to_topic, {topic_id: topic.id, user_id: user.id})
end
