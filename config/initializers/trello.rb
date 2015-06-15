require 'trello'

include Trello
include Trello::Authorization

Trello::Authorization.const_set :AuthPolicy, OAuthPolicy

# First arg is your public key, and second is secret.
# You can get this info by going to:
# https://trello.com/1/appKey/generate
OAuthPolicy.consumer_credential = OAuthCredential.new 'f5f6cc762e7588152763c899070ffb88', '86a8ee2a7015d3302d999041a58c7eeff393d08b94de8f26733bb22443849a4c'
# First arg is the access token key, second is presently not used -- trello bug?
# You can get the key by going to this url in your browser:
# https://trello.com/1/authorize?key=PUBLIC_KEY_FROM_ABOVE&name=MyApp&response_type=token&scope=read,write,account&expiration=never
# Only request the permissions you need; i.e., scope=read if you only need read, or scope=write if you only need write. Comma separate scopes you need.
# If you want your token to expire after 30 days, drop the &expiration=never.
OAuthPolicy.token = OAuthCredential.new '7a39cecdf6b9d08566db5e344e13c5807962e7dca2c592ca841653780d786cf3', nil
