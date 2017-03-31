class TheoreticalBotConstraint
	def matches?(request)
		SiteSetting.theoreticalbot_enabled
	end
end