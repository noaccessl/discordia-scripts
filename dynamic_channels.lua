-- This script allows create a dynamic temporary voice channel for each user which can configure him as he wants
-- Works the same as the DynChanZL bot, but on Lua

local discordia = require 'discordia'
local client = discordia.Client()

local Channels = {
    [ 'ChannelID' ] = { -- Channel ID through which a dynamic temporary channel will be created for a specific user
        GuildID = 'GuildID',
        CategoryID = 'CategoryID' -- Category ID wherein will be create dynamic temporary channel
    }
}

local slotpos = 0
local DynamicChannels = {}

client:on( 'voiceChannelJoin', function( member, channel )
    local ChannelData = Channels[ channel.id ]
    if ChannelData ~= nil then
        local category = client:getGuild( ChannelData.GuildID ):getChannel( ChannelData.CategoryID )

        local DynamicChannel = category:createVoiceChannel( '👉 ' .. member.username )
	    DynamicChannel:moveDown( slotpos + #DynamicChannels )

	    member:setVoiceChannel( DynamicChannel.id )

	    local permissions = DynamicChannel:getPermissionOverwriteFor( member )
	    permissions:allowAllPermissions()

        local cachedData = { members = 1, guildid = ChannelData.GuildID }
        DynamicChannels[ DynamicChannel.id ] = cachedData
    
        return
    end

    if DynamicChannels[ channel.id ] ~= nil then
        DynamicChannels[ channel.id ].members = DynamicChannels[ channel.id ].members + 1
    end
end )

client:on( 'voiceChannelLeave', function( member, channel )
    if DynamicChannels[ channel.id ] ~= nil then
        DynamicChannels[ channel.id ].members = DynamicChannels[ channel.id ].members - 1

        if DynamicChannels[ channel.id ].members == 0 then
            local DynamicChannel = client:getGuild( DynamicChannels[ channel.id ].guildid ):getChannel( channel.id )
            DynamicChannel:delete()

            DynamicChannels[ channel.id ] = nil
        end
    end
end )

client:on( 'channelDelete', function( channel )
    if DynamicChannels[ channel.id ] ~= nil then
        DynamicChannels[ channel.id ] = nil
    end
end )

client:run 'Bot BOT_TOKEN'
