--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroDBC
local DBC = HeroDBC.DBC
-- HeroLib
local HL            = HeroLib
local Cache         = HeroCache
local Unit          = HL.Unit
local Player        = Unit.Player
local Target        = Unit.Target
local Pet           = Unit.Pet
local Spell         = HL.Spell
local Item          = HL.Item
-- HeroRotation
local HR            = HeroRotation
local AoEON         = HR.AoEON
local CDsON         = HR.CDsON
local Cast          = HR.Cast
local CastSuggested = HR.CastSuggested
-- lua
local match      = string.match

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Define S/I for spell and item arrays
local S = Spell.DemonHunter.Havoc
local I = Item.DemonHunter.Havoc

-- Create table to exclude above trinkets from On Use function
local OnUseExcludes = {
}

-- Rotation Var
local ShouldReturn -- Used to get the return string
local Enemies8y, Enemies20y
local EnemiesCount8, EnemiesCount20
local ChaosTheoryEquipped = Player:HasLegendaryEquipped(23)
local BurningWoundEquipped = Player:HasLegendaryEquipped(25)

-- GUI Settings
local Everyone = HR.Commons.Everyone
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.DemonHunter.Commons,
  Havoc = HR.GUISettings.APL.DemonHunter.Havoc
}

-- Interrupts List
local StunInterrupts = {
  {S.FelEruption, "Cast Fel Eruption (Interrupt)", function () return true; end},
  {S.ChaosNova, "Cast Chaos Nova (Interrupt)", function () return true; end},
}

-- Variables
local VarPoolingForMeta = false
local VarBladeDance = false
local VarPoolingForBladeDance = false
local VarPoolingForEyeBeam = false
local VarWaitingForEssenceBreak = false
local VarWaitingForMomentum = false

HL:RegisterForEvent(function()
  VarPoolingForMeta = false
  VarBladeDance = false
  VarPoolingForBladeDance = false
  VarPoolingForEyeBeam = false
  VarWaitingForEssenceBreak = false
  VarWaitingForMomentum = false
end, "PLAYER_REGEN_ENABLED")

HL:RegisterForEvent(function()
  ChaosTheoryEquipped = Player:HasLegendaryEquipped(23)
  BurningWoundEquipped = Player:HasLegendaryEquipped(25)
end, "PLAYER_EQUIPMENT_CHANGED")

local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

local function IsInMeleeRange(range)
  if S.Felblade:TimeSinceLastCast() <= Player:GCD() then
    return true
  elseif S.VengefulRetreat:TimeSinceLastCast() < 1.0 then
    return false
  end
  return range and Target:IsInMeleeRange(range) or Target:IsInMeleeRange(5)
end

local function CastFelRush()
  if Settings.Havoc.FelRushDisplayStyle == "Suggested" then
    return CastSuggested(S.FelRush)
  elseif Settings.Havoc.FelRushDisplayStyle == "Cooldown" then
    if S.FelRush:TimeSinceLastDisplay() ~= 0 then
      return Cast(S.FelRush, { true, false } )
    else
      return false
    end
  end

  return Cast(S.FelRush)
end

local function ConserveFelRush()
  return not Settings.Havoc.ConserveFelRush or S.FelRush:Charges() == 2
end

local function EvalutateTargetIfFilterDemonsBite202(TargetUnit)
  return TargetUnit:DebuffRemains(S.BurningWoundDebuff)
end

local function EvaluateTargetIfDemonsBite204(TargetUnit)
  return (BurningWoundEquipped and TargetUnit:DebuffRemains(S.BurningWoundDebuff) < 4)
end

local function EvalutateTargetIfFilterDemonsBite206(TargetUnit)
  return TargetUnit:DebuffRemains(S.BurningWoundDebuff)
end

local function EvaluateTargetIfDemonsBite208(TargetUnit)
  return (BurningWoundEquipped and TargetUnit:DebuffRemains(S.BurningWoundDebuff) < 4)
end

