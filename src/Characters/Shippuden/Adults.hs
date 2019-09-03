{-# LANGUAGE OverloadedLists #-}
{-# OPTIONS_HADDOCK hide     #-}

module Characters.Shippuden.Adults (cs) where

import Characters.Base

import qualified Model.Skill as Skill

cs :: [Category -> Character]
cs =
  [ Character
    "Kakashi Hatake"
    "For most of his life, Kakashi has avoided using Kamui—his Sharingan's ultimate ability—unless absolutely necessary, due to the mental and physical strain. Those days are over. With years of practice and refinement behind him, Kakashi can now rely on Kamui's dimensional warping to torture his enemies and make his allies intangible."
    [ [ Skill.new
        { Skill.name      = "Lightning Beast Fang"
        , Skill.desc      = "Kakashi creates a lightning hound out of his Lightning Blade, which deals 25 piercing damage to an enemy. If the target is damaged, they will be stunned for 1 turn. During the next turn, this skill becomes [Lightning Blade Finisher][n][r]."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin, Rand]
        , Skill.effects   =
          [ To Enemy do
                trap' 1 (OnDamaged All) $ apply 1 [Stun All]
                pierce 25
          ,  To Self $ vary' 1 "Lightning Beast Fang" "Lightning Blade Finisher"
          ]
        }
      , Skill.new
        { Skill.name      = "Lightning Blade Finisher"
        , Skill.desc      = "Deals 35 piercing damage to an enemy. Deals 15 additional damage if the target is affected by [Lightning Beast Fang]."
        , Skill.classes   = [Chakra, Melee]
        , Skill.cost      = [Nin, Rand]
        , Skill.effects   =
          [ To Enemy do
              bonus <- 15 `bonusIf` targetHas "Lightning Beast Fang"
              pierce (35 + bonus)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Kamui"
        , Skill.desc      = "If used on an enemy, deals 45 piercing damage to them, increases their cooldowns by 1 turn, and increases the costs of their skills by 1 random chakra. If used on an ally, cures them of enemy effects and makes them invulnerable for 1 turn."
        , Skill.classes   = [Chakra, Ranged, Bypassing]
        , Skill.cost      = [Blood, Gen]
        , Skill.effects   =
          [ To Enemy $ pierce 45
          , To XAlly do
                cureAll
                apply 1 [Invulnerable All]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Team Tactics"
        , Skill.desc      = "For 3 turns, the cooldowns of Kakashi's allies are decreased by 1. While active, the first enemy skill used will replace this skill for 1 turn. Kakashi's copy of the skill has no chakra cost and ends when this skill reverts."
        , Skill.classes   = [Mental, Unreflectable]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To XAllies $ apply 3 [Snare (-1)]
          , To Enemies $ apply' "Team Tactics " 3 [Replace 1 All 2 True]
          ]
        }
      ]
    , [ invuln "Shadow Clone" "Kakashi" [Chakra] ]
    ] []
  , Character
    "Asuma Sarutobi"
    "Having somehow managed to avoid lung cancer, Asuma remains the leader of Team 10. Using techniques he learned from the Fire Temple, he hinders his opponents and instantly executes weak enemies."
    [ [ Skill.new
        { Skill.name      = "Thousand Hand Strike"
        , Skill.desc      = "Asuma summons Kannon, the Fire Temple's patron spirit, which provides him with 40 permanent destructible defense and deals 25 damage to an enemy. Next turn, this skill becomes [Kannon Strike][r]. When [Kannon Strike] ends, this skill is disabled for 1 turn."
        , Skill.require   = HasI (-1) "Overheating"
        , Skill.classes   = [Physical, Melee, Summon]
        , Skill.cost      = [Blood, Rand]
        , Skill.effects   =
          [ To Enemy $ damage 25
          , To Self do
                defend 0 40
                vary' 1 "Thousand Hand Strike" "Kannon Strike"
          ]
        }
      , Skill.new
        { Skill.name      = "Kannon Strike"
        , Skill.desc      = "Deals 20 damage to an enemy. This skill remains [Kannon Strike] for another turn."
        , Skill.classes   = [Physical, Melee, Nonstacking]
        , Skill.cost      = [Rand]
        , Skill.effects   =
          [ To Enemy $ damage 20
          , To Self do
                tag' "Overheating" 2
                vary' 1 "Thousand Hand Strike" "Kannon Strike"
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Burning Ash"
        , Skill.desc      = "Asuma continually exhales a cloud of combustible ash upon his enemies, increasing the cooldowns of their skills by 1 turn. While active, this skill becomes [Burning Ash: Ignite][b]."
        , Skill.classes   = [Bane, Ranged, Unreflectable]
        , Skill.cost      = [Gen, Rand]
        , Skill.dur       = Action 0
        , Skill.start     =
          [ To Self $ vary "Burning Ash" "Burning Ash: Ignite"]
        , Skill.effects   =
          [ To Enemies $ apply 0 [Snare 1] ]
        }
      , Skill.new
        { Skill.name      = "Burning Ash: Ignite"
        , Skill.desc      = "Asuma strikes a piece of flint between his teeth, producing a spark that sets fire to his piles of ash and burns them away. The fire deals 10 affliction damage to each enemy per stack of [Burning Ash] on them."
        , Skill.classes   = [Ranged, Bypassing, Uncounterable, Unreflectable]
        , Skill.cost      = [Blood]
        , Skill.effects   =
          [ To Enemies do
                stacks <- targetStacks "Burning Ash"
                afflict (10 * stacks)
          , To Self do
                cancelChannel "Burning Ash"
                everyone $ remove "Burning Ash"
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Decapitate"
        , Skill.desc      = "Bypassing invulnerability, Asuma mercilessly slaughters an enemy whose health is at or below 25."
        , Skill.classes   = [Physical, Melee, Bypassing, Uncounterable, Unreflectable]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                health <- target health
                when (health <= 25) kill
          ]
        }
      ]
    , [ invuln "Dodge" "Asuma" [Physical] ]
    ] []
  , Character
    "Might Guy"
    "Over the past few years, Guy has learned restraint. By gradually opening his Gates in sequence, he avoids the risk of burning out before the battle is won."
    [ [ Skill.new
        { Skill.name      = "Nunchaku"
        , Skill.desc      = "Using his signature Twin Fangs weapons, Guy deals 10 damage to an enemy for 3 turns. While active, if an enemy uses a physical skill on him, he will deal 10 damage to them. Deals 5 additional damage on the first turn per stack of [Single Gate Release]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.dur       = Action 3
        , Skill.start     =
          [ To Self $ flag' "first" ]
        , Skill.effects   =
          [ To Self $ trapFrom 1 (OnHarmed Physical) $ damage 10
          , To Enemy do
                firstTurn <- userHas "first"
                if firstTurn then do
                    stacks <- userStacks "Single Gate Release"
                    damage (10 + 5 * stacks)
                else
                    damage 10
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Fiery Kick"
        , Skill.desc      = "Guy slams his leg into an enemy, dealing 35 damage and weakening their damage by 20 for 1 turn. Deals 5 additional damage per stack of [Single Gate Release]. At 6 stacks of [Single Gate Release], this skill becomes [Asakujaku][b][t]. At 7 stacks of [Single Gate Release], this skill becomes [Hirudora][b][t]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Blood, Tai]
        , Skill.effects   =
          [ To Enemy do
                stacks <- userStacks "Single Gate Release"
                damage (35 + 5 * stacks)
                apply 1 [Weaken All Flat 20]
          ]
        }
      , Skill.new
        { Skill.name      = "Asakujaku"
        , Skill.desc      = "With unparalleled speed and power, Guy deals 60 damage to an enemy and stuns them for 1 turn. At 7 stacks of [Single Gate Release], this skill becomes [Hirudora][b][t]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Blood, Tai]
        , Skill.effects   =
          [ To Enemy do
                damage 60
                apply 1 [Stun All]
          ]
        }
      , Skill.new
        { Skill.name      = "Hirudora"
        , Skill.desc      = "Using one single punch, Guy deals 300 damage to one enemy."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Blood, Tai]
        , Skill.effects   =
          [ To Enemy $ damage 300 ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Single Gate Release"
        , Skill.desc      = "Guy opens one of his internal Gates, losing 5 health and gaining 5 points of permanent damage reduction."
        , Skill.classes   = [Mental, Unremovable]
        , Skill.charges   = 7
        , Skill.effects   =
          [ To Self do
                sacrifice 0 5
                apply 0 [Reduce All Flat 5]
                stacks <- userStacks "Single Gate Release"
                case stacks of
                    6 -> vary "Fiery Kick" "Asakujaku"
                    7 -> vary "Fiery Kick" "Hirudora"
                    _ -> return ()
          ]
        }
      ]
    , [ invuln "Block" "Guy" [Physical] ]
    ] []
  , Character
    "Maki"
    "A jōnin from the Hidden Sand Village, Maki studied under Pakura and mourned her death greatly. As a member of the Allied Shinobi Forces Sealing Team, Maki must put aside her long-held grudge against the Hidden Stone Village for killing her teacher."
    [ [ Skill.new
        { Skill.name      = "Binding Cloth"
        , Skill.desc      = "Maki deploys a roll of cloth from within a seal and wraps it around herself, gaining 50% damage reduction for 1 turn. If an enemy uses a skill on Maki, the cloth wraps around them, stunning their physical and melee skills for 1 turn."
        , Skill.classes   = [Physical, Ranged, Invisible]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Self do
                apply 1 [Reduce All Percent 50]
                trapFrom 1 (OnHarmed All) $ apply 1 [Stun Physical, Stun Melee]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Humidified Cloth"
        , Skill.desc      = "Maki soaks a strip of cloth in steam and lashes out with it, dealing 20 piercing damage to an enemy and stunning their skills that affect opponents for 1 turn."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Enemy do
                damage 20
                apply 1 [Stun Harmful]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Cloth Paralysis"
        , Skill.desc      = "Maki binds an enemy in rolls of cloth, stunning their chakra and ranged skills for 2 turns. While active, Melee skills deal 5 additional damage to the target."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Nin, Gen]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Enemy $ apply 2 [Stun Chakra, Stun Ranged, Bleed Melee Flat 5] ]
        }
      ]
    , [ invuln "Cloth Dome" "Maki" [Physical] ]
    ] []
  , Character
    "Akatsuchi"
    "A jōnin from the Hidden Rock Village, Akatsauchi is cheerful and excitable. He uses brute strength and rock golems to pummel his enemies to the ground."
    [ [ Skill.new
        { Skill.name      = "High-Speed Assault"
        , Skill.desc      = "Akatsuchi punches an enemy with all his might, dealing 25 damage. Costs 1 fewer random chakra during [Stone Golem]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai, Rand]
        , Skill.effects   = [ To Enemy $ damage 25 ]
        , Skill.changes   =
            changeWithChannel "Stone Golem" \x -> x { Skill.cost = [Tai] }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Stone Golem"
        , Skill.desc      = "A golem of rock rampages across the battlefield, dealing 15 damage to all enemies for 2 turns and providing Akatsuki with 25% damage reduction."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin, Rand]
        , Skill.cooldown  = 2
        , Skill.dur       = Action 2
        , Skill.effects   =
          [ To Enemies $ damage 15
          , To Self    $ apply 1 [Reduce All Percent 25]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Chakra Devour"
        , Skill.desc      = "A stone golem attacks an enemy, dealing 15 damage and depleting 1 random chakra."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                deplete 1
                damage 15
          ]
        }
      ]
    , [ invuln "Dodge" "Akatsuchi" [Physical] ]
    ] []
  , Character
    "Kurotsuchi"
    "A jōnin from the Hidden Rock Village, Kurotsuchi is the Third Tsuchikage's granddaughter. Witty and self-assured, Kurotsuchi is famed for her unflinching resolve in the face of danger."
    [ [ Skill.new
        { Skill.name      = "Lava Quicklime"
        , Skill.desc      = "Kurotsuchi expels a mass of quicklime from her mouth, dealing 25 damage to an enemy and gaining 50% damage reduction for 1 turn."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                damage 25
                tag 1
          , To Self $ apply 1 [Reduce All Percent 50]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Water Trumpet"
        , Skill.desc      = "Kurotsuchi cups her hand to her mouth and expels a jet of water, dealing 20 damage to an enemy. If the target was damaged by Lava Quicklime last turn, their physical and chakra skills are stunned for 1 turn."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Enemy do
                damage 20
                whenM (targetHas "Lava Quicklime") $
                    apply 1 [Stun Physical, Stun Chakra]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Falling Earth Spears"
        , Skill.desc      = "Spikes of stone and mud erupt from the ground, dealing 15 damage to all enemies and making them immune to effects from each other."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Blood, Rand]
        , Skill.effects   =
          [ To Enemies do
                damage 15
                apply 1 [Seal]
          ]
        }
      ]
    , [ invuln "Dodge" "Kurotsuchi" [Physical] ]
    ] []
  , Character
    "Ittan"
    "A chūnin from the Hidden Rock Village, Ittan is battle-hardened and level-headed. By reshaping the terrain, Ittan turns the battlefield to his advantage."
    [ [ Skill.new
        { Skill.name      = "Battlefield Trenches"
        , Skill.desc      = "By raising and lowering ground levels, Ittan alters the battlefield in his favor. For 2 turns, all enemies receive 20% more damage and Ittan gains 15 points of damage reduction."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Blood, Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Self $ apply 2 [Reduce All Flat 15]
          , To Enemies $ apply 2 [Bleed All Percent 20]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Mobile Core"
        , Skill.desc      = "Ittan disrupts the ground under an enemy, dealing 30 damage to them and weakening their damage by 10 for 1 turn."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Rand, Rand]
        , Skill.effects   =
          [ To Enemy do
                damage 30
                apply 1 [Weaken All Flat 10]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Earth Dome"
        , Skill.desc      = "A shield of rock protects Ittan and one of his allies, making them invulnerable to ranged skills for 1 turn."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Self $ apply 1 [Invulnerable Ranged]
          , To Ally $ apply 1 [Invulnerable Ranged]
          ]
        }
      ]
    , [ invuln "Trench Defense" "Ittan" [Physical] ]
    ] []
  , Character
    "Kitsuchi"
    "A jōnin from the Hidden Rock Village, Kitsuchi is the Third Tsuchikage's son and Kurotsuchi's father. He commands the Allied Shinobi Forces Second Division, a responsibility he takes with the utmost seriousness."
    [ [ Skill.new
        { Skill.name      = "Rock Fist"
        , Skill.desc      = "A massive stone hand punches an enemy, dealing 35 damage and preventing them from countering or reflecting skills for 1 turn."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                damage 35
                apply 1 [Uncounter]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Erupt"
        , Skill.desc      = "A mountain bursts from the ground under Kitsuchi's enemies, dealing 10 damage to them and providing him with 20% damage reduction for 1 turn. For 1 turn, stuns, counters, and reflects applied by enemies will last 1 fewer turn."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Self $ apply 1 [Reduce All Percent 20]
          , To Enemies do
                damage 10
                apply 1 [ Throttle 1 $ Any Stun
                        , Throttle 1 $ Only Reflect
                        , Throttle 1 $ Only ReflectAll
                        ]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Sandwiching Mountain"
        , Skill.desc      = "Two rock formations slam into an enemy from either side, dealing 45 damage to them and stunning their physical and mental skills for 2 turns."
        , Skill.classes   = [Physical, Ranged]
        , Skill.cost      = [Blood, Blood]
        , Skill.cooldown  = 2
        , Skill.dur       = Control 2
        , Skill.effects   =
          [ To Enemy do
                damage 45
                apply 2 [Stun Physical, Stun Mental]
          ]
        }
      ]
    , [ invuln "Rock Shelter" "Kitsuchi" [Physical] ]
    ] []
  , Character
    "C"
    "A jōnin from the Hidden Cloud Village, C is one of the Raikage's bodyguards. Reliable and dutiful, C supports his allies with healing and sensing."
    [ [ Skill.new
        { Skill.name      = "Sensory Technique"
        , Skill.desc      = "C strikes a random enemy while detecting the flow of chakra, dealing 20 damage to them. Next turn, if an enemy uses a skill on C, he will become invulnerable for 1 turn."
        , Skill.classes   = [Mental, Nonstacking, Ranged]
        , Skill.cost      = [Gen]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To REnemy $ damage 20
          , To Self   $ trap 1 (OnHarmed All) $ apply 1 [Invulnerable All]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Mystical Palm Healing"
        , Skill.desc      = "C restores 25 health to himself or an ally."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Ally $ heal 25 ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Flash Pillar"
        , Skill.desc      = "A flash of lightning blinds and disorients an enemy, dealing 35 damage to them and making them immune to effects from allies."
        , Skill.classes   = [Mental, Ranged]
        , Skill.cost      = [Gen, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                damage 35
                apply 1 [Seal]
          ]
        }
      ]
    , [ invuln "Parry" "C" [Physical] ]
    ] []
  , Character
    "Atsui"
    "A chūnin from the Hidden Cloud Village, Atsui is a hot-headed hotshot whose favorite word is 'Hot' and whose name literally means 'Hot'. An incredibly complex character with hidden depths, Atsui's skills are as diverse as his multifaceted personality."
    [ [ Skill.new
        { Skill.name      = "Burning Blade"
        , Skill.desc      = "Fire envelops Atsui's sword and surrounds him, providing 10 points of damage reduction to him for 3 turns. While active, any enemy who uses a skill on Atsui will receive 10 affliction damage."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Self do
                apply 3 [Reduce All Flat 10]
                trapFrom 3 (OnHarmed All) $ afflict 10
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Fire Wall"
        , Skill.desc      = "Fire erupts around Atsui's enemies. Next turn, any enemy who uses a skill will receive 10 affliction damage. Costs 1 fewer random chakra during [Burning Blade]."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemies $ trap 1 (OnAction All) $ afflict 10 ]
        , Skill.changes   =
            changeWith "Burning Blade" \x -> x { Skill.cost = [Nin] }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Flame Slice"
        , Skill.desc      = "Atsui slashes at an enemy with his fiery blade, sending an arc of flame in their direction that deals 25 piercing damage."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.effects   =
          [ To Enemy $ damage 25 ]
        }
      ]
    , [ invuln "Parry" "Atsui" [Physical] ]
    ] []
  , Character
    "Izumo and Kotetsu"
    "A pair of chūnin from the Hidden Leaf Village assigned to hunt down members of Akatsuki, Izumo and Kotetsu are close friends and effective partners. Although their strength may be somewhat lacking as individuals, they have a significant advantage of their own: there are two of them."
    [ [ Skill.new
        { Skill.name      = "Mace Crush"
        , Skill.desc      = "Kotetsu slams an enemy with his mace, dealing 30 damage. Deals 10 additional damage to an enemy affected by [Syrup Trap]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand, Rand]
        , Skill.effects   =
          [ To Enemy do
                bonus <- 10 `bonusIf` targetHas "Syrup Trap"
                damage (30 + bonus)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Syrup Trap"
        , Skill.desc      = "Izumo spits out a field of sticky syrup that impedes the enemy team. For 2 turns, enemies that use chakra skills will have their chakra skills stunned for 1 turn, and enemies that use physical skills will have their physical skills stunned for 1 turn."
        , Skill.classes   = [Ranged, Bane]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Enemies do
                trap 2 (Countered Chakra)   $ apply 1 [Stun Chakra]
                trap 2 (Countered Physical) $ apply 1 [Stun Physical]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Devastate"
        , Skill.desc      = "Izumo flanks an enemy from the left, making them vulnerable to Kotetsu's [Annihilate] for 3 turns. If the target is affected by [Annihilate], Izumo deals 65 damage to them. If Izumo uses [Tag Team], this skill becomes [Annihilate][t]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Enemy do
                tag 3
                whenM (targetHas "Annihilate") $ damage 65
          ]
        }
      , Skill.new
        { Skill.name      = "Annihilate"
        , Skill.desc      = "Kotetsu flanks an enemy from the left, making them vulnerable to Izumo's [Devastate] for 3 turns. If the target is affected by [Devastate], Kotetsu deals 65 damage to them. If Kotetsu uses [Tag Team], this skill becomes [Devastate][t]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Enemy do
                tag 3
                whenM (targetHas "Devastate") $ damage 65
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Tag Team"
        , Skill.desc      = "Izumo tags out, swapping his health with Kotetsu's. Once used, if Kotetsu dies, Izumo will immediately take over. "
        , Skill.classes   = [Nonstacking, Uncounterable, Unreflectable, Unremovable]
        , Skill.cost      = [Rand]
        , Skill.require   = HasI (-1) "solo"
        , Skill.effects   =
          [ To Self do
                userHealth <- user health
                tagHealth <- userStacks "Kotetsu's Health"
                setHealth if tagHealth == 0 then 100 else tagHealth
                remove "Kotetsu's Health"
                addStacks "Izumo's Health" userHealth
                vary "Devastate" "Annihilate"
                vary "Tag Team" "Tag Team"
                trap' 0 OnRes do
                    tagHealth' <- userStacks "Izumo's Health"
                    setHealth tagHealth'
                    remove "Izumo's Health"
                    hide' "solo" 0 []
                    vary "Devastate" baseVariant
                    vary "Tag Team" baseVariant
          ]
        }
      , Skill.new
        { Skill.name      = "Tag Team"
        , Skill.desc      = "Kotetsu tags out, swapping his health with Izumo's. Once used, if Izumo dies, Kotetsu will immediately take over. "
        , Skill.classes   = [Nonstacking, Uncounterable, Unreflectable, Unremovable]
        , Skill.cost      = [Rand]
        , Skill.require   = HasI (-1) "solo"
        , Skill.effects   =
          [ To Self do
                userHealth <- user health
                tagHealth <- userStacks "Izumo's Health"
                setHealth if tagHealth == 0 then 100 else tagHealth
                remove "Izumo's Health"
                addStacks "Kotetsu's Health" userHealth
                vary "Devastate" baseVariant
                vary "Tag Team" baseVariant
                trap' 0 OnRes do
                    tagHealth' <- userStacks "Kotetsu's Health"
                    setHealth tagHealth'
                    remove "Kotetsu's Health"
                    hide' "solo" 0 []
                    vary "Devastate" "Annihilate"
                    vary "Tag Team" "Tag Team"
          ]
        }
      ]
    ] []
  , Character
    "Tsunade"
    "Tsunade has become the fifth Hokage. Knowing the Hidden Leaf Village's fate depends on her, she holds nothing back. Even if one of her allies is on the verge of dying, she can keep them alive long enough for her healing to get them back on their feet."
    [ [ Skill.new
        { Skill.name      = "Heaven Spear Kick"
        , Skill.desc      = "Tsunade spears an enemy with her foot, dealing 20 piercing damage to them. If an ally is affected by [Healing Wave], their health cannot drop below 1 next turn. Spends a Seal if available to deal 20 additional damage and demolish the target's destructible defense and Tsunade's destructible barrier."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.effects   =
          [ To Enemy do
                has <- userHas "Strength of One Hundred Seal"
                when has demolishAll
                pierce (20 + if has then 20 else 0)
          , To Allies $ whenM (targetHas "Healing Wave") $ apply 1 [Endure]
          , To Self do
              remove "Strength of One Hundred Seal"
              vary "Strength of One Hundred Seal" baseVariant
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Healing Wave"
        , Skill.desc      = "Tsunade pours chakra into an ally, restoring 30 health to them immediately and 10 health each turn for 2 turns. Spends a Seal if available to restore 10 additional health immediately and last 3 turns."
        , Skill.classes   = [Chakra, Unremovable]
        , Skill.cost      = [Nin, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To XAlly do
                has <- userHas "Strength of One Hundred Seal"
                heal (20 + if has then 10 else 0)
                apply (if has then (-3) else (-2)) [Heal 10]
          , To Self do
                remove "Strength of One Hundred Seal"
                vary "Strength of One Hundred Seal" baseVariant
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Strength of One Hundred Seal"
        , Skill.desc      = "Tsunade activates her chakra-storing Seal, restoring 25 health and empowering her next skill. Spends a Seal if available to instead restore 50 health to Tsunade and gain 2 random chakra."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Self do
                heal 25
                tag 0
                vary "Strength of One Hundred Seal"
                     "Strength of One Hundred Seal"
          ]
        }
      , Skill.new
        { Skill.name      = "Strength of One Hundred Seal"
        , Skill.desc      = "Tsunade activates her chakra-storing Seal, restoring 25 health and empowering her next skill. Spends a Seal if available to instead restore 50 health to Tsunade and gain 2 random chakra."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Self do
                heal 50
                gain [Rand, Rand]
                vary "Strength of One Hundred Seal" baseVariant
                remove "Strength of One Hundred Seal"
          ]
        }
      ]
    , [ invuln "Block" "Tsunade" [Physical] ]
    ] []
  , Character
    "Ōnoki"
    "The third Tsuchikage of the Hidden Rock Village, Onoki is the oldest and most stubborn Kage. His remarkable ability to control matter on an atomic scale rapidly grows in strength until it can wipe out a foe in a single attack."
    [ [ Skill.new
        { Skill.name      = "Earth Golem"
        , Skill.desc      = "A golem of rock emerges from the ground, providing 10 permanent destructible defense to his team and dealing 10 damage to all enemies."
        , Skill.classes   = [Chakra, Physical, Melee]
        , Skill.cost      = [Nin]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Allies  $ defend 0 10
          , To Enemies $ damage 10
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Lightened Boulder"
        , Skill.desc      = "Ōnoki negates the gravity of an ally, providing 10 points of damage reduction to them for 2 turns. While active, the target cannot be countered or reflected."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To XAlly $ apply 2 [Reduce All Flat 10, AntiCounter] ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Atomic Dismantling"
        , Skill.desc      = "The atomic bonds within an enemy shatter, dealing 20 piercing damage to them and permanently increasing the damage of this skill by 10."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin]
        , Skill.effects   =
          [ To Enemy do
                stacks <- userStacks "Atomic Dismantling"
                pierce (20 + 10 * stacks)
          , To Self addStack
          ]
        }
      ]
    , [ invuln "Flight" "Ōnoki" [Chakra] ]
    ] []
  , Character
    "Mei Terumi"
    "The third Mizukage of the Hidden Mist Village, Mei works tirelessly to help her village overcome its dark history and become a place of kindness and prosperity. Her corrosive attacks eat away at the defenses of her "
    [ [ Skill.new
        { Skill.name      = "Solid Fog"
        , Skill.desc      = "Mei exhales a cloud of acid mist, dealing 15 affliction damage to an enemy for 3 turns."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Enemy $ afflict 15 ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Water Bomb"
        , Skill.desc      = "Water floods the battlefield, dealing 20 piercing damage to all enemies and preventing them from reducing damage or becoming invulnerable for 1 turn."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Nin, Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemies do
                pierce 20
                apply 1 [Expose]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Lava Monster"
        , Skill.desc      = "Mei spits a stream of hot lava, dealing 10 affliction damage to all enemies and removing 20 destructible defense from them for 3 turns."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Blood, Rand]
        , Skill.cooldown  = 3
        , Skill.dur       = Action 3
        , Skill.effects   =
          [ To Enemies do
              demolish 20
              afflict 10
          ]
        }
      ]
    , [ invuln "Flee" "Mei" [Physical] ]
    ] []
  ]
