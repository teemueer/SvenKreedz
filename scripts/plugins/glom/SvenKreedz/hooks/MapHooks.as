namespace MapHooks
{

  HookReturnCode Change()
  {
    g_Scheduler.RemoveTimer(@g_pLooper);

    g_bMapInit = false;
    g_bMapActivate = false;

    SKZClient::g_Clients.resize(0);

    g_Hooks.RemoveHook(Hooks::Player::PlayerPostThink, @PlayerHooks::PostThinkLadder);
    g_Hooks.RemoveHook(Hooks::Player::PlayerPostThink, @PlayerHooks::PostThinkWater);
    
    return HOOK_CONTINUE;
  }

}