local function Precombat()
  -- flask
  -- augmentation
  -- food
  -- snapshot_stats
  -- potion
  if I.PotionofPhantomFire:IsReady() and Settings.Commons.Enabled.Potions then
    if Cast(I.PotionofPhantomFire, nil, Settings.Commons.DisplayStyle.Potions) then return "potion_of_unbridled_fury 2"; end
  end
  -- Manually added: Fel Rush if out of range
  if not Target:IsInMeleeRange(5) and S.FelRush:IsCastable() then
    if Cast(S.FelRush, nil, nil, not Target:IsInRange(15)) then return "fel_rush 6"; end
  end
  -- Manually added: Demon's Bite/Demon Blades if in melee range
  if Target:IsInMeleeRange(5) and (S.DemonsBite:IsCastable() or S.DemonBlades:IsAvailable()) then
    if Cast(S.DemonsBite, nil, nil, not Target:IsInMeleeRange(5)) then return "demons_bite or demon_blades 8"; end
  end
end

local function Cooldown()
  -- metamorphosis,if=!(talent.demonic.enabled|variable.pooling_for_meta)&cooldown.eye_beam.remains>20&(!covenant.venthyr.enabled|!dot.sinful_brand.ticking)|fight_remains<25
  if S.Metamorphosis:IsCastable() and (not (S.Demonic:IsAvailable() or VarPoolingForMeta) and S.EyeBeam:CooldownRemains() > 20 and (not S.SinfulBrand:IsAvailable() or Target:DebuffDown(S.SinfulBrandDebuff)) or HL.BossFilteredFightRemains("<", 25)) then
    if Cast(S.Metamorphosis, Settings.Havoc.GCDasOffGCD.Metamorphosis, nil, not Target:IsInRange(40)) then return "metamorphosis 22"; end
  end
  -- metamorphosis,if=talent.demonic.enabled&(cooldown.eye_beam.remains>20&(!variable.blade_dance|cooldown.blade_dance.remains>gcd.max))&(!covenant.venthyr.enabled|!dot.sinful_brand.ticking)
  if S.Metamorphosis:IsCastable() and (S.Demonic:IsAvailable() and (S.EyeBeam:CooldownRemains() > 20 and ((not VarBladeDance) or S.BladeDance:CooldownRemains() > Player:GCD())) and (not S.SinfulBrand:IsAvailable() or Target:DebuffDown(S.SinfulBrandDebuff))) then
    if Cast(S.Metamorphosis, Settings.Havoc.GCDasOffGCD.Metamorphosis, nil, not Target:IsInRange(40)) then return "metamorphosis 24"; end
  end
  -- sinful_brand,if=!dot.sinful_brand.ticking
  if S.SinfulBrand:IsCastable() and (Target:DebuffDown(S.SinfulBrandDebuff)) then
    if Cast(S.SinfulBrand, nil, Settings.Commons.DisplayStyle.Covenant, not Target:IsSpellInRange(S.SinfulBrand)) then return "sinful_brand 26"; end
  end
  -- the_hunt,if=!talent.demonic.enabled&!variable.waiting_for_momentum|buff.furious_gaze.up
  if S.TheHunt:IsCastable() and (not S.Demonic:IsAvailable() and not VarWaitingForMomentum or Player:BuffUp(S.FuriousGazeBuff)) then
    if Cast(S.TheHunt, nil, Settings.Commons.DisplayStyle.Covenant, not Target:IsSpellInRange(S.TheHunt)) then return "the_hunt 28"; end
  end
  -- fodder_to_the_flame
  if S.FoddertotheFlame:IsCastable() then
    if Cast(S.FoddertotheFlame, nil, Settings.Commons.DisplayStyle.Covenant) then return "fodder_to_the_flame 30"; end
  end
  -- elysian_decree,if=(active_enemies>desired_targets|raid_event.adds.in>30)
  if S.ElysianDecree:IsCastable() and (EnemiesCount8 > 0) then
    if Cast(S.ElysianDecree, nil, Settings.Commons.DisplayStyle.Covenant, not Target:IsInRange(30)) then return "elysian_decree 32"; end
  end
  -- potion,if=buff.metamorphosis.remains>25|fight_remains<60
  if I.PotionofPhantomFire:IsReady() and Settings.Commons.Enabled.Potions and (Player:BuffRemains(S.MetamorphosisBuff) > 25 or HL.BossFilteredFightRemains("<", 60)) then
    if Cast(I.PotionofPhantomFire, nil, Settings.Commons.DisplayStyle.Potions) then return "potion_of_unbridled_fury 34"; end
  end
  -- use_items,if=buff.metamorphosis.up
  if Settings.Commons.Enabled.Trinkets and (Player:BuffUp(S.MetamorphosisBuff)) then
    local TrinketToUse = Player:GetUseableTrinkets(OnUseExcludes)
    if TrinketToUse then
      if Cast(TrinketToUse, nil, Settings.Commons.DisplayStyle.Trinkets) then return "Generic use_items for " .. TrinketToUse:Name(); end
    end
  end
