namespace PlayerHooks
{

  array<bool> g_WaterJumping(33, false);

  HookReturnCode Spawn(CBasePlayer@ pPlayer)
  {
    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);
    pClient.RemoveTarget();
    pClient.CreateSemiclip();
    
    return HOOK_CONTINUE;
  }

  HookReturnCode TakeDamage(DamageInfo@ pDamageInfo)
  {
    if (pDamageInfo.bitsDamageType & DMG_ALWAYSGIB != 0)
      pDamageInfo.flDamage = pDamageInfo.pVictim.pev.health;
    
    return HOOK_CONTINUE;
  }

  HookReturnCode Killed(CBasePlayer@ pPlayer, CBaseEntity@ pAttacker, int iGib)
  {
    SKZClient::Client@ pClient = SKZClient::GetClient(pPlayer);
    pClient.Cancel();

    if (pAttacker is pPlayer)
      pPlayer.pev.frags += 1;

  return HOOK_CONTINUE;
  }

  HookReturnCode EnteredObserver(CBasePlayer@ pPlayer)
  {
    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);
    pClient.RemoveSemiclip();

    return HOOK_CONTINUE;
  }

  HookReturnCode PostThinkLadder(CBasePlayer@ pPlayer)
  {
    if (pPlayer.IsOnLadder()) {
      const float flBoost = SKZCommand::g_pLadderBoost.GetFloat();
      pPlayer.pev.velocity.x *= flBoost;
      pPlayer.pev.velocity.y *= flBoost;
      pPlayer.pev.velocity.z *= flBoost;
    }

    return HOOK_CONTINUE;
  }

  HookReturnCode PostThinkWater(CBasePlayer@ pPlayer)
  {
    const uint uiIndex = pPlayer.entindex();
    if (pPlayer.pev.flags & FL_WATERJUMP != 0)
    {
      if (!g_WaterJumping[uiIndex])
        pPlayer.pev.velocity.z += 8.0f;

      g_WaterJumping[uiIndex] = true;
    }
    else
      g_WaterJumping[uiIndex] = false;

    return HOOK_CONTINUE;
  }

}