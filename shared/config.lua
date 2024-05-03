-- Configuration settings for the job center system.
Config = {

    Framework = "esx", -- Choose your framework: 'esx' or 'qb'
    Database = "oxmysql", -- Specify your database technology: 'ghmattimysql', 'oxmysql', or 'mysql-async' (check fxmanifest.lua when you change it!)

    -- Job settings: 'setjob' for primary jobs, 'setsecondjob' for secondary jobs.
    TypeJob = "setjob",

    -- Maximum XP that can be redeemed per successful job action.
    MaxExpAmount = 500,

    -- Cooldown in milliseconds for job-related triggers to prevent abuse.
    TriggerCooldown = 5000,

    -- Jobs that will be not available in the jobcenter to get
    BlackListedJobs = {
        'police',
        'mechanic',
        'ambulance',
        'unemployed',
    },

    -- Localization strings for UI elements and notifications.
    Language = {
        male = "MALE",
        female = "FEMALE",
        money = "Cash",
        bank = "Bank Account",
        available = "Available",
        unavailable = "Unavailable",
        level = "LEVEL",
        start = "START",
        notifysuccess = "Successfully selected job",
        currentjob = "Your current Job",
        succesfully = "succesfully",
        loaded = "loaded",
    },

    -- Configuration for NPC peds including appearance and location.
    Peds = {
        {
            pedName = "DUMMY", -- Display name for NPC.
            pedHash = 0x5D71A46F, -- Model hash (see: https://wiki.rage.mp/index.php?title=Peds).
            pedCoord = vector3(-23.4752, -366.3171, 39.8410-0.9), -- World coordinates for the NPC spawn.
            h = 0.9552, -- Orientation of NPC (heading).
            drawText = "DUMMY",  -- Text label displayed above NPC in the game.
        },
    },

    -- Configurations for jobs available through the job center.
    Jobs = {
        { 
            id = 1,
            jobname = "Fisherman",
            jobid = "fisherman",
            grade = 0,
            level = 1,
            image = "./images/fisherman.png",
            jobinfoimage = "./images/fishermanjobinfo.png",
            miniinfo = {
                "10-15 minutes of work",
                "$14,000-22,500 Earnings",
            },
            jobdesc = "Fishing can be a serene and rewarding experience, offering a connection with nature and a chance to reel in a prized catch.",
        },
        { 
            id = 2,
            jobname = "Garbage Collector",
            jobid = "garbage",
            grade = 0,
            level = 1,
            image = "./images/garbage.png",
            jobinfoimage = "./images/garbagejobinfo.png",
            miniinfo = {
                "5-15 minutes of work",
                "$5,000-22,500 Earnings",
            },
            jobdesc = "Garbage collection involves sorting and disposing of waste to maintain public health and environmental responsibility.",
        },
        { 
            id = 3,
            jobname = "TEST",
            jobid = "garbage2",
            grade = 0,
            level = 3,
            image = "./images/garbage.png",
            jobinfoimage = "./images/garbagejobinfo.png",
            miniinfo = {
                "5-15 minutes of work",
                "$5,000-22,500 Earnings",
            },
            jobdesc = "Garbage collection involves sorting and disposing of waste to maintain public health and environmental responsibility.",
        },
    }

}







