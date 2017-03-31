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
                raw: bot_response,
                no_bump: true
              )
            end
          end
        end

        class ReplyToFirstPost < Jobs::Base
          def execute(args)
            post_count = Post.where(user_id: args[:user_id], hidden: false, post_type: Post.types[:regular]).count
            if post_count == 1
              bot_user = User.find_by(username: SiteSetting.theoreticalbot_username)
              bot_responses = I18n.t('theoreticalbot_first_post_responses', {username: args[:username]}).split("|")
              bot_response = bot_responses.sample
              PostCreator.create(
                  bot_user,
                  topic_id: args[:topic_id],
                  reply_to_post_number: args[:post_number],
                  raw: bot_response,
                  no_bump: true
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

DiscourseEvent.on(:post_created) do |post, opts, user|
  if SiteSetting.theoreticalbot_send_first_post_replies
    Jobs.enqueue(:reply_to_first_post, {topic_id: post.topic.id, post_number: post.post_number, username: user.username, user_id: user.id})
  end
end