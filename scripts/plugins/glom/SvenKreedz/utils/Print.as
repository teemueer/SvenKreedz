namespace SKZPrint
{
  void Chat(const string& in szMessage)
  {
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTTALK, "[KZ] " + szMessage + "\n");
  }

  void Chat(const string& in szFormat, const string& in p1, const string& in p2, const string& in p3, const string& in p4)
  {
    string szMessage;
    snprintf(szMessage, szFormat, p1, p2, p3, p4);
    Chat(szMessage);
  }


  void Notify(const string& in szMessage)
  {
    g_PlayerFuncs.ClientPrintAll(HUD_PRINTNOTIFY, "[KZ] " + szMessage + "\n");
  }

  void Notify(const string& in szFormat, const string& in p1)
  {
    string szMessage;
    snprintf(szMessage, szFormat, p1);
    Notify(szMessage);
  }

  void Notify(CBasePlayer@ pPlayer, const string& in szMessage)
  {
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTNOTIFY, "[KZ] " + szMessage + "\n");
  }

  void Notify(CBasePlayer@ pPlayer, const string& in szFormat, const string& in p1, const string& in p2)
  {
    string szMessage;
    snprintf(szMessage, szFormat, p1, p2);
    Notify(@pPlayer, szMessage);
  }


  void Console(CBasePlayer@ pPlayer, const string& in szMessage)
  {
    g_PlayerFuncs.ClientPrint(pPlayer, HUD_PRINTCONSOLE, szMessage + "\n");
  }

  void Console(CBasePlayer@ pPlayer, const string& in szFormat, const string& in p1)
  {
    string szMessage;
    snprintf(szMessage, szFormat, p1);
    Console(@pPlayer, szMessage);
  }
}