--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...;
-- HeroRotation
local HR = HeroRotation;
-- HeroLib
local HL = HeroLib;
-- File Locals
local GUI = HL.GUI;
local CreateChildPanel = GUI.CreateChildPanel;
local CreatePanelOption = GUI.CreatePanelOption;
local CreateARPanelOption = HR.GUI.CreateARPanelOption;
local CreateARPanelOptions = HR.GUI.CreateARPanelOptions;

--- ============================ CONTENT ============================
-- All settings here should be moved into the GUI someday.
HR.GUISettings.APL.Mage = {
  Commons = {
    UseTrinkets = true,
    UsePotions = true,
    TrinketDisplayStyle = "Suggested",
    CovenantDisplayStyle = "Suggested",
    UseTimeWarp = false,
    -- {Display GCD as OffGCD, ForceReturn}
    GCDasOffGCD = {
      -- Abilities
    },
    -- {Display OffGCD as OffGCD, ForceReturn}
    OffGCDasOffGCD = {
      -- Racials
      Racials = true,
      -- Abilities
      TimeWarp = true,
      Counterspell = true,
    }
  },
  Frost = {
    MirrorImagesBeforePull = false,
    MovingRotation = false,
    UseTemporalWarp = true,
    -- {Display GCD as OffGCD, ForceReturn}
    GCDasOffGCD = {
      -- Abilities
      RuneOfPower = true,
      IcyVeins = true,
      MirrorImage = true,
      FrozenOrb = true,
    },
    -- {Display OffGCD as OffGCD, ForceReturn}
    OffGCDasOffGCD = {
      -- Abilities
      IceFloes = true,
    }
  },
  Fire = {
    DisableCombustion = false,
    -- {Display GCD as OffGCD, ForceReturn}
    GCDasOffGCD = {
      -- Abilities
      RuneOfPower = true,
    },
    -- {Display OffGCD as OffGCD, ForceReturn}
    OffGCDasOffGCD = {
      -- Abilities
      Combustion = true,
    }
  },
  Arcane = {
    UseManaGem = true,
    AMSpamRotation = false,
    StayDistance = false,
    -- {Display GCD as OffGCD, ForceReturn}
    GCDasOffGCD = {
      -- Abilities
      RuneOfPower = true,
      ArcanePower = true,
      MirrorImage = true,
      TouchoftheMagi = true,
      Evocation = true,
    },
    -- {Display OffGCD as OffGCD, ForceReturn}
    OffGCDasOffGCD = {
      -- Abilities
      PresenceofMind = true,
    }
  }
};

HR.GUI.LoadSettingsRecursively(HR.GUISettings);

-- Child Panels
local ARPanel = HR.GUI.Panel;
local CP_Mage = CreateChildPanel(ARPanel, "Mage");
local CP_Arcane = CreateChildPanel(CP_Mage, "Arcane");
local CP_Fire = CreateChildPanel(CP_Mage, "Fire");
local CP_Frost = CreateChildPanel(CP_Mage, "Frost");

-- Controls
-- Mage
CreateARPanelOptions(CP_Mage, "APL.Mage.Commons");
--CreatePanelOption("CheckButton", CP_Mage, "APL.Mage.Commons.UseTimeWarp", "Use Time Warp (NYI)", "Enable this if you want the addon to show you when to use Time Warp.");
CreatePanelOption("CheckButton", CP_Mage, "APL.Mage.Commons.UsePotions", "Show Potions", "Enable this if you want the addon to show you when to use Potions.");
CreatePanelOption("CheckButton", CP_Mage, "APL.Mage.Commons.UseTrinkets", "Use Trinkets", "Use Trinkets as part of the rotation");
CreatePanelOption("Dropdown", CP_Mage, "APL.Mage.Commons.TrinketDisplayStyle", {"Main Icon", "Suggested", "Cooldown"}, "Trinket Display Style", "Define which icon display style to use for Trinkets.");
CreatePanelOption("Dropdown", CP_Mage, "APL.Mage.Commons.CovenantDisplayStyle", {"Main Icon", "Suggested", "Cooldown"}, "Covenant Display Style", "Define which icon display style to use for active Shadowlands Covenant Abilities.");
-- Arcane
CreatePanelOption("CheckButton", CP_Arcane, "APL.Mage.Arcane.AMSpamRotation", "Use AM spam rotation", "Enable the use of the Arcane Missile Spam rotation.");
CreatePanelOption("CheckButton", CP_Arcane, "APL.Mage.Arcane.MirrorImagesBeforePull", "Use Mirror Image before combat", "Enable the use of Mirror image before starting combat (very low dps).");
CreatePanelOption("CheckButton", CP_Arcane, "APL.Mage.Arcane.StayDistance", "Stay at distance", "Only use Arcane Explosion if in range or on the left icon.");
CreateARPanelOptions(CP_Arcane, "APL.Mage.Arcane");
--CreatePanelOption("CheckButton", CP_Arcane, "APL.Mage.Arcane.UseManaGem", "Use Mana Gem", "Use mana gem during combat.");
-- Fire
CreatePanelOption("CheckButton", CP_Fire, "APL.Mage.Fire.DisableCombustion", "Disable Combustion", "Disable the usage of Combustion within the Fire rotation.");
CreateARPanelOptions(CP_Fire, "APL.Mage.Fire");
-- Frost
CreatePanelOption("CheckButton", CP_Frost, "APL.Mage.Frost.MirrorImagesBeforePull", "Use Mirror Image before combat", "Enable the use of Mirror image before starting combat (very low dps).");
CreatePanelOption("CheckButton", CP_Frost, "APL.Mage.Frost.MovingRotation", "Disable cast abilities when moving", "Don't show abilities where a ca&st is needed (makes the rotation a bit clunky with small steps).");
CreatePanelOption("CheckButton", CP_Frost, "APL.Mage.Frost.UseTemporalWarp", "Suggest Time Warp with Temporal Warp legendary", "Show time warp ability when using the Temporal Warp legendary");
CreateARPanelOptions(CP_Frost, "APL.Mage.Frost");
