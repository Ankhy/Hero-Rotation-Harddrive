--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, addonTable = ...;
-- HeroDBC
local DBC = HeroDBC.DBC
-- HeroLib
local HL         = HeroLib
local Cache      = HeroCache
local Unit       = HL.Unit
local Player     = Unit.Player
local Target     = Unit.Target
local Pet        = Unit.Pet
local Spell      = HL.Spell
local MultiSpell = HL.MultiSpell
local Item       = HL.Item
-- HeroRotation
local HR         = HeroRotation

--- ============================ CONTENT ============================

-- Spell
if not Spell.Monk then Spell.Monk = {}; end
Spell.Monk.Windwalker = {

  -- Racials
  AncestralCall                         = Spell(274738),
  ArcaneTorrent                         = Spell(25046),
  BagOfTricks                           = Spell(312411),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Bloodlust                             = Spell(2825),
  GiftoftheNaaru                        = Spell(59547),
  Fireblood                             = Spell(265221),
  LightsJudgment                        = Spell(255647),
  QuakingPalm                           = Spell(107079),
  Shadowmeld                            = Spell(58984),

  -- Abilities
  BlackoutKick                          = Spell(100784),
  BlackoutKickBuff                      = Spell(116768),
  CracklingJadeLightning                = Spell(117952),
  ExpelHarm                             = Spell(322101),
  FistsOfFury                           = Spell(113656),
  FlyingSerpentKick                     = Spell(101545),
  FlyingSerpentKickActionBarReplacement = Spell(115057),
  InvokeXuenTheWhiteTiger               = Spell(123904),
  RisingSunKick                         = Spell(107428),
  SpinningCraneKick                     = Spell(101546),
  StormEarthAndFire                     = Spell(137639),
  StormEarthAndFireBuff                 = Spell(137639),
  TigerPalm                             = Spell(100780),
  TouchOfDeath                          = Spell(322109),

  -- Debuffs
  MarkOfTheCraneDebuff                  = Spell(228287),

  -- Talents
  Celerity                              = Spell(115173),
  ChiWave                               = Spell(115098),
  ChiBurst                              = Spell(123986),
  DanceOfChijiBuff                      = Spell(325202),
  EyeOfTheTiger                         = Spell(196607),
  FistOfTheWhiteTiger                   = Spell(261947),
  GoodKarma                             = Spell(280195),
  HitCombo                              = Spell(196740),
  HitComboBuff                          = Spell(196741),
  InnerStrengthBuff                     = Spell(261769),
  RushingJadeWind                       = Spell(261715),
  RushingJadeWindBuff                   = Spell(261715),
  WhirlingDragonPunch                   = Spell(152175),
  WhirlingDragonPunchBuff               = Spell(196742),
  Serenity                              = Spell(152173),
  SerenityBuff                          = Spell(152173),
  SpiritualFocus                        = Spell(280197),

  -- Defensive
  DampenHarm                            = Spell(122278), -- Talent
  DampenHarmBuff                        = Spell(122278),
  DiffuseMagic                          = Spell(122783), -- Talent
  FortifyingBrew                        = Spell(243435),
  TouchOfKarma                          = Spell(122470),

  -- Utility
  ChiTorpedo                            = Spell(115008), -- Talent
  Detox                                 = Spell(218164),
  Disable                               = Spell(116095),
  EnergizingElixir                      = Spell(115288), -- Talent
  HealingElixir                         = Spell(122281), -- Talent
  LegSweep                              = Spell(119381), -- Talent
  Paralysis                             = Spell(115078),
  Provoke                               = Spell(115546),
  RingOfPeace                           = Spell(116844), -- Talent
  Roll                                  = Spell(109132),
  SpearHandStrike                       = Spell(116705),
  TigersLust                            = Spell(116841), -- Talent
  TigerTailSweep                        = Spell(264348),
  Transcendence                         = Spell(101643),
  TranscendenceTransfer                 = Spell(119996),
  Vivify                                = Spell(116670),

  -- Trinket Debuffs
  RazorCoralDebuff                      = Spell(303568),

  -- PvP Abilities

  -- Shadowland Covenant

  -- Shadowlands Legendary
  ChiEnergyBuff                         = Spell(337571),
  RecentlyRushingTigerPalm              = Spell(337340),
  RecentlyRushingTigerPalm              = Spell(337341),

  -- Misc
  PoolEnergy                            = Spell(999910)
}

