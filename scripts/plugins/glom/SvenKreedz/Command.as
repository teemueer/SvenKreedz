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
    CMD_WEAPON
  }

  dictionary g_Commands = {
    {CMD_START,     array<string> = {"t_start"}},
    {CMD_STOP,      array<string> = {"t_stop"}},
    {CMD_CANCEL,    array<string> = {"t_cancel"}},
    {CMD_RESPAWN,   array<string> = {"respawn"}},
    {CMD_PRO,       array<string> = {"pro"}},
    {CMD_NUB,       array<string> = {"nub"}},
    {CMD_CP,        array<string> = {"cp"}},
    {CMD_TP,        array<string> = {"tp"}},
    {CMD_OBSERVER,  array<string> = {"observer"}},
    {CMD_MENU,      array<string> = {"menu"}},
    {CMD_WEAPON,    array<string> = {"weapon"}}
  };

  CCVar@ g_pLadderBoost = CCVar("ladder_boost", 1.5f, "Ladder boost value", ConCommandFlag::AdminOnly);

  CClientCommand@ g_pStart    = CClientCommand("t_start",   "Start timer",          @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pStop     = CClientCommand("t_stop",    "Stop timer",           @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pCancel   = CClientCommand("t_cancel",  "Stop timer",           @Console, ConCommandFlag::AdminOnly);
  CClientCommand@ g_pRewpawn  = CClientCommand("respawn",   "Respawn",              @Console);
  CClientCommand@ g_pPro      = CClientCommand("pro",       "Print pro climbers",   @Console);
  CClientCommand@ g_pNub      = CClientCommand("nub",       "Print nub climbers",   @Console);
  CClientCommand@ g_pCp       = CClientCommand("cp",        "Save a checkpoint",    @Console);
  CClientCommand@ g_pTp       = CClientCommand("tp",        "Load a checkpoint",    @Console);
  CClientCommand@ g_pObserver = CClientCommand("observer",  "Toggle observer mode", @Console);
  CClientCommand@ g_pMenu     = CClientCommand("menu",      "Toggle menu",          @Console);
  CClientCommand@ g_pWeapon   = CClientCommand("weapon",    "Give weapon",          @Console);

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

      bool bAdmin = g_PlayerFuncs.AdminLevel(@pPlayer) >= ADMIN_YES;
      SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);

      switch (uiKey)
      {
        case CMD_START:
          pClient.Start();
          break;
        case CMD_STOP:
          pClient.Stop();
          break;
        case CMD_CANCEL:
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
      }

      return true;
    }

    return false;
  }

  void Console(const CCommand@ pArguments)
  {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    if (pArguments.ArgC() == 1)
      Execute(pPlayer, pArguments[0]);
  }

  void LadderBoost(const CCommand@ pArguments)
  {
    CBasePlayer@ pPlayer = g_ConCommandSystem.GetCurrentPlayer();

    if (pArguments.ArgC() > 1)
    {
      float flValue = atof(pArguments[1]);
      g_pLadderBoost.SetFloat(flValue);
    }
    else
      SKZPrint::Console(@pPlayer, "Ladder boost value is %1", g_pLadderBoost.GetFloat());
  }
}