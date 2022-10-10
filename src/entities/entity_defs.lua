ENTITY_DEFS = {
    ['player'] = {
        width = 24,
        height = 24,
        ox = 0,
        oy = 0,
        health = 5,
        speed = 20,
        attack = 1,
        animations = {
            ['idle-up'] = {
                frames = { 1, 2, 3, 4 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['idle-down'] = {
                frames = { 9, 10, 11, 12 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['idle-left'] = {
                frames = { 17, 18, 19, 20 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['idle-right'] = {
                frames = { 25, 26, 27, 28 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['walk-up'] = {
                frames = { 5, 6, 7, 8 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['walk-down'] = {
                frames = { 13, 14, 15, 16 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['walk-left'] = {
                frames = { 21, 22, 23, 24 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['walk-right'] = {
                frames = { 29, 30, 31, 32 },
                interval = 0.15,
                looping = true,
                texture = 'player'
            },
            ['roll-up'] = {
                frames = { 32, 33, 34, 35, 36, 37, 38, 39, 40 },
                interval = 0.05,
                looping = false,
                texture = 'player'
            },
            ['roll-down'] = {
                frames = { 41, 42, 43, 44, 45, 46, 47, 48 },
                interval = 0.05,
                looping = false,
                texture = 'player'
            },
            ['roll-left'] = {
                frames = { 32, 33, 34, 35, 36, 37, 38, 39, 40 },
                interval = 0.05,
                looping = false,
                texture = 'player'
            },
            ['roll-right'] = {
                frames = { 41, 42, 43, 44, 45, 46, 47, 48 },
                interval = 0.05,
                looping = false,
                texture = 'player'
            },
            ['attack-up'] = {
                frames = { 1, 2, 3, 4 },
                interval = 0.1,
                looping = true,
                texture = 'player-attack'
            },
            ['attack-down'] = {
                frames = { 5, 6, 7, 8 },
                interval = 0.1,
                looping = true,
                texture = 'player-attack'
            },
            ['attack-left'] = {
                frames = { 9, 10, 11, 12 },
                interval = 0.1,
                looping = true,
                texture = 'player-attack'
            },
            ['attack-right'] = {
                frames = { 13, 14, 15, 16 },
                interval = 0.1,
                looping = true,
                texture = 'player-attack'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8, 25, 25 },
                interval = 0.2,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['box-single'] = {
        width = 16,
        height = 20,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 17 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['box-with-shovel'] = {
        width = 16,
        height = 20,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 18 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['box-stack'] = {
        width = 32,
        height = 24,
        ox = 0,
        oy = 8,
        animations = {
            ['idle-down'] = {
                frames = { 19 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['pot-1'] = {
        width = 18,
        height = 22,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 20 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['pot-2'] = {
        width = 20,
        height = 22,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 21 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['pot-3'] = {
        width = 20,
        height = 22,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 22 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['dead-bush'] = {
        width = 16,
        height = 16,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 29 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['dead-tree'] = {
        width = 22,
        height = 26,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 30 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['cactus-1'] = {
        width = 18,
        height = 24,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 31 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['cactus-2'] = {
        width = 18,
        height = 24,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 32 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['chest'] = {
        width = 32,
        height = 24,
        ox = 0,
        oy = 8,
        animations = {
            ['idle-down'] = {
                frames = { 1 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['open'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.05,
                looping = false,
                texture = 'objects'
            }
        }
    },
    ['gold-chest'] = {
        width = 32,
        height = 24,
        ox = 0,
        oy = 8,
        animations = {
            ['idle-down'] = {
                frames = { 9 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['open'] = {
                frames = { 9, 10, 11, 12, 13, 14, 15, 16 },
                interval = 0.05,
                looping = false,
                texture = 'objects'
            }
        }
    },
    ['gold-1'] = {
        width = 13,
        height = 13,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 25 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 9, 10, 11, 12, 13, 14, 15, 16 },
                interval = 0.1,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['gold-2'] = {
        width = 23,
        height = 17,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 26 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 9, 10, 11, 12, 13, 14, 15, 16 },
                interval = 0.1,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['gold-3'] = {
        width = 12,
        height = 14,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 27 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 9, 10, 11, 12, 13, 14, 15, 16 },
                interval = 0.1,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['gold-4'] = {
        width = 16,
        height = 16,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 28 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 9, 10, 11, 12, 13, 14, 15, 16 },
                interval = 0.1,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['heart'] = {
        width = 16,
        height = 16,
        ox = 0,
        oy = 0,
        animations = {
            ['idle-down'] = {
                frames = { 46 },
                interval = 1,
                looping = false,
                texture = 'objects'
            },
            ['death'] = {
                frames = { 17, 18, 19, 20, 21, 22, 23, 24 },
                interval = 0.1,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['snake'] = {
        width = 18,
        height = 16,
        ox = 4,
        oy = 0,
        health = 2,
        speed = 5,
        attack = 1,
        animations = {
            ['idle-up'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = true,
                texture = 'enemies'
            },
            ['idle-down'] = {
                frames = { 13, 14, 15, 16, 17, 18, 19, 20 },
                interval = 0.15,
                looping = true,
                texture = 'enemies'
            },
            ['idle-left'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = true,
                texture = 'enemies'
            },
            ['idle-right'] = {
                frames = { 13, 14, 15, 16, 17, 18, 19, 20 },
                interval = 0.15,
                looping = true,
                texture = 'enemies'
            },
            ['walk-up'] = {
                frames = { 1, 2, 3, 4, 9, 10, 11, 12 },
                interval = 0.1,
                looping = true,
                texture = 'enemies'
            },
            ['walk-down'] = {
                frames = { 13, 14, 15, 16, 21, 22, 23, 24 },
                interval = 0.1,
                looping = true,
                texture = 'enemies'
            },
            ['walk-left'] = {
                frames = { 1, 2, 3, 4, 9, 10, 11, 12 },
                interval = 0.1,
                looping = true,
                texture = 'enemies'
            },
            ['walk-right'] = {
                frames = { 13, 14, 15, 16, 21, 22, 23, 24 },
                interval = 0.1,
                looping = true,
                texture = 'enemies'
            },
            ['death'] = {
                frames = { 1, 2, 3, 4, 5, 6, 7, 8 },
                interval = 0.15,
                looping = false,
                texture = 'death-small'
            }
        }
    },
    ['skeleton'] = {
        width = 16,
        height = 18,
        ox = -4,
        oy = 0,
        health = 3,
        speed = 20,
        attack = 1,
        animations = {
            ['idle-down'] = {
                frames = { 25, 26 },
                interval = 0.2,
                looping = true,
                texture = 'enemies'
            }
        }
    }
}