namespace SKZEntity
{
  enum TIMER {
    TIMER_START,
    TIMER_STOP
  }

  array<CBaseEntity@> g_Buttons;

  bool CreateTimers()
  {
    g_CustomEntityFuncs.RegisterCustomEntity("TriggerTimer", "trigger_timer");

    bool bStart = false;
    bool bStop = false;

    array<string> allowedClassnames = {"func_button", "trigger_multiple"};
    const string szFakeMaster = "__glom_master";

    dictionary timerTargets = {
      {TIMER_START, SKZFile::ReadLines(SKZConfig::szStartTargets)},
      {TIMER_STOP, SKZFile::ReadLines(SKZConfig::szStopTargets)}
    };

    array<string>@ keys = timerTargets.getKeys();

    array<string>@ targets;
    for (uint i = 0; i < keys.length(); ++i)
    {
      const uint uiKey = atoi(keys[i]);
      timerTargets.get(uiKey, @targets);

      for (uint j = 0; j < targets.length(); ++j)
      {
        CBaseEntity@ pEntity;
        while (true)
        {
          @pEntity = g_EntityFuncs.FindEntityByString(@pEntity, "target", targets[j]);
          if (pEntity is null)
            break;

          if (allowedClassnames.find(pEntity.GetClassname()) == -1)
            continue;

          if (!bStart && uiKey == TIMER_START)
            bStart = true;
          else if (!bStop && uiKey == TIMER_STOP)
            bStop = true;

          g_EntityFuncs.CreateEntity("trigger_timer", {
            {"type", string(uiKey)},
            {"targetname", string(pEntity.pev.target)}
          });

          pEntity.KeyValue("master", szFakeMaster);
          pEntity.KeyValue("wait", "0.1");

          if (DEBUG) g_Game.AlertMessage(at_console, "Created trigger_timer for \n", pEntity.pev.target);
        }
      }
    }

    if (bStart && bStop) {
      g_EntityFuncs.CreateEntity("multisource", {
        {"targetname", szFakeMaster}
      });
      return true;
    }

    return false;
  }

  bool HasEntity(const string &in szClassname)
  {
    CBaseEntity@ pEntity = g_EntityFuncs.FindEntityByClassname(@pEntity, szClassname);
    return pEntity !is null ? true : false;
  }

  void FixSpawns()
  {
    CBaseEntity@ pEntity;
    while (true)
    {
      @pEntity = g_EntityFuncs.FindEntityByString(@pEntity, "classname", "info_player_start");

      if (pEntity is null)
        break;

      g_EntityFuncs.CreateEntity("info_player_deathmatch", {
        {"angles", pEntity.pev.angles.ToString()},
        {"origin", pEntity.pev.origin.ToString()}
      });

      g_EntityFuncs.Remove(pEntity);
    }
  }

  void CreateButton(CBasePlayer@ pPlayer, const uint uiType) {
    const float flPlayerY = pPlayer.pev.angles.y;
    const float flButtonY = flPlayerY > 0 ? -90 + flPlayerY : 270 + flPlayerY;

    Vector vAngles = Vector(0, flButtonY, 0);
    Vector vOrigin = pPlayer.pev.origin;
    vOrigin.z -= 32;

    CBaseEntity@ pButton = g_EntityFuncs.CreateEntity("func_timer", {
      {"type", string(uiType)},
      {"angles", vAngles.ToString()},
      {"origin", vOrigin.ToString()}
    });

    g_Buttons.insertLast(@pButton);
  };

  void RemoveButton(const uint uiType)
  {
    for (uint i = 0; i < g_Buttons.length(); ++i)
    {
      CBaseEntity@ pButton = g_Buttons[i];
      if (pButton.pev.iuser4 == float(uiType))
      {
        g_EntityFuncs.Remove(@pButton);
        g_Buttons.removeAt(i);
      }
    }
  }

  void SaveButtons()
  {
    array<string> buttons;
    for (uint i = 0; i < g_Buttons.length(); ++i)
    {
      CBaseEntity@ pButton = g_Buttons[i];
      string szLine;
      snprintf(szLine, "%1\t%2\t3\n",
        int(pButton.pev.iuser4),
        pButton.pev.origin.ToString(),
        pButton.pev.angles.ToString());
      buttons.insertLast(szLine);
    }
    SKZFile::WriteLines(SKZConfig::szButtons + g_Engine.mapname, @buttons);
  }

  void LoadButtons()
  {
    g_CustomEntityFuncs.RegisterCustomEntity("FuncTimer", "func_timer");

    array<string> lines = SKZFile::ReadLines(SKZConfig::szButtons + g_Engine.mapname);
    for (uint i = 0; i < lines.length(); ++i)
    {
      array<string> fields = lines[i].Split("\t");

      const uint uiType = atoi(fields[0]);

      array<string> _ = fields[1].Split(", ");
      Vector vOrigin = Vector(atof(_[0]), atof(_[1]), atof(_[2]));

      _ = fields[2].Split(", ");
      Vector vAngles = Vector(atof(_[0]), atof(_[1]), atof(_[2]));

      CBaseEntity@ pButton = g_EntityFuncs.CreateEntity("func_timer", {
        {"type", string(uiType)},
        {"angles", vAngles.ToString()},
        {"origin", vOrigin.ToString()}
      });

      g_Buttons.insertLast(@pButton);
    }
  }

}