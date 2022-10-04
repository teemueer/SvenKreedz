namespace ClientHooks
{

  HookReturnCode PutInServer(CBasePlayer@ pPlayer) {
    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);
    SKZPoint::UpdateFrags(@pClient);
    
    return HOOK_CONTINUE;
  }

  HookReturnCode Say(SayParameters@ pParams)
  {
    const CCommand@ pArguments = pParams.GetArguments();
    if (pArguments.ArgC() == 1)
    {
      CBasePlayer@ pPlayer = pParams.GetPlayer();
      if (SKZCommand::Execute(pPlayer, pArguments[0]))
      {
        pParams.ShouldHide = true;
        return HOOK_HANDLED;
      }
    }
    return HOOK_CONTINUE;
  }

  HookReturnCode Disconnect(CBasePlayer@ pPlayer)
  {
    const uint uiIndex = pPlayer.entindex();
    @SKZClient::g_Clients[uiIndex] = null;
    
    return HOOK_CONTINUE;
  }

}