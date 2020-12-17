-- With this script, you can have a dynamic temp channel for each user
-- I also don’t know how to adapt this for many servers ¯\_(ツ)_/¯

-- The principle of operation is similar to that of the DynChanZL bot

local discordia = require 'discordia'
local client = discordia.Client()

local _Channel = '' -- id of the channel, which will be create a dynamic temporary channel for certain user
local Guild = '' -- id of your guild
local DynamicChannelCategory = '' -- id of category wherein will be create dynamic temorary channel
local MoveDown = 0

local DynamicChannels = {}
local DynamicChannelsAlt = {}

client:on( 'voiceChannelJoin', function( member, channel )
    if channel.id == _Channel then
        local DynamicChannel = client:getGuild( Guild ):createVoiceChannel( '👉 ' .. member.username )
        DynamicChannel:setCategory( DynamicChannelCategory )
		DynamicChannel:moveDown( MoveDown + #DynamicChannels )

		local permissions = DynamicChannel:getPermissionOverwriteFor( member )
		permissions:allowAllPermissions()

		member:setVoiceChannel( DynamicChannel.id )

        DynamicChannelsAlt[ DynamicChannel.id ] = true
        DynamicChannels[ DynamicChannel.id ] = { members = 1 }
        
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
            local DynamicChannel = client:getGuild( Guild ):getChannel( channel.id )
            DynamicChannel:delete()
    
            DynamicChannelsAlt[ DynamicChannel.id ] = nil
            DynamicChannels[ DynamicChannel.id ] = nil
        end
    end
end )

client:on( 'channelDelete', function( channel )
    if DynamicChannelsAlt[ channel.id ] then
        DynamicChannelsAlt[ DynamicChannel.id ] = nil
        DynamicChannels[ DynamicChannel.id ] = nil
    end
end )

client:run 'Bot BOT_TOKEN'
