final class FuncTimer : ScriptBaseEntity
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
    self.pev.solid = SOLID_BBOX;
    self.pev.framerate = 1.0f;

    g_EntityFuncs.SetOrigin(self, self.pev.origin);
    g_EntityFuncs.SetModel(self, "models/glom/kz/" + (m_uiType == SKZEntity::TIMER_START ? "start.mdl" : "stop.mdl"));
    g_EntityFuncs.SetSize(self.pev, Vector(-16, -16, 0), Vector(16, 16, 64));

    self.pev.iuser4 = m_uiType;
    self.pev.target = m_uiType == SKZEntity::TIMER_START ? "counter_start" : "counter_stop";

    self.Precache();

    self.pev.nextthink = g_Engine.time + 0.1f;
  }

  void Use(CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue)
  {
    if ((g_Engine.time - self.pev.nextthink) < 0.1f || pActivator is null || !pActivator.IsPlayer())
      return;

    CBasePlayer@ pPlayer = cast<CBasePlayer@>(pActivator);
    if (pPlayer is null)
      return;

    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);

    if (m_uiType == SKZEntity::TIMER_START)
      pClient.Start();
    else if (m_uiType == SKZEntity::TIMER_STOP)
      pClient.Stop();

    self.pev.nextthink = g_Engine.time + 0.1f;
  }

  int ObjectCaps()
  {
    return BaseClass.ObjectCaps() | FCAP_IMPULSE_USE;
  }
}