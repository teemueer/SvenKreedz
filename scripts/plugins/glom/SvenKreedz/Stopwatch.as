namespace SKZStopwatch
{
  RGBA RGBA_START     = RGBA_SVENCOOP;
  RGBA RGBA_RECORD    = RGBA_GREEN;
  RGBA RGBA_NO_RECORD = RGBA_YELLOW;
  RGBA RGBA_CANCEL    = RGBA_RED;
  RGBA RGBA_NUB       = RGBA_ORANGE;

  final class Stopwatch
  {
    private uint m_uiStartTime;
    private HUDNumDisplayParams m_Params;

    uint StartTime
    {
      get const { return m_uiStartTime; }
      set { m_uiStartTime = value; }
    }

    bool Started
    {
      get const { return m_Params.flags & HUD_TIME_FREEZE == 0; }
    }

    float Time
    {
      get const { return m_Params.value; }
      set { m_Params.value = value; }
    }

    HUDNumDisplayParams Params
    {
      get const { return m_Params; }
      set { m_Params = value; }
    }

    Stopwatch()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "Stopwatch()\n");

      m_uiStartTime = 0;

      m_Params.x = 0;
      m_Params.y = 0.06;
      m_Params.spritename = "stopwatch";
      m_Params.flags = HUD_ELEM_SCR_CENTER_X
        | HUD_ELEM_DEFAULT_ALPHA
        | HUD_TIME_HOURS
        | HUD_TIME_MINUTES
        | HUD_TIME_SECONDS
        | HUD_TIME_MILLISECONDS
        | HUD_TIME_FREEZE;
    }

    Stopwatch(Stopwatch@ pStopwatch)
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "Copy()\n");
      this.StartTime = pStopwatch.StartTime;
      this.Params = pStopwatch.Params;
    }

    ~Stopwatch()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "~Stopwatch()\n");
    }

    void Start(CBasePlayer@ pPlayer, const uint uiStartTime)
    {
      this.StartTime = uiStartTime;

      m_Params.flags &= ~HUD_TIME_FREEZE;
      m_Params.value = 0;
      m_Params.color1 = RGBA_START;

      g_PlayerFuncs.HudTimeDisplay(@pPlayer, m_Params);
      SKZPrint::Notify(@pPlayer, "Timer started");
    }

    void Stop(CBasePlayer@ pPlayer, const uint uiTime, const bool bNewRecord)
    {
      m_Params.flags |= HUD_TIME_FREEZE;
      m_Params.value = uiTime / 1000.0;
      m_Params.color1 = bNewRecord ? RGBA_RECORD : RGBA_NO_RECORD;

      g_PlayerFuncs.HudTimeDisplay(@pPlayer, m_Params);
      SKZPrint::Notify(@pPlayer, "Timer stopped");
    }

    void Cancel(CBasePlayer@ pPlayer, const uint uiTime)
    {
      m_Params.flags |= HUD_TIME_FREEZE;
      m_Params.value = uiTime / 1000.0;
      m_Params.color1 = RGBA_CANCEL;

      g_PlayerFuncs.HudTimeDisplay(@pPlayer, m_Params);
      SKZPrint::Notify(@pPlayer, "Timer cancelled");
    }

    void SetNubRun(CBasePlayer@ pPlayer, const float flTime)
    {
      m_Params.value = flTime;
      m_Params.color1 = RGBA_NUB;

      g_PlayerFuncs.HudTimeDisplay(@pPlayer, m_Params);
    }

    void Show(CBasePlayer@ pPlayer, const float flTime)
    {
      m_Params.value = flTime;

      g_PlayerFuncs.HudTimeDisplay(@pPlayer, m_Params);
    }

    bool opEquals(Stopwatch@ pStopwatch)
    {
      return this.StartTime == pStopwatch.StartTime && this.Params.flags == pStopwatch.Params.flags;
    }
  }

}