namespace SKZCommand
{
  enum CMD
  {
    CMD_START,
    CMD_STOP,
    CMD_CANCEL,
    CMD_RESPAWN,
    CMD_PRO,
    CMD_NUB,
    CMD_CP,
    CMD_TP,
    CMD_OBSERVER,
    CMD_MENU,
    CMD_WEAPON,
    CMD_CREATE_START,
    CMD_REMOVE_START,
    CMD_CREATE_STOP,
    CMD_REMOVE_STOP,
    CMD_SAVE_BUTTONS
  }

  dictionary g_Commands = {
    {CMD_RESPAWN,       array<string> = {"respawn", "start"}},
    {CMD_PRO,           array<string> = {"pro", "top15"}},
    {CMD_NUB,           array<string> = {"nub"}},
    {CMD_CP,            array<string> = {"cp"}},
    {CMD_TP,            array<string> = {"tp"}},
    {CMD_OBSERVER,      array<string> = {"observer", "observe", "spectate", "spectator", "spec", "obs"}},
    {CMD_MENU,          array<string> = {"menu"}},
    {CMD_WEAPON,        array<string> = {"weapon"}},
    {CMD_CREATE_START,  array<string> = {"create_start"}},
    {CMD_REMOVE_START,  array<string> = {"remove_start"}},
    {CMD_CREATE_STOP,   array<string> = {"create_stop"}},
    {CMD_REMOVE_STOP,   array<string> = {"remove_stop"}},
    {CMD_SAVE_BUTTONS,  array<string> = {"save_buttons"}},
    {CMD_START,         array<string> = {"start_timer"}},
    {CMD_STOP,          array<string> = {"stop_timer"}}
  };

  CCVar@ g_pLadderBoost = CCVar("mp_ladder_boost", 1.5f, "Ladder boost value", ConCommandFlag::AdminOnly);
  CClientCommand@ g_pLadderBoostCommand = CClientCommand("ladder_boost", "Ladder boost", @LadderBoost);

  CClientCommand@ g_pStartTimer   = CClientCommand("start_timer",   "Start timer",  @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pStopTimer    = CClientCommand("stop_timer",    "Stop timer",   @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pCancelTimer  = CClientCommand("cancel_timer",  "Cancel timer", @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pCreateStart  = CClientCommand("create_start",  "Create start", @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pRemoveStart  = CClientCommand("remove_start",  "Remove start", @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pCreateStop   = CClientCommand("create_stop",   "Create stop",  @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pRemoveStop   = CClientCommand("remove_stop",   "Remove stop",  @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pSaveButtons  = CClientCommand("save_buttons",  "Save buttons", @Console, ConCommandFlag::AdminOnly);

  CClientCommand@ g_pMenu       = CClientCommand("menu",      "Toggle menu",          @Console);
  CClientCommand@ g_pCp         = CClientCommand("cp",        "Save a checkpoint",    @Console);
  CClientCommand@ g_pTp         = CClientCommand("tp",        "Load a checkpoint",    @Console);
  CClientCommand@ g_pPro        = CClientCommand("pro",       "Print pro climbers",   @Console);
  CClientCommand@ g_pTop15      = CClientCommand("top15",     "Print pro climbers",   @Console);
  CClientCommand@ g_pNub        = CClientCommand("nub",       "Print nub climbers",   @Console);
  CClientCommand@ g_pRewpawn    = CClientCommand("respawn",   "Respawn",              @Console);
  CClientCommand@ g_pStart      = CClientCommand("start",     "Respawn",              @Console);
  CClientCommand@ g_pObserver   = CClientCommand("observer",  "Toggle observer mode", @Console);
  CClientCommand@ g_pObserve    = CClientCommand("observe",   "Toggle observer mode", @Console);
  CClientCommand@ g_pOSpectate  = CClientCommand("spectate",  "Toggle observer mode", @Console);
  CClientCommand@ g_pSpectator  = CClientCommand("spectator", "Toggle observer mode", @Console);
  CClientCommand@ g_pSpec       = CClientCommand("spec",      "Toggle observer mode", @Console);
  CClientCommand@ g_pObs        = CClientCommand("obs",       "Toggle observer mode", @Console);
  CClientCommand@ g_pWeapon     = CClientCommand("weapon",    "Give weapon",          @Console);

  array<string> g_CommandPrefixes = {".", "/", "!"};

  bool Execute(CBasePlayer@ pPlayer, string& in szCommand)
  {
    if (g_CommandPrefixes.find(szCommand[0]) == -1)
      return false;

    szCommand = szCommand.SubString(1, szCommand.Length());

    array<string>@ keys = g_Commands.getKeys();

    array<string>@ commands;
    for (uint i = 0; i < keys.length(); ++i)
    {
      const uint uiKey = atoi(keys[i]);
      g_Commands.get(uiKey, @commands);

      if (commands.find(szCommand) == -1)
        continue;

      SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);

      bool bAdmin = g_PlayerFuncs.AdminLevel(@pPlayer) >= ADMIN_YES;

      switch (uiKey)
      {
        case CMD_START:
          if (bAdmin)
            pClient.Start();
          break;
        case CMD_STOP:
          if (bAdmin)
            pClient.Stop();
          break;
        case CMD_CANCEL:
          if (bAdmin)
            pClient.Cancel();
          break;
        case CMD_RESPAWN:
          pClient.Respawn();
          break;
        case CMD_PRO:
          SKZRecord::PrintRecords(@pClient.Player, SKZRecord::RECORD_PRO);
          break;
        case CMD_NUB:
          SKZRecord::PrintRecords(@pClient.Player, SKZRecord::RECORD_NUB);
          break;
        case CMD_CP:
          pClient.Save();
          break;
        case CMD_TP:
          pClient.Load();
          break;
        case CMD_OBSERVER:
          pClient.ToggleObserver();
          break;
        case CMD_MENU:
          pClient.ToggleMenu();
          break;
        case CMD_WEAPON:
          pClient.GiveWeapon();
          break;
        case CMD_CREATE_START:
          if (bAdmin)
            SKZEntity::CreateButton(@pClient.Player, SKZEntity::TIMER_START);
          break;
        case CMD_REMOVE_START:
          if (bAdmin)
            SKZEntity::RemoveButton(SKZEntity::TIMER_START);
          break;
        case CMD_CREATE_STOP:
          if (bAdmin)
            SKZEntity::CreateButton(@pClient.Player, SKZEntity::TIMER_STOP);
          break;
        case CMD_REMOVE_STOP:
          if (bAdmin)
            SKZEntity::RemoveButton(SKZEntity::TIMER_STOP);
          break;
        case CMD_SAVE_BUTTONS:
          if (bAdmin)
            SKZEntity::SaveButtons();
          break;
      }

      return true;
    }

    return false;
  }

  void Console(const CCommand@ pArguments)
  {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    if (pArguments.ArgC() == 1)
      Execute(@pPlayer, pArguments[0]);
  }

  void LadderBoost(const CCommand@ pArguments)
  {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    bool bAdmin = g_PlayerFuncs.AdminLevel(@pPlayer) >= ADMIN_YES;
    if (!bAdmin)
      return;

    if (pArguments.ArgC() > 1)
    {
      float flValue = atof(pArguments[1]);
      g_pLadderBoost.SetFloat(flValue);
    }
    else
      SKZPrint::Console(@pPlayer, "Ladder boost value is %1", g_pLadderBoost.GetFloat());
  }
}