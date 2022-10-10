#include "Stopwatch"
#include "Checkpoint"

namespace SKZClient
{
  array<Client@> g_Clients;

  final class Client
  {
    private EHandle m_hPlayer;
    private EHandle m_hSemiclip;

    private bool m_bSemiclip;

    private SKZStopwatch::Stopwatch@ m_pStopwatch;
    private SKZStopwatch::Stopwatch@ m_pTargetStopwatch;

    private uint m_uiStartTime;
    private uint m_uiCp;
    private uint m_uiTp;

    private SKZCheckpoint::Checkpoint@ m_pCheckpoint;

    private SKZRecord::Record@ m_pRecord;

    private SKZMenu::Menu@ m_pMenu;
    private bool m_bMenuOpen;

    CBasePlayer@ Player
    {
      get const { return cast<CBasePlayer@>(m_hPlayer.GetEntity()); }
      set { m_hPlayer = EHandle(@value); }
    }

    CBaseEntity@ Semiclip
    {
      get const { return cast<CBaseEntity@>(m_hSemiclip.GetEntity()); }
      set { m_hSemiclip = EHandle(@value); }
    }

    bool IsSemiclipped
    {
      get const { return m_bSemiclip; }
    }

    string Name
    {
      get const {
        CBasePlayer@ pPlayer = @this.Player;
        if (pPlayer is null)
          return "";

        return this.Player.pev.netname;
      }
    }

    string SteamId
    {
      get const
      {
        CBasePlayer@ pPlayer = @this.Player;
        if (pPlayer is null)
          return "";

        const string szSteamId = g_EngineFuncs.GetPlayerAuthId(pPlayer.edict());
        return szSteamId == "BOT" ? this.Name : szSteamId;
      }
    }

    float Time
    {
      get const
      {
        return this.Stopwatch.Started
          ? (SKZTime::Now() - m_uiStartTime) / 1000.0
          : this.Stopwatch.Time;
      }
    }

    bool MenuOpen
    {
      get const { return m_bMenuOpen; }
      set { m_bMenuOpen = value; }
    }

    bool IsBot
    {
      get const {
        CBasePlayer@ pPlayer = @this.Player;
        if (pPlayer is null)
          return false;

        return pPlayer.pev.flags & FL_FAKECLIENT != 0;
      }
    }
    
    SKZStopwatch::Stopwatch@ Stopwatch
    {
      get const { return m_pStopwatch; }
      set { @m_pStopwatch = @value; }
    }

    SKZStopwatch::Stopwatch@ TargetStopwatch
    {
      get const { return m_pTargetStopwatch; }
      set { @m_pTargetStopwatch = @value; }
    }

    SKZCheckpoint::Checkpoint@ Checkpoint
    {
      get const { return m_pCheckpoint; }
      set { @m_pCheckpoint = @value; }
    }

    SKZRecord::Record@ Record
    {
      get const { return m_pRecord; }
      set { @m_pRecord = @value; }
    }

    Client(CBasePlayer@ pPlayer)
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Client()\n", pPlayer.pev.netname);

      @this.Player = @pPlayer;

      m_bSemiclip = false;

      @this.Stopwatch = SKZStopwatch::Stopwatch();

      m_uiStartTime = 0;
      m_uiCp = 0;
      m_uiTp = 0;

      @this.Checkpoint = SKZCheckpoint::Checkpoint();

      @m_pMenu = SKZMenu::Menu();
      this.MenuOpen = false;
    }