end

local function EssenceBreak()
  -- essence_break,if=fury>=80&(cooldown.blade_dance.ready|!variable.blade_dance)
  if S.EssenceBreak:IsCastable() and IsInMeleeRange() and (Player:Fury() >= 80 and (S.BladeDance:CooldownUp() or (not VarBladeDance))) then
    if Cast(S.EssenceBreak) then return "essence_break 62"; end
  end
  -- death_sweep,if=variable.blade_dance&debuff.essence_break.up
  -- blade_dance,if=variable.blade_dance&debuff.essence_break.up
  if IsInMeleeRange(8) and (VarBladeDance and Target:DebuffDown(S.EssenceBreakDebuff)) then
    if S.DeathSweep:IsReady() then
      if Cast(S.DeathSweep) then return "death_sweep 64"; end
    end
    if S.BladeDance:IsReady() then
      if Cast(S.BladeDance) then return "blade_dance 66"; end
    end
  end
  -- annihilation,if=debuff.essence_break.up
  -- chaos_strike,if=debuff.essence_break.up
  if IsInMeleeRange() and (Target:DebuffUp(S.EssenceBreakDebuff)) then
    if S.Annihilation:IsReady() then
      if Cast(S.Annihilation) then return "annihilation 68"; end
    end
    if S.ChaosStrike:IsReady() then
      if Cast(S.ChaosStrike) then return "chaos_strike 70"; end
    end
  end
end

