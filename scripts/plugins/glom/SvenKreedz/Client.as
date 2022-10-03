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
      get const { return this.Player.pev.netname; }
    }

    string SteamId
    {
      get const
      {
        const string szSteamId = g_EngineFuncs.GetPlayerAuthId(this.Player.edict());
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
      get const { return this.Player.pev.flags & FL_FAKECLIENT != 0; }
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

      @this.Semiclip = g_EntityFuncs.Create("trigger_semiclip", this.Player.pev.origin, g_vecZero, true);
      @this.Semiclip.pev.owner = @Player.edict();
      g_EntityFuncs.DispatchSpawn(@this.Semiclip.edict());
    }

    void RemoveSemiclip()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] RemoveSemiclip()\n", this.Name);
      
      if (m_hSemiclip.IsValid())
			  g_EntityFuncs.Remove(this.Semiclip);
    }

    void ToggleSemiclip()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] ToggleSemiclip\n", this.Name);

      this.IsSemiclipped
        ? this.Player.pev.groupinfo = 0
        : this.Player.pev.groupinfo = 1 << (this.Player.entindex() & 31);

      m_bSemiclip = !m_bSemiclip;
    }

    void Start()
    {
      //if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Start()\n", this.Name);

      m_uiStartTime = SKZTime::Now();
      m_uiCp = 0;
      m_uiTp = 0;

      this.Player.pev.iuser4 = 0;

      this.Stopwatch.Start(@this.Player, m_uiStartTime);
    }

    void Stop()
    {
      if (!this.Stopwatch.Started)
        return;

      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Stop()\n", this.Name);

      uint uiStopTime = SKZTime::Now();
      uint uiTime = uiStopTime - m_uiStartTime;

      this.Stopwatch.Stop(@this.Player, uiTime);

      @this.Record = SKZRecord::Record(this.Name, this.SteamId, uiTime, m_uiCp, m_uiTp);
      SKZRecord::UpdateRecords(@this.Record);
    }

    void Cancel()
    {
      if (!this.Stopwatch.Started)
        return;

      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Cancel()\n", this.Name);

      uint uiStopTime = SKZTime::Now();

      this.Stopwatch.Cancel(@this.Player, uiStopTime - m_uiStartTime);
    }

    void Respawn(const bool bIsBot = false)
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Respawn()\n", this.Name);

      this.Cancel();
      g_PlayerFuncs.RespawnPlayer(@this.Player, true, true);

      if (bIsBot)
        this.Player.pev.origin = Vector(99999, 99999, 99999);
    }

    void Save()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Save()\n", this.Name);

      if (this.Checkpoint.Save(@this.Player, m_uiStartTime))
        m_uiCp++;
    }

    void Load()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] Load()\n", this.Name);

      if (this.Checkpoint.Load(@this.Player) && this.Stopwatch.Started)
      {
        if (m_uiCp == 0)
          this.Cancel();
        else if (m_uiTp++ == 0)
          this.Stopwatch.SetNubRun(@this.Player, this.Time);
      }
    }

    void ToggleObserver()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] ToggleObserver()\n", this.Name);

      Observer@ pObserver = this.Player.GetObserver();

      if (pObserver.IsObserver())
      {
        SKZPrint::Notify("%1 exited observer mode", this.Name);
        g_PlayerFuncs.RespawnPlayer(@this.Player, true, true);
        this.RemoveTarget();
      }
      else
      {
        SKZPrint::Notify("%1 entered observer mode", this.Name);
        this.Cancel();

        pObserver.StartObserver(this.Player.pev.origin, this.Player.pev.v_angle, true);
        if (pObserver.HasCorpse())
          pObserver.RemoveDeadBody();

        g_Scheduler.SetTimeout(@this, "DelayRespawn", 0.1f);
      }

      if (this.MenuOpen)
        g_Scheduler.SetTimeout(@this, "ToggleMenu", 0.1f);
    }

    void DelayRespawn()
    {
      this.Player.m_flRespawnDelayTime = 10000 - g_EngineFuncs.CVarGetFloat("mp_respawndelay");
    }

    void SetTarget(Client@ pTarget)
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] SetTarget()\n", this.Name);

      @this.TargetStopwatch = SKZStopwatch::Stopwatch(@pTarget.Stopwatch);
      this.TargetStopwatch.Show(@this.Player, pTarget.Time);
    }

    void RemoveTarget()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] RemoveTarget()\n", this.Name);

      @this.TargetStopwatch = null;

      this.Stopwatch.Show(@this.Player, this.Time);
    }

    void ToggleMenu()
    {
      m_pMenu.Open(@this.Player);
    }

    void GiveWeapon()
    {
      if (!this.Player.IsAlive())
      {
        SKZPrint::Notify(@this.Player, "Can't give weapon while dead.");
        return;
      }

      this.Player.SetMaxAmmo("357", 9999);
      this.Player.GiveNamedItem("weapon_eagle");
      this.Player.GiveAmmo(9999, "357", 9999);
    }
  }

  Client@ GetClient(CBasePlayer@ pPlayer)
  {
    const uint uiIndex = pPlayer.entindex();
    Client@ pClient = g_Clients[uiIndex];

    if (pClient is null)
      @g_Clients[uiIndex] = Client(@pPlayer);

    return @g_Clients[uiIndex];
  }
}