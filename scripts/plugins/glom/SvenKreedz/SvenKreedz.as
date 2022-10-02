const bool DEBUG = true;

const string PLUGIN_NAME    = "SVEN-KREEDZ";
const string PLUGIN_TAG     = "SKZ";
const string PLUGIN_VERSION = "1.0.0";
const string PLUGIN_AUTHOR  = "GLOM";
const string PLUGIN_CONTACT = "https://glom.iki.fi/kz";

#include "Client"
#include "Command"
#include "Entity"
#include "Menu"
#include "Point"
#include "Record"

#include "hooks/ClientHooks"
#include "hooks/PlayerHooks"
#include "hooks/MapHooks"

#include "entities/TriggerSemiclip"
#include "entities/TriggerTimer"
#include "entities/FuncTimer"

#include "utils/Config"
#include "utils/File"
#include "utils/Misc"
#include "utils/Print"
#include "utils/Time"

bool g_bMapActivate = false;
bool g_bMapInit = false;

CScheduledFunction@ g_pLooper;

void PluginInit()
{
  g_Module.ScriptInfo.SetAuthor(PLUGIN_AUTHOR);
  g_Module.ScriptInfo.SetContactInfo(PLUGIN_CONTACT);

  SKZClient::g_Clients.resize(g_Engine.maxClients + 1);

  g_Hooks.RegisterHook(Hooks::Player::ClientPutInServer, @ClientHooks::PutInServer);
  g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientHooks::Say);
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect,	@ClientHooks::Disconnect);

  g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerHooks::Spawn);
  g_Hooks.RegisterHook(Hooks::Player::PlayerSpawn, @PlayerHooks::Spawn);
  g_Hooks.RegisterHook(Hooks::Player::PlayerTakeDamage, @PlayerHooks::TakeDamage);
  g_Hooks.RegisterHook(Hooks::Player::PlayerKilled, @PlayerHooks::Killed);
  g_Hooks.RegisterHook(Hooks::Player::PlayerEnteredObserver, @PlayerHooks::EnteredObserver);
  
  g_Hooks.RegisterHook(Hooks::Game::MapChange, @MapHooks::Change);
}

void MapInit()
{
  if (g_bMapInit)
    return;

  g_bMapInit = true;

  SKZClient::g_Clients.resize(0);
  SKZClient::g_Clients.resize(g_Engine.maxClients + 1);

  SKZRecord::LoadRecords();
  SKZPoint::LoadPoints();

  g_CustomEntityFuncs.RegisterCustomEntity("TriggerSemiclip", "trigger_semiclip");

  g_SoundSystem.PrecacheSound("vox/woop.wav");
  g_Game.PrecacheModel("models/glom/kz/start.mdl");
  g_Game.PrecacheModel("models/glom/kz/stop.mdl");
}

void MapActivate()
{
  if (g_bMapActivate)
    return;

  g_bMapActivate = true;

  if (!SKZEntity::CreateTimers())
    SKZEntity::LoadButtons();

  SKZEntity::FixSpawns();

  if (SKZEntity::HasEntity("func_ladder"))
    g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, PlayerHooks::PostThinkLadder);

  if (SKZEntity::HasEntity("func_water"))
    g_Hooks.RegisterHook(Hooks::Player::PlayerPostThink, PlayerHooks::PostThinkWater);

  if (string(g_Engine.mapname).StartsWith("surf_"))
    g_EngineFuncs.CVarSetFloat("sv_airaccelerate", 100.0f);

  @g_pLooper = g_Scheduler.SetInterval("MainLoop", 0.1f);
}

void MainLoop()
{
  for (int i = 1; i <= g_Engine.maxClients; ++i)
  {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if (pPlayer is null || !pPlayer.IsConnected())
      continue;

    SKZClient::Client @pClient = SKZClient::GetClient(@pPlayer);

    if (pClient.Stopwatch.Started && (pPlayer.pev.movetype == MOVETYPE_NOCLIP || pPlayer.pev.flags & FL_GODMODE != 0 || pPlayer.pev.iuser4 == 69))
    {
      pPlayer.pev.iuser4 = 0;
      pClient.Cancel();
    }

    Observer@ pObserver = pPlayer.GetObserver();
    if (!pObserver.IsObserver())
      continue;

    CBaseEntity@ pTargetEntity = pObserver.GetObserverTarget();
    if (pTargetEntity is null || !pTargetEntity.IsPlayer()) {
      if (pClient.TargetStopwatch !is null)
        pClient.RemoveTarget();
      continue;
    }

    CBasePlayer@ pTargetPlayer = cast<CBasePlayer@>(pTargetEntity);
    SKZClient::Client@ pTarget = SKZClient::GetClient(@pTargetPlayer);

    if (pClient.TargetStopwatch is null || pClient.TargetStopwatch != pTarget.Stopwatch)
      g_Scheduler.SetTimeout(@pClient, "SetTarget", 0.05f, @pTarget);
  }
}