local function Demonic()
  -- fel_rush,if=(talent.unbound_chaos.enabled&buff.unbound_chaos.up)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
  if S.FelRush:IsCastable() and ((S.UnboundChaos:IsAvailable() and Player:BuffUp(S.UnboundChaosBuff)) and S.FelRush:Charges() == 2) then
    if CastFelRush() then return "fel_rush 82"; end
  end
  -- death_sweep,if=variable.blade_dance
  if S.DeathSweep:IsReady() and IsInMeleeRange(8) and (VarBladeDance) then
    if Cast(S.DeathSweep) then return "death_sweep 84"; end
  end
  -- glaive_tempest,if=active_enemies>desired_targets|raid_event.adds.in>10
  if S.GlaiveTempest:IsReady() and (EnemiesCount8 > 1) then
    if Cast(S.GlaiveTempest, Settings.Havoc.GCDasOffGCD.GlaiveTempest, nil, not Target:IsInMeleeRange(8)) then return "glaive_tempest 86"; end
  end
  -- throw_glaive,if=conduit.serrated_glaive.enabled&cooldown.eye_beam.remains<6&!buff.metamorphosis.up&!debuff.exposed_wound.up
  if S.ThrowGlaive:IsCastable() and (S.SerratedGlaive:IsAvailable() and S.EyeBeam:CooldownRemains() < 6 and Player:BuffDown(S.MetamorphosisBuff) and Target:DebuffDown(S.ExposedWoundDebuff)) then
    if Cast(S.ThrowGlaive, Settings.Havoc.GCDasOffGCD.ThrowGlaive, nil, not Target:IsSpellInRange(S.ThrowGlaive)) then return "throw_glaive 88"; end
  end
  -- eye_beam,if=raid_event.adds.up|raid_event.adds.in>25
  if S.EyeBeam:IsReady() then
    if Cast(S.EyeBeam, Settings.Havoc.GCDasOffGCD.EyeBeam, nil, not Target:IsInRange(20)) then return "eye_beam 90"; end
  end
  -- blade_dance,if=variable.blade_dance&!cooldown.metamorphosis.ready&(cooldown.eye_beam.remains>5|(raid_event.adds.in>cooldown&raid_event.adds.in<25))
  if S.BladeDance:IsReady() and IsInMeleeRange(8) and (VarBladeDance and (S.EyeBeam:CooldownRemains() > 5)) then
    if Cast(S.BladeDance) then return "blade_dance 92"; end
  end
  -- immolation_aura
  if S.ImmolationAura:IsCastable() then
    if Cast(S.ImmolationAura) then return "immolation_aura 94"; end
  end
  -- annihilation,if=!variable.pooling_for_blade_dance
  if S.Annihilation:IsReady() and IsInMeleeRange() and (not VarPoolingForBladeDance) then
    if Cast(S.Annihilation) then return "annihilation 96"; end
  end
  -- felblade,if=fury.deficit>=40
  if S.Felblade:IsCastable() and (Player:FuryDeficit() >= 40) then
    if Cast(S.Felblade, nil, nil, not Target:IsSpellInRange(S.Felblade)) then return "felblade 98"; end
  end
  -- chaos_strike,if=!variable.pooling_for_blade_dance&!variable.pooling_for_eye_beam
  if S.ChaosStrike:IsReady() and IsInMeleeRange() and ((not VarPoolingForBladeDance) and (not VarPoolingForEyeBeam)) then
    if Cast(S.ChaosStrike) then return "chaos_strike 100"; end
  end
  -- fel_rush,if=talent.demon_blades.enabled&!cooldown.eye_beam.ready&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
  if S.FelRush:IsCastable() and (S.DemonBlades:IsAvailable() and not S.EyeBeam:CooldownUp() and ConserveFelRush()) then
    if CastFelRush() then return "fel_rush 102"; end
  end
  -- demons_bite,target_if=min:debuff.burning_wound.remains,if=runeforge.burning_wound&debuff.burning_wound.remains<4
  if S.DemonsBite:IsCastable() then
    if Everyone.CastTargetIf(S.DemonsBite, Enemies8y, "min", EvalutateTargetIfFilterDemonsBite206, EvaluateTargetIfDemonsBite208, not Target:IsSpellInRange(S.DemonsBite)) then return "demons_bite 103"; end
  end
  -- demons_bite
  if S.DemonsBite:IsCastable() and IsInMeleeRange() then
    if Cast(S.DemonsBite) then return "demons_bite 104"; end
  end
  -- throw_glaive,if=buff.out_of_range.up
  if S.ThrowGlaive:IsCastable() and (not IsInMeleeRange()) then
    if Cast(S.ThrowGlaive, Settings.Havoc.GCDasOffGCD.ThrowGlaive, nil, not Target:IsSpellInRange(S.ThrowGlaive)) then return "throw_glaive 106"; end
  end
  -- fel_rush,if=movement.distance>15|buff.out_of_range.up
  if S.FelRush:IsCastable() and (not IsInMeleeRange() and ConserveFelRush()) then
    if CastFelRush() then return "fel_rush 108"; end
  end
  -- vengeful_retreat,if=movement.distance>15
  if S.VengefulRetreat:IsCastable() and (not IsInMeleeRange()) then
    if Cast(S.VengefulRetreat, Settings.Havoc.OffGCDasOffGCD.VengefulRetreat) then return "vengeful_retreat 110"; end
  end
  -- throw_glaive,if=talent.demon_blades.enabled
  if S.ThrowGlaive:IsCastable() and (S.DemonBlades:IsAvailable()) then
    if Cast(S.ThrowGlaive, Settings.Havoc.GCDasOffGCD.ThrowGlaive, nil, not Target:IsSpellInRange(S.ThrowGlaive)) then return "throw_glaive 112"; end
  end
