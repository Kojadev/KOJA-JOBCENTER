let LevelLimit = 1000;
let requiredXP = 1000;
let userlevel = 1;
let userXP = 0;
let joby = [];
let translate = [];
let isFirstOpen = true;
let profilePhoto = "";

window.addEventListener("message", (event) => {
    if (event.data.type === "show") {
        if (isFirstOpen) {
            isFirstOpen = false;
            translate = event.data.translate;
            $(".profilePhoto").attr("src", event.data.avatar);
            $(".taskFirstName").html(event.data.firstname);
            $(".taskLastName").html(event.data.lastname);
            $(".cashMoneyValue").html("$" + event.data.moneyCash);
            $(".bankMoneyValue").html("$" + event.data.moneyBank);
            $(".cashMoneyText").html(translate.money);
            $(".bankMoneyText").html(translate.bank);
            $(".jobwindow_job_start").html(translate.start);
            $(".taskCharSex").html(event.data.gender);
            $("#notifytext").html(translate.notifysuccess);
            $(".succesfully").html(translate.succesfully);
            $(".loadedText").html(translate.loaded);
            $(".jobsection_text").html(translate.currentjob);
            $(".jobsection_job").html(event.data.job);
            $(".jobitem_access").html(translate.available);
            $(".jobitem_access_no").html(translate.unavailable);
            joby = event.data.jobs;
        }

        setXP(parseInt(event.data.xp));
        $(".generalSection").show();

    } else if (event.data.type === "addEXP") {
        giveXP(parseInt(event.data.xp));
    }
});

$(document).on("keydown", function() {
    switch (event.keyCode) {
        case 27: // ESC
            $.post(`https://${GetParentResourceName()}/closeMenu`, JSON.stringify());
            $(".generalSection").hide();
            $(".notifySection").hide();
            break;
    }
});

function refreshAll() {
    if (userXP >= requiredXP) {
        userlevel += Math.floor(userXP / requiredXP);
        userXP %= requiredXP;
    }

    userlevel = Math.min(userlevel, LevelLimit);
    userXP = (userlevel === LevelLimit) ? requiredXP : userXP;

    setTimeout(() => {
        document.getElementById("currentLVL").textContent = `${userlevel} LVL`;
        $(".currentXP").text(userXP + 'XP');
        populateJobList(joby);
    }, 100);
}

function setXP(number) {
    userlevel = 1;
    userXP = number;
    refreshAll();
}

function giveXP(number) {
    userXP += number;
    refreshAll();
}

$(document).on("click", ".jobitem", function() {
    if ($(this).hasClass("jobitem_NO")) return;

    $('.jobitem.active').removeClass('active');
    $(this).addClass('active');

    let jobData = $(this).attr("data-jobData");
    let jobDetails = JSON.parse(jobData);

    $(".jobwindow_image_main").css("background-image", `url(${jobDetails.jobinfoimage})`);
    $(".jobwindow_job_name, #jobidnotify, .jobwindow_job_name_start").text(jobDetails.jobname);
    $(".jobwindow_job_desc").text(jobDetails.jobdesc);
    $(".jobwindow_job_level").text(`${translate.level} ${jobDetails.level}`);
    $(".jobwindow_bg_img").attr("src", jobDetails.jobinfoimage);
    $(".jobwindow_job_start").data("startInfo", jobData);
    $(".jobwindow_job_mini_info").empty();

    if (jobDetails.miniinfo) {
        jobDetails.miniinfo.forEach(info => {
            $(".jobwindow_job_mini_info").append(`
                <div class="jobwindow_job_mini_item">
                    <i id="jobwindow_job_mini_icon" class="fa-solid fa-circle-dot"></i>
                    <div class="jobwindow_job_mini_text">${info}</div>
                </div>
            `);
        });
    }
});

$(document).on("click", ".jobwindow_job_start", function() {
    let jobStartData = $(this).data("startInfo");
    let jobInfo = JSON.parse(jobStartData);

    $.post(`https://${GetParentResourceName()}/selectJob`, JSON.stringify({
        jobInfo
    }));

    $(".notifySection").fadeIn(250);
    setTimeout(() => {
        refreshAll();
        $(".notifySection").fadeOut(250);
    }, 2500);

    $.post(`https://${GetParentResourceName()}/closeMenu`);
    $(".generalSection").hide();
});

function populateJobList(joby) {
    $(".joblist").empty();
    joby.forEach(job => {
        let accessLevelHtml = userlevel >= job.level ? `
            <div class="jobitem" data-jobData='${JSON.stringify(job)}'>
                <div class="jobitem_img"><img src="${job.image}" alt="" /></div>
                <div class="jobitem_name">${job.jobname}</div>
                <div class="jobitem_access">${translate.available}</div>
                <div class="jobitem_level"><div class="jobitem_level_inner">${job.level}</div>
                    <div class="jobitem_level_innertext">LEVEL</div>
                </div>
            </div>
        ` : `
            <div class="jobitem_NO" id="jobitem_NO" data-jobData='${JSON.stringify(job)}'>
                <div class="jobitem_img"><img src="${job.image}" alt="" /></div>
                <div class="jobitem_name">${job.jobname}</div>
                <div class="jobitem_access_no">${translate.unavailable}</div>
                <div class="jobitem_level_no"><div class="jobitem_level_inner">${job.level}</div>
                    <div class="jobitem_level_innertext">LEVEL</div>
                </div>
            </div>
        `;
        $(".joblist").append(accessLevelHtml);
    });

    setTimeout(() => {
        $(".jobItem:first-child").trigger('click');
    }, 15);
}