Spell.Monk.Brewmaster = {

  -- Racials
  AncestralCall                = Spell(274738),
  ArcaneTorrent                = Spell(50613),
  BagOfTricks                  = Spell(312411),
  Berserking                   = Spell(26297),
  BloodFury                    = Spell(20572),
  Fireblood                    = Spell(265221),
  LightsJudgment               = Spell(255647),

  -- Abilities
  BlackoutKick                 = Spell(205523),
  BreathOfFire                 = Spell(115181),
  Clash                        = Spell(324312),
  CracklingJadeLightning       = Spell(117952),
  ExpelHarm                    = Spell(322101),
  InvokeNiuzaoTheBlackOx       = Spell(132578),
  KegSmash                     = Spell(121253),
  SpinningCraneKick            = Spell(322729),
  TigerPalm                    = Spell(100780),
  TouchOfDeath                 = Spell(322109),

  -- Debuffs
  BreathOfFireDotDebuff        = Spell(123725),

  -- Talents
  BlackoutCombo                = Spell(196736),
  BlackoutComboBuff            = Spell(228563),
  BlackOxBrew                  = Spell(115399),
  BobAndWeave                  = Spell(280515),
  Celerity                     = Spell(115173),
  CelestialFlames              = Spell(325177),
  ChiBurst                     = Spell(123986),
  ChiWave                      = Spell(115098),
  EyeOfTheTiger                = Spell(196607),
  ExplodingKeg                 = Spell(214326),
  LightBrewing                 = Spell(325093),
  RushingJadeWind              = Spell(116847),
  SpecialDelivery              = Spell(196730),
  Spitfire                     = Spell(242580),
  SummonBlackOxStatue          = Spell(115315),

  -- Defensive
  CelestialBrew                = Spell(322507),
  DampenHarm                   = Spell(122278), --Talent
  DampenHarmBuff               = Spell(122278),
  ElusiveBrawlerBuff           = Spell(195630),
  FortifyingBrew               = Spell(115203),
  FortifyingBrewBuff           = Spell(115203),
  HighTolerance                = Spell(196737), -- Talent
  PurifyingBrew                = Spell(119582),
  Shuffle                      = Spell(215479),

  -- Utility
  ChiTorpedo                   = Spell(115008), -- Talentn
  Detox                        = Spell(218164),
  Disable                      = Spell(116095),
  LegSweep                     = Spell(119381), -- Talent
  Paralysis                    = Spell(115078),
  Provoke                      = Spell(115546),
  RingOfPeace                  = Spell(116844), -- Talent
  Roll                         = Spell(109132),
  SpearHandStrike              = Spell(116705),
  TigersLust                   = Spell(116841), -- Talent
  TigerTailSweep               = Spell(264348), -- Talent
  Transcendence                = Spell(101643),
  TranscendenceTransfer        = Spell(119996),
  Vivify                       = Spell(116670),

  -- Trinket Debuffs
  RazorCoralDebuff             = Spell(303568),
  ConductiveInkDebuff          = Spell(302565),

  -- PvP Abilities

  -- Stagger Levels
  HeavyStagger                 = Spell(124273),
  ModerateStagger              = Spell(124274),
  LightStagger                 = Spell(124275),

  -- Misc
  PoolEnergy                   = Spell(999910)
}

-- Items
if not Item.Monk then Item.Monk = {}; end
Item.Monk.Windwalker = {
  PotionofUnbridledFury                = Item(169299),
  GalecallersBoon                      = Item(159614, {13, 14}),
  LustrousGoldenPlumage                = Item(159617, {13, 14}),
  PocketsizedComputationDevice         = Item(167555, {13, 14}),
  AshvanesRazorCoral                   = Item(169311, {13, 14}),
  AzsharasFontofPower                  = Item(169314, {13, 14}),
  RemoteGuidanceDevice                 = Item(169769, {13, 14}),
  WrithingSegmentofDrestagath          = Item(173946, {13, 14}),
  -- For VarTodOnUse
  DribblingInkpod                      = Item(169319, {13, 14}),
  -- Gladiator Badges/Medallions
  DreadGladiatorsMedallion             = Item(161674, {13, 14}),
  DreadCombatantsInsignia              = Item(161676, {13, 14}),
  DreadCombatantsMedallion             = Item(161811, {13, 14}),
  DreadGladiatorsBadge                 = Item(161902, {13, 14}),
  DreadAspirantsMedallion              = Item(162897, {13, 14}),
  DreadAspirantsBadge                  = Item(162966, {13, 14}),
  SinisterGladiatorsMedallion          = Item(165055, {13, 14}),
  SinisterGladiatorsBadge              = Item(165058, {13, 14}),
  SinisterAspirantsMedallion           = Item(165220, {13, 14}),
  SinisterAspirantsBadge               = Item(165223, {13, 14}),
  NotoriousGladiatorsMedallion         = Item(167377, {13, 14}),
  NotoriousGladiatorsBadge             = Item(167380, {13, 14}),
  NotoriousAspirantsMedallion          = Item(167525, {13, 14}),
  NotoriousAspirantsBadge              = Item(167528, {13, 14})
}

Item.Monk.Brewmaster = {
  -- BfA
  PotionofUnbridledFury        = Item(169299),
  PocketsizedComputationDevice = Item(167555, {13, 14}),
  AshvanesRazorCoral           = Item(169311, {13, 14}),
}
