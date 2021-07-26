-- This script allows create a dynamic temporary voice channel for each user which can configure him as he wants
-- Works the same as the DynChanZL bot, but on Lua

local discordia = require( 'discordia' )
local client = discordia.Client()

--[[---------------------------------------------------------------------------
Dynamic Channels
---------------------------------------------------------------------------]]
dynchan = {
	channels = {
		[ 'ChannelID' ] = { -- After connecting to the channel, which id is written here, the bot will create its own dynamic channel for you
			GuildID = 'GuildID', -- Guild ID of this channel ( Required! )
			CategoryID = 'CategoryID', -- Category ID of this channel ( Required! )
			AllowedPermissions = { -- Allows the owner of a dynamic channel to:
				0x0000000010, -- Manage it
				0x0010000000, -- Manage its access for other members or roles
				0x0000400000, -- Mute members of his channel
				0x0000800000, -- Deafen members of his channel
				0x0001000000 -- Move or disconnect members of his channel
			} -- Read more about this here: https://discord.com/developers/docs/topics/permissions#permissions-bitwise-permission-flags
		}
	},
	slotpos = 0,
	stored = {},
	memberchannels = {}
}

function dynchan.GetStored( channelID )

	return dynchan.stored[ channelID ]

end

function dynchan.GetCount()

	local count = 0

	for k in pairs( dynchan.stored ) do

		count = count + 1

	end

	return count

end

function dynchan.IsStored( channelID )

	return dynchan.GetStored( channelID ) ~= nil

end

function dynchan.Store( channelID, guildID )

	dynchan.stored[ channelID ] = {
		memberCount = 1,
		guildID = guildID
	}

end

function dynchan.Remove( channelID )

	dynchan.stored[ channelID ] = nil

end

function dynchan.MemberJoin( channelID )

	local stored = dynchan.GetStored( channelID )
	if not stored then return end

	stored.memberCount = stored.memberCount + 1

end

function dynchan.MemberLeave( channelID )

	local stored = dynchan.GetStored( channelID )
	if not stored then return end

	stored.memberCount = stored.memberCount - 1

end

function dynchan.GetMemberChannel( member )

	return dynchan.memberchannels[ member.user.id ]

end

function dynchan.SetMemberChannel( member, channelID )

	dynchan.memberchannels[ member.user.id ] = channelID

end

local timer = require( 'timer' )

client:on( 'voiceChannelJoin', function( member, channel )

	local channelData = dynchan.channels[ channel.id ]

	if channelData then

		local co = coroutine.create( function()

			local memberchannel = dynchan.GetMemberChannel( member )

			if memberchannel then

				local stored = dynchan.GetStored( memberchannel )

				if stored then

					dynchan.SetMemberChannel( member, nil )

					local storedMemberChannel = client:getGuild( stored.guildID ):getChannel( memberchannel )

					if storedMemberChannel then

						storedMemberChannel:delete()

					end

				end

			end

			local category = client:getGuild( channelData.GuildID ):getChannel( channelData.CategoryID )

			local DynamicChannel = category:createVoiceChannel( '👉 ' .. member.username )
			DynamicChannel:moveDown( dynchan.slotpos + dynchan.GetCount() )

			local permissions = DynamicChannel:getPermissionOverwriteFor( member )
			permissions:allowPermissions( unpack( channelData.AllowedPermissions ) )

			if member.voiceChannel == nil then

				return DynamicChannel:delete()

			end

			member:setVoiceChannel( DynamicChannel.id )

			dynchan.Store( DynamicChannel.id, channelData.GuildID )
			dynchan.SetMemberChannel( member, DynamicChannel.id )

		end )
		timer.setTimeout( 150, coroutine.resume, co )

	elseif dynchan.IsStored( channel.id ) then

		dynchan.MemberJoin( channel.id )

	end

end )

client:on( 'voiceChannelLeave', function( member, channel )

	if dynchan.IsStored( channel.id ) then

		dynchan.MemberLeave( channel.id )

		local stored = dynchan.GetStored( channel.id )

		if stored.memberCount == 0 then

			dynchan.SetMemberChannel( member, nil )
			client:getGuild( stored.guildID ):getChannel( channel.id ):delete()

		end

	end

end )

client:on( 'channelDelete', function( channel )

	if dynchan.IsStored( channel.id ) then

		dynchan.Remove( channel.id )

	end

end )

--[[---------------------------------------------------------------------------
Run bot
---------------------------------------------------------------------------]]
client:run 'Bot BOT_TOKEN'