end

local function Normal()
  -- vengeful_retreat,if=talent.momentum.enabled&buff.prepared.down&time>1
  if S.VengefulRetreat:IsCastable() and (S.Momentum:IsAvailable() and Player:BuffDown(S.PreparedBuff) and HL.CombatTime() > 1) then
    if Cast(S.VengefulRetreat, Settings.Havoc.OffGCDasOffGCD.VengefulRetreat) then return "vengeful_retreat 122"; end
  end
  -- fel_rush,if=(variable.waiting_for_momentum|talent.unbound_chaos.enabled&buff.unbound_chaos.up)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
  if S.FelRush:IsCastable() and ((VarWaitingForMomentum or S.UnboundChaos:IsAvailable() and Player:BuffUp(S.UnboundChaosBuff)) and ConserveFelRush()) then
    if CastFelRush() then return "fel_rush 124"; end
  end
  -- fel_barrage,if=active_enemies>desired_targets|raid_event.adds.in>30
  if S.FelBarrage:IsCastable() and IsInMeleeRange(8) and (EnemiesCount8 > 1) then
    if Cast(S.FelBarrage) then return "fel_barrage 126"; end
  end
  -- death_sweep,if=variable.blade_dance
  if S.DeathSweep:IsReady() and IsInMeleeRange(8) and (VarBladeDance) then
    if Cast(S.DeathSweep) then return "death_sweep 128"; end
  end
  -- immolation_aura
  if S.ImmolationAura:IsCastable() then
    if Cast(S.ImmolationAura) then return "immolation_aura 130"; end
  end
  -- glaive_tempest,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>10)
  if S.GlaiveTempest:IsReady() and ((not VarWaitingForMomentum) and EnemiesCount8 > 1) then
    if Cast(S.GlaiveTempest, Settings.Havoc.GCDasOffGCD.GlaiveTempest) then return "glaive_tempest 132"; end
  end
  -- throw_glaive,if=conduit.serrated_glaive.enabled&cooldown.eye_beam.remains<6&!buff.metamorphosis.up&!debuff.exposed_wound.up
  if S.ThrowGlaive:IsCastable() and (S.SerratedGlaive:IsAvailable() and S.EyeBeam:CooldownRemains() < 6 and Player:BuffDown(S.MetamorphosisBuff) and Target:DebuffDown(S.ExposedWoundDebuff)) then
    if Cast(S.ThrowGlaive, Settings.Havoc.GCDasOffGCD.ThrowGlaive, nil, not Target:IsSpellInRange(S.ThrowGlaive)) then return "throw_glaive 134"; end
  end
  -- eye_beam,if=!variable.waiting_for_momentum&(active_enemies>desired_targets|raid_event.adds.in>15)
  if S.EyeBeam:IsReady() and (not VarWaitingForMomentum and EnemiesCount20 > 0) then
    if Cast(S.EyeBeam, Settings.Havoc.GCDasOffGCD.EyeBeam) then return "eye_beam 136"; end
  end
  -- blade_dance,if=variable.blade_dance
  if S.BladeDance:IsReady() and IsInMeleeRange(8) and (VarBladeDance) then
    if Cast(S.BladeDance) then return "blade_dance 138"; end
  end
  -- felblade,if=fury.deficit>=40
  if S.Felblade:IsCastable() and (Player:FuryDeficit() >= 40) then
    if Cast(S.Felblade, nil, nil, not Target:IsSpellInRange(S.Felblade)) then return "felblade 140"; end
  end
  -- annihilation,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance&!variable.waiting_for_essence_break
  if S.Annihilation:IsReady() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or (not VarWaitingForMomentum) or Player:FuryDeficit() < 30 or Player:BuffRemains(S.MetamorphosisBuff) < 5) and (not VarPoolingForBladeDance) and (not VarWaitingForEssenceBreak)) then
    if Cast(S.Annihilation) then return "annihilation 144"; end
  end
  -- chaos_strike,if=(talent.demon_blades.enabled|!variable.waiting_for_momentum|fury.deficit<30)&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&!variable.waiting_for_essence_break
  if S.ChaosStrike:IsReady() and IsInMeleeRange() and ((S.DemonBlades:IsAvailable() or (not VarWaitingForMomentum) or Player:FuryDeficit() < 30) and (not VarPoolingForMeta) and (not VarPoolingForBladeDance) and (not VarWaitingForEssenceBreak)) then
    if Cast(S.ChaosStrike) then return "chaos_strike 146"; end
  end
  -- eye_beam,if=talent.blind_fury.enabled&raid_event.adds.in>cooldown
  if S.EyeBeam:IsReady() and (S.BlindFury:IsAvailable()) then
    if Cast(S.EyeBeam, Settings.Havoc.GCDasOffGCD.EyeBeam, nil, not Target:IsInRange(20)) then return "eye_beam 148"; end
  end
  -- demons_bite,target_if=min:debuff.burning_wound.remains,if=runeforge.burning_wound&debuff.burning_wound.remains<4
  if S.DemonsBite:IsCastable() then
    if Everyone.CastTargetIf(S.DemonsBite, Enemies8y, "min", EvalutateTargetIfFilterDemonsBite202, EvaluateTargetIfDemonsBite204, not Target:IsSpellInRange(S.DemonsBite)) then return "demons_bite 149"; end
  end
  -- demons_bite
  if S.DemonsBite:IsCastable() and IsInMeleeRange() then
    if Cast(S.DemonsBite) then return "demons_bite 150"; end
  end
  -- fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10&talent.demon_blades.enabled
  if S.FelRush:IsCastable() and (not S.Momentum:IsAvailable() and S.DemonBlades:IsAvailable() and ConserveFelRush()) then
    if CastFelRush() then return "fel_rush 152"; end
  end
  -- felblade,if=movement.distance>15|buff.out_of_range.up
  if S.Felblade:IsCastable() and (not IsInMeleeRange()) then
    if Cast(S.Felblade, nil, nil, not Target:IsSpellInRange(S.Felblade)) then return "felblade 154"; end
  end
  -- fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
  if S.FelRush:IsCastable() and (not IsInMeleeRange() and not S.Momentum:IsAvailable() and ConserveFelRush()) then
    if CastFelRush() then return "fel_rush 156"; end
  end
  -- vengeful_retreat,if=movement.distance>15
  if S.VengefulRetreat:IsCastable() and (not IsInMeleeRange()) then
    if Cast(S.VengefulRetreat, Settings.Havoc.OffGCDasOffGCD.VengefulRetreat) then return "vengeful_retreat 158"; end
  end
  -- throw_glaive,if=talent.demon_blades.enabled
  if S.ThrowGlaive:IsCastable() and (S.DemonBlades:IsAvailable()) then
    if Cast(S.ThrowGlaive, Settings.Havoc.GCDasOffGCD.ThrowGlaive, nil, not Target:IsSpellInRange(S.ThrowGlaive)) then return "throw_glaive 160"; end
  end
