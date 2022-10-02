final class TriggerTimer : ScriptBaseEntity
{
  private uint m_uiType;

  bool KeyValue(const string& in szKey, const string& in szValue)
  {
    if (szKey == "type")
      m_uiType = atoi(szValue);
    else
      return BaseClass.KeyValue(szKey, szValue);
    return true;
  }

  void Precache() {
    BaseClass.Precache();
  }

  void Spawn()
  {
    self.pev.movetype = MOVETYPE_NONE;
    self.pev.solid = SOLID_NOT;
    self.pev.framerate = 1.0f;

    self.Precache();
  }

  void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
  {
    if (pActivator is null || !pActivator.IsPlayer())
      return;

    CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
    if (pPlayer is null)
      return;

    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);

    if (m_uiType == SKZEntity::TIMER_START)
      pClient.Start();
    else if (m_uiType == SKZEntity::TIMER_STOP)
      pClient.Stop();
  } 
}