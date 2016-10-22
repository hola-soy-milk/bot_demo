

class BotLogic < BaseBotLogic

	def self.setup
		set_welcome_message "Welcome!"
		set_get_started_button "bot_start_payload"
    set_bot_menu ['Reset', 'Main Menu']
	end

	def self.cron
		broadcast_all ":princess:"
	end

	def self.bot_logic
		ENV["DOMAIN_NAME"] = "https://82be97d0.ngrok.io"

    #binding.pry

		if @request_type == "CALLBACK" and @fb_params.payload == "RESET_BOT"
			@current_user.delete
			reply_message "Removed all your data from our servers."
			return
		elsif @request_type == "CALLBACK" and @fb_params.payload == "MAIN MENU_BOT"
      state_go 0
		end

		state_action 0, :greeting
		state_action 1, :menu_chosen
		state_action 2, :new_visa_question
    state_action 3, :when_where_renew_visa
    state_action 4, :renew_visa_district_chosen
	end

	def self.greeting
    response = HTTParty.get("https://graph.facebook.com/v2.6/#{@fb_params.messaging["sender"]["id"]}?fields=first_name,last_name,profile_pic,locale,timezone,gender&access_token=EAAJXg6vFWM4BAHGYaZCZC2IGzTqreHyRsaIhYw3Qt6RWBE5FsIjPy7uSMZATfTItjUW3qkqSMW5vtediwRri7y9NvFVQnmez6iZAeTUqZCuF5WpA9hJvyPkEJ6Orbg5dYu2eECuTJFdTW2xTdqS9RYvVhQe0WDDBaPYZCCHV3OYwZDZD")
    user_info = JSON.parse(response.body)
		reply_message "Hey #{user_info['first_name']}! How are you liking life in Vienna?"
    reply_quick_reply "What can I help you with?", ['🇦🇹 Visa', '🏡 Housing', '🎓 University', '🎒 Student life', '🏥 Counseling']
		state_go
	end

  def self.menu_chosen
    case get_message
    when '🇦🇹 Visa'
      reply_quick_reply "Is this your first time applying for a visa?", ['✅ Yes', '❌ No']
      state_go
    else
      reply_message "Yeah yeah working on it"
      state_go 0
    end
  end

  def self.new_visa_question
    case get_message
    when '❌ No'
      reply_quick_reply "Alright! What's on your mind?", ['🕐 When/where to go?', '❓ What do I need"', '⚠️ I was rejected!']
      state_go
    else
      reply_message "Yeah yeah working on it"
      state_go 0
    end
  end

  def self.when_where_renew_visa
    case get_message
    when '🕐 When/where to go?'
      reply_quick_reply "That depends. What district do you live in?", %W(1st 2nd 3rd 4th 5th 6th 7th 8th 9th 10th+)
      state_go
    else
      reply_message "Yeah yeah working on it"
      state_go 0
    end
  end

  def self.renew_visa_district_chosen
    case get_message
    when '8th'
      reply_message 'Alright, you need to go renew your visa at the "MA 35 Einwanderung und Staatsbürgerschaft für die Bezirke" near the city hall (Rathaus)'
      reply_message 'Below is a map of the area:'
      reply_image "http://i.imgur.com/OfAXVSP.png"
      reply_message 'Their opening times are as follows:'
      reply_message 'Monday: 8AM–12PM'
      reply_message 'Tuesday: 8AM–12PM'
      reply_message 'Wednesday: Closed'
      reply_message 'Thursday: 8AM–12PM, 3:30–5:30PM'
      reply_message 'Friday: 8AM–12PM'
      reply_message 'Saturday: Closed'
      reply_message 'Sunday: Closed'
      reply_quick_reply "Anything else I can do?", ['🕐 When/where to go?', '❓ What do I need"', '⚠️ I was rejected!', '🔙 Go back']
    else
      reply_message "Yeah yeah working on it"
      state_go 0
    end
  end

	def self.confirm
		if get_message == "Yes"
			subscribe_user("pregnant")
			state_go
			reply_message "Awwww sweet! You are all set now. I'll start to track your pregnancy for you. Can't wait :bride_with_veil::heart::baby_bottle:"
		else
			reply_message "Ohh Sorry, please use this format: DD/MM/YYYY"
			@current_user.profile = {}
			@current_user.save!
			state_reset
		end
	end

	def self.onboarded
		output_current_week
	end

	### helper functions

	def self.calculate_current_week
		user_date = Date.parse @current_user.profile[:due_date]
		server_date = Date.parse Time.now.to_s

		40 - ((user_date - server_date).to_i / 7)
	end

	def self.output_current_week
		current_week = calculate_current_week
		reply_message "you are in week number #{current_week}"
	end

end