end

--- ======= ACTION LISTS =======
local function APL()
  if AoEON() then
    Enemies8y = Player:GetEnemiesInMeleeRange(8) -- Multiple Abilities
    Enemies20y = Player:GetEnemiesInMeleeRange(20) -- Eye Beam
    EnemiesCount8 = #Enemies8y
    EnemiesCount20 = #Enemies20y
  else
    EnemiesCount8 = 1
    EnemiesCount20 = 1
  end

  if Everyone.TargetIsValid() then
    -- Precombat
    if not Player:AffectingCombat() then
      local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
    end
    -- Interrupts
    local ShouldReturn = Everyone.Interrupt(10, S.Disrupt, Settings.Commons.OffGCDasOffGCD.Disrupt, StunInterrupts); if ShouldReturn then return ShouldReturn; end
    -- auto_attack
    -- variable,name=blade_dance,value=talent.first_blood.enabled|spell_targets.blade_dance1>=(3-(talent.trail_of_ruin.enabled+buff.metamorphosis.up))|runeforge.chaos_theory&buff.chaos_theory.down
    VarBladeDance = S.FirstBlood:IsAvailable() or EnemiesCount8 >= (3 - (num(S.TrailofRuin:IsAvailable()) + num(Player:BuffUp(S.MetamorphosisBuff)))) or ChaosTheoryEquipped and Player:BuffDown(S.ChaosTheoryBuff)
    -- variable,name=pooling_for_meta,value=!talent.demonic.enabled&cooldown.metamorphosis.remains<6&fury.deficit>30
    VarPoolingForMeta = not S.Demonic:IsAvailable() and S.Metamorphosis:CooldownRemains() < 6 and Player:FuryDeficit() > 30
    -- variable,name=pooling_for_blade_dance,value=variable.blade_dance&(fury<75-talent.first_blood.enabled*20)
    VarPoolingForBladeDance = VarBladeDance and Player:Fury() < 75 - num(S.FirstBlood:IsAvailable()) * 20
    -- variable,name=pooling_for_eye_beam,value=talent.demonic.enabled&!talent.blind_fury.enabled&cooldown.eye_beam.remains<(gcd.max*2)&fury.deficit>20
    VarPoolingForEyeBeam = S.Demonic:IsAvailable() and not S.BlindFury:IsAvailable() and S.EyeBeam:CooldownRemains() < (Player:GCD() * 2) and Player:FuryDeficit() > 20
    -- variable,name=waiting_for_essence_break,value=talent.essence_break.enabled&!variable.pooling_for_blade_dance&!variable.pooling_for_meta&cooldown.essence_break.up
    VarWaitingForEssenceBreak = S.EssenceBreak:IsAvailable() and (not VarPoolingForBladeDance) and (not VarPoolingForMeta) and S.EssenceBreak:CooldownUp()
    -- variable,name=waiting_for_momentum,value=talent.momentum.enabled&!buff.momentum.up
    VarWaitingForMomentum = S.Momentum:IsAvailable() and Player:BuffDown(S.MomentumBuff)
    -- disrupt (Manually moved above variable declarations)
    -- call_action_list,name=cooldown,if=gcd.remains=0
    if CDsON() then
      local ShouldReturn = Cooldown(); if ShouldReturn then return ShouldReturn; end
    end
    -- pick_up_fragment,type=demon,if=demon_soul_fragments>0
    -- pick_up_fragment,if=fury.deficit>=35
    -- TODO: Can't detect when orbs actually spawn, we could possibly show a suggested icon when we DON'T want to pick up souls so people can avoid moving?
    -- throw_glaive,if=buff.fel_bombardment.stack=5&(buff.immolation_aura.up|!buff.metamorphosis.up)
    if S.ThrowGlaive:IsCastable() and (Player:BuffStack(S.FelBombardmentBuff) == 5 and (Player:BuffUp(S.ImmolationAuraBuff) or Player:BuffDown(S.MetamorphosisBuff))) then
      if Cast(S.ThrowGlaive, Settings.Havoc.GCDasOffGCD.ThrowGlaive, nil, not Target:IsSpellInRange(S.ThrowGlaive)) then return "throw_glaive fel_bombardment"; end
    end
    -- call_action_list,name=essence_break,if=talent.essence_break.enabled&(variable.waiting_for_essence_break|debuff.essence_break.up)
    if (S.EssenceBreak:IsAvailable() and (VarWaitingForEssenceBreak or Target:DebuffUp(S.EssenceBreakDebuff))) then
      local ShouldReturn = EssenceBreak(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=demonic,if=talent.demonic.enabled
    if (S.Demonic:IsAvailable()) then
      local ShouldReturn = Demonic(); if ShouldReturn then return ShouldReturn; end
    end
    -- run_action_list,name=normal
    if (true) then
      local ShouldReturn = Normal(); if ShouldReturn then return ShouldReturn; end
    end
  end
end

local function Init()

end

HR.SetAPL(577, APL, Init)
