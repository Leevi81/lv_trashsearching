return {
    progressBar = {
        duration = 5000, -- Duration in milliseconds
        position = 'bottom', -- 'bottom' / 'middle'
        anim = {
            scenario = 'PROP_HUMAN_BUM_BIN'
        },
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        }
    },

    disableskillCheck = false,
    
    target = {
        icon = 'fas fa-trash',
        distance = 1.5
    },

    prick = {
        enable = true, -- Enable or disable prick chance when not using gloves
        enableSoundEffect = true,
        prickChance = 90, -- Percentage chance (0-100) of getting stung by something sharp if not wearing gloves
        waitTime = 7000, -- How long should the effect last
        healthLoss = 5, 
    },

    models = {
        'prop_dumpster_01a',
        'prop_dumpster_02a',
        'prop_dumpster_4a',
        'prop_dumpster_02b',
        'prop_dumpster_4b',
        'prop_bin_01a',
        'prop_bin_02a',
        'prop_bin_03a',
        'prop_bin_04a',
        'prop_bin_05a',
        'prop_bin_06a',
        'prop_bin_07c',
        'prop_bin_13a',
        'prop_bin_14a',
        'prop_bin_14b',
        'zprop_bin_01a_old',
        'prop_ld_case_01',
        'prop_cs_bin_03',
        'prop_cs_bin_02',
        'prop_gas_smallbin01',
        'prop_recyclebin_03_a',
        'prop_recyclebin_01a'
    },
}
