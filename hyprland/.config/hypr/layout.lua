----------------
---- LAYOUT ----
----------------

-- Active layout: "dwindle", "master" or "scrolling"
hl.config({
    general = {
        layout = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        focus_fit_method = 0,
        -- column_width = 0.4,
        -- direction = "down"
    },
})
