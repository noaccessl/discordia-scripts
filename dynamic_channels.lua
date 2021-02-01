-- With this script, you can have a dynamic temp channel for each user
-- The principle of operation is similar to that of the DynChanZL bot

local discordia = require 'discordia'
local client = discordia.Client()

local Channels = {
    [ 'ChannelID' ] = { -- id of the channel, which will be create a dynamic temporary channel for certain user
        GuildID = 'GuildID',
        CategoryID = 'CategoryID' -- id of category wherein will be create dynamic temporary channel
    }
}
local MoveDown = 0

local DynamicChannels = {}
local DynamicChannelsAlt = {}

client:on( 'voiceChannelJoin', function( member, channel )
    local ch = Channels[ channel.id ]
    if ch ~= nil then
        local DynamicChannel = client:getGuild( ch.GuildID ):createVoiceChannel( '👉 ' .. member.username )
        DynamicChannel:setCategory( ch.CategoryID )
	    DynamicChannel:moveDown( MoveDown + #DynamicChannels )

	    member:setVoiceChannel( DynamicChannel.id )

	    local permissions = DynamicChannel:getPermissionOverwriteFor( member )
	    permissions:allowAllPermissions()

        DynamicChannelsAlt[ DynamicChannel.id ] = true
        DynamicChannels[ DynamicChannel.id ] = { members = 1, guildid = ch.GuildID }
    
        return
    end

    if DynamicChannelsAlt[ channel.id ] then
        DynamicChannels[ channel.id ].members = DynamicChannels[ channel.id ].members + 1
    end
end )

client:on( 'voiceChannelLeave', function( member, channel )
    if DynamicChannelsAlt[ channel.id ] then
        DynamicChannels[ channel.id ].members = DynamicChannels[ channel.id ].members - 1

        if DynamicChannels[ channel.id ].members == 0 then
            local DynamicChannel = client:getGuild( DynamicChannels[ channel.id ].guildid ):getChannel( channel.id )
            DynamicChannel:delete()

            DynamicChannelsAlt[ channel.id ] = nil
            DynamicChannels[ channel.id ] = nil
        end
    end
end )

client:on( 'channelDelete', function( channel )
    if DynamicChannelsAlt[ channel.id ] then
        DynamicChannelsAlt[ channel.id ] = nil
        DynamicChannels[ channel.id ] = nil
    end
end )

client:run 'Bot BOT_TOKEN'
