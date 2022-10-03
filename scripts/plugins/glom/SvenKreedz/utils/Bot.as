namespace SKZBot
{
  bool g_bBotInGame = false;

  SKZClient::Client@ Create(const string& in szName)
  {
    CBasePlayer@ pPlayer = g_PlayerFuncs.CreateBot(szName);
    SKZClient::Client@ pClient = SKZClient::Client(@pPlayer);
    pClient.Respawn(true);
    SKZClient::g_Clients.insertLast(@pClient);
    g_bBotInGame = true;
    return @pClient;
  }

  void KickAll()
  {
    for (uint i = 0; i < SKZClient::g_Clients.length(); ++i)
    {
      SKZClient::Client@ pClient = SKZClient::g_Clients[i];
      if (pClient !is null && pClient.IsBot)
        g_AdminControl.KickPlayer(@pClient.Player);
    }
    g_bBotInGame = false;
  }
}