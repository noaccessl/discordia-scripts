-- With this script, you can have a dynamic temp channel for each user
-- And i don't know fucking how to make this for multiple servers

local discordia = require 'discordia'
local client = discordia.Client()

local channelID = '' -- id of the channel, which will be create a dynamic temporary channel for certain user
local guildID = '' -- id of your guild
local categoryID = '' -- id of category wherein will be create dynamic temorary channel
local moveDown = 0

local channel_count = 0
local channels = {}

client:on( 'voiceChannelJoin', function( member, channel )
	if channel.id == channelID then
        local createdChannel = client:getGuild( guildID ):createVoiceChannel( member.username )

        if categoryID ~= '' then
            createdChannel:setCategory( categoryID )
        end

		createdChannel:moveDown( moveDown + channel_count )

		local permissions = createdChannel:getPermissionOverwriteFor( member )
		permissions:allowAllPermissions()

		member:setVoiceChannel( createdChannel.id )

		channel_count = channel_count + 1
		channels[ createdChannel.id ] = { ownerID = member.id, voiceChannel = createdChannel }
	end 
end )

client:on( 'voiceChannelLeave', function( member, channel )
	if channels[ channel.id ] and channels[ channel.id ].ownerID == member.id then 
		local myChannel = client:getGuild( guildID ):getChannel( channel.id )

		channel_count = channel_count - 1
		channels[ myChannel.id ] = nil

		myChannel:delete()
	end 
end )

client:on( 'channelDelete', function( channel )
	if channels[ channel.id ] then 
		local ThisChannel = client:getGuild( guildID ):getChannel( channel.id )

		channel_count = channel_count - 1
		channels[ ThisChannel.id ] = nil

		ThisChannel:delete()
	end 
end )

client:run 'Bot BOT_TOKEN'
