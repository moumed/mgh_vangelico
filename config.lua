Config = {
	Locale = 'fr', -- The locale to use (fr or en)

	Skillcheck = true, -- If true, players must complete a skillcheck to break display cases

	EnableMarker = true, -- If true, markers will be shown when the player is near the store

	UseBlips = true, -- If true, blips will be shown on the map

	MaxWindows = 20, -- Maximum amount of windows that can be broken

	NotifType = "ox_lib", -- ox_lib / mgh
	
	-- Robbery timing settings
	CaseBreakingTime = 5000, -- Time in milliseconds to break each display case (5 seconds)
	AlarmDuration = 300000, -- Time in milliseconds for alarm to play (5 minutes)
	MaxRobberyTime = 600000, -- Maximum time for the entire robbery in milliseconds (10 minutes)

	-- Configurable loot items
	LootItems = {
		{
			item = 'diamond',
			min = 1,
			max = 3,
			chance = 20 -- 20% chance to get this item
		},
		{
			item = 'gold_watch',
			min = 1,
			max = 2,
			chance = 30 -- 30% chance to get this item
		},
		{
			item = 'ruby',
			min = 1,
			max = 2,
			chance = 25 -- 25% chance to get this item
		},
		{
			item = 'emerald',
			min = 1,
			max = 2,
			chance = 25 -- 25% chance to get this item
		},
		{
			item = 'sapphire',
			min = 1,
			max = 2,
			chance = 15 -- 15% chance to get this item
		},
		{
			item = 'pearl_necklace',
			min = 1,
			max = 1,
			chance = 10 -- 10% chance to get this item
		}
	},

	Police = {
		Jobs = { -- List of jobs that are considered as police
			'police',
			'sheriff',
			'state',
			'fbi'
		},
		RequiredCops = 1 -- How many cops are required to rob the store
	},

	Dispatch = 'qs-dispatch', -- Supported dispatches: qs-dispatch, cd_dispatch, core_dispatch

	SecBetwNextRob = 3600, -- How many seconds between each robbery (1 hour)
	
	-- Discord webhook configuration
	Discord = {
		Enable = true, -- Enable Discord webhook
		WebhookURL = "https://discord.com/api/webhooks/1392584956013711541/XOvbM7Bz9wSpmwc4W4WFL6jPsAkBK4e5vUyYD6EDgE25bnAi9vwhCKAdGsU4YLE7hMST", -- Your Discord webhook URL
		BotName = "Vangelico Bot", -- Bot name that will appear in Discord
		Color = 16711680, -- Color of the embed (red = 16711680)
		Title = "🔫 Braquage de Bijouterie", -- Title of the embed
		Footer = "MGH Vangelico System" -- Footer text
	}
}