    ~Client()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] ~Client()\n", this.Name);

      this.RemoveSemiclip();

      m_hPlayer = null;
      m_hSemiclip = null;
    }

    void CreateSemiclip()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] CreateSemiclip()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      @this.Semiclip = g_EntityFuncs.Create("trigger_semiclip", pPlayer.pev.origin, g_vecZero, true);
      @this.Semiclip.pev.owner = @pPlayer.edict();
      g_EntityFuncs.DispatchSpawn(@this.Semiclip.edict());
    }

    void RemoveSemiclip()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] RemoveSemiclip()\n", this.Name);
      
      if (m_hSemiclip.IsValid())
			  g_EntityFuncs.Remove(this.Semiclip);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      pPlayer.pev.groupinfo = 0;
    }

    void ToggleSemiclip()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] ToggleSemiclip\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      this.IsSemiclipped
        ? pPlayer.pev.groupinfo = 0
        : pPlayer.pev.groupinfo = 1 << (pPlayer.entindex() & 31);

      m_bSemiclip = !m_bSemiclip;
    }

    void Start()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Start()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      m_uiStartTime = SKZTime::Now();
      m_uiCp = 0;
      m_uiTp = 0;

      pPlayer.pev.iuser4 = 0;

      this.Stopwatch.Start(@pPlayer, m_uiStartTime);
    }

    void Stop()
    {
      if (!this.Stopwatch.Started)
        return;

      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Stop()\n", this.Name);

      uint uiStopTime = SKZTime::Now();
      uint uiTime = uiStopTime - m_uiStartTime;

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      @this.Record = SKZRecord::Record(this.Name, this.SteamId, uiTime, m_uiCp, m_uiTp);
      const bool bNewRecord = SKZRecord::UpdateRecords(@this.Record);

      this.Stopwatch.Stop(@pPlayer, uiTime, bNewRecord);
    }

    void Cancel()
    {
      if (!this.Stopwatch.Started)
        return;

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Cancel()\n", this.Name);

      uint uiStopTime = SKZTime::Now();

      this.Stopwatch.Cancel(@pPlayer, uiStopTime - m_uiStartTime);
    }

    void Respawn(const bool bIsBot = false)
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Respawn()\n", this.Name);

      this.Cancel();

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      g_PlayerFuncs.RespawnPlayer(@pPlayer, true, true);

      //if (bIsBot)
      //  pPlayer.pev.origin = Vector(99999, 99999, 99999);
    }

    void Save()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Save()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      if (this.Checkpoint.Save(@pPlayer, m_uiStartTime))
        m_uiCp++;

      g_Game.AlertMessage(at_console, "[%1] cp: %2 tp: %3\n", this.Name, m_uiCp, m_uiTp);
    }

    void Load()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Load()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      if (this.Checkpoint.Load(@pPlayer) && this.Stopwatch.Started)
      {
        if (m_uiCp == 0)
          this.Cancel();
        else if (m_uiTp++ == 0)
          this.Stopwatch.SetNubRun(@pPlayer, this.Time);
      }
    }

    void ToggleObserver()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] ToggleObserver()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      Observer@ pObserver = pPlayer.GetObserver();

      if (pObserver.IsObserver())
      {
        SKZPrint::Notify("%1 exited observer mode", this.Name);
        g_PlayerFuncs.RespawnPlayer(@pPlayer, true, true);
        this.RemoveTarget();
      }
      else
      {
        SKZPrint::Notify("%1 entered observer mode", this.Name);
        this.Cancel();

        pObserver.StartObserver(pPlayer.pev.origin, pPlayer.pev.v_angle, true);
        if (pObserver.HasCorpse())
          pObserver.RemoveDeadBody();

        g_Scheduler.SetTimeout(@this, "DelayRespawn", 0.1f);
      }

      if (this.MenuOpen)
        g_Scheduler.SetTimeout(@this, "ToggleMenu", 0.1f);
    }

    void DelayRespawn()
    {
      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      pPlayer.m_flRespawnDelayTime = 10000 - g_EngineFuncs.CVarGetFloat("mp_respawndelay");
    }

    void SetTarget(Client@ pTarget)
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] SetTarget()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      @this.TargetStopwatch = SKZStopwatch::Stopwatch(@pTarget.Stopwatch);
      this.TargetStopwatch.Show(@pPlayer, pTarget.Time);
    }

    void RemoveTarget()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] RemoveTarget()\n", this.Name);

      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      @this.TargetStopwatch = null;

      this.Stopwatch.Show(@pPlayer, this.Time);
    }

    void ToggleMenu()
    {
      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      m_pMenu.Open(@pPlayer);
    }

    void GiveWeapon()
    {
      CBasePlayer@ pPlayer = @this.Player;
      if (pPlayer is null)
        return;

      if (!pPlayer.IsAlive())
      {
        SKZPrint::Notify(@pPlayer, "Can't give weapon while dead.");
        return;
      }

      pPlayer.SetMaxAmmo("357", 9999);
      pPlayer.GiveNamedItem("weapon_eagle");
      pPlayer.GiveAmmo(9999, "357", 9999);
    }
  }

  Client@ GetClient(CBasePlayer@ pPlayer)
  {
    if (pPlayer is null)
      return null;

    const uint uiIndex = pPlayer.entindex();
    Client@ pClient = g_Clients[uiIndex];

    if (pClient is null)
      @g_Clients[uiIndex] = Client(@pPlayer);

    return @g_Clients[uiIndex];
  }
}