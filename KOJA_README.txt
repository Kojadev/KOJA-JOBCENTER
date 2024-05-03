 							         

                            			THANK YOU FOR BUYING                                                                                                                   
 __  __   _____     _____   ______      ____     ____     ____     ______   ____     ______  ____       
/\ \/\ \ /\  __`\  /\___ \ /\  _  \    /\  _`\  /\  _`\  /\  _`\  /\__  _\ /\  _`\  /\__  _\/\  _`\     
\ \ \/'/'\ \ \/\ \ \/__/\ \\ \ \L\ \   \ \,\L\_\\ \ \/\_\\ \ \L\ \\/_/\ \/ \ \ \L\ \\/_/\ \/\ \,\L\_\   
 \ \ , <  \ \ \ \ \   _\ \ \\ \  __ \   \/_\__ \ \ \ \/_/_\ \ ,  /   \ \ \  \ \ ,__/   \ \ \ \/_\__ \   
  \ \ \\`\ \ \ \_\ \ /\ \_\ \\ \ \/\ \    /\ \L\ \\ \ \L\ \\ \ \\ \   \_\ \__\ \ \/     \ \ \  /\ \L\ \ 
   \ \_\ \_\\ \_____\\ \____/ \ \_\ \_\   \ `\____\\ \____/ \ \_\ \_\ /\_____\\ \_\      \ \_\ \ `\____\
    \/_/\/_/ \/_____/ \/___/   \/_/\/_/    \/_____/ \/___/   \/_/\/ / \/_____/ \/_/       \/_/  \/_____/
                                                                                                        
                                                                                                        		
Welcome to the KOJA Job Center Installation Guide!

Please read through this entire guide to ensure a smooth setup process.

Step-by-Step Installation:

1. Database Setup
> Import the koja_jobcenter.sql file into your SQL database.

2. Server Upload
> Upload the entire KOJA_jobcenter folder to your server.

3. Server Configuration
Add ensure KOJA_jobcenter to your server.cfg or resource.cfg, depending on your configuration file name.

4. Server Config Modifications
> Open server_config.lua and make the following changes:
Insert your Steam API key: SteamApiKey = "YOUR_STEAM_API_KEY"
Note: You can obtain a Steam API key here.
Set up a Discord webhook for logging job activities: webhook = "YOUR_DISCORD_WEBHOOK"

5. Configure Settings
> Edit Config.lua according to your preferences. Detailed explanations are provided within the file to guide you through the options.

6. Experience Point Integration
> Add the TriggerServerEvent call to each job function in the job center, so players can earn XP upon job completion.
Server Trigger Example: TriggerServerEvent('koja_jobcenter:addXP', AMOUNT)
Ensure this trigger is placed at the end of a successful job function.

7. Final Steps
> Once you have completed the above steps, your job center should be ready to go. Enjoy!

FAQ:

> Why do I need a Steam API Key?
Our script uses a profile system to fetch and display Steam profile avatars in the UI. Since Steam requires an API key to access profile information, it is necessary for full functionality.



