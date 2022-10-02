final class TriggerSemiclip : ScriptBaseEntity
{
  private float m_flLastTouch;
  
  private Vector m_vecMins = Vector(-64, -64, -64);
  private Vector m_vecMaxs = Vector(64, 64, 64);

  float LastTouch
  {
    get const { return m_flLastTouch; }
    set { m_flLastTouch = value; }
  }

  CBaseEntity@ Owner
  {
    get const { return g_EntityFuncs.Instance(self.pev.owner); }
  }

  bool KeyValue(const string& in szKey, const string& in szValue)
  {
    return BaseClass.KeyValue(szKey, szValue);
  }

  void Precache()
  {
    BaseClass.Precache();

    g_Game.PrecacheModel(self, "models/player.mdl");
		g_Game.PrecacheModel(self, "models/playert.mdl");
  }

  void Spawn()
  {
    this.Precache();

    g_EntityFuncs.SetModel(self, "models/player.mdl");

    @self.pev.aiment = @self.pev.owner;
    self.pev.movetype = MOVETYPE_FOLLOW;
    self.pev.solid = SOLID_TRIGGER;
    self.pev.framerate = 1.0f;
    self.pev.effects = EF_NODRAW;

    g_EntityFuncs.SetSize(self.pev, m_vecMins, m_vecMaxs);
    g_EntityFuncs.SetOrigin(self, self.pev.origin);

    SetTouch(TouchFunction(this.Touch));

    self.pev.nextthink = g_Engine.time + 0.1f;
  }

  void Touch(CBaseEntity@ pEntity)
  {
    if (pEntity is null || pEntity.edict() is self.pev.owner || !this.Owner.IsAlive() || !pEntity.IsPlayer() || !pEntity.IsAlive())
      return;

    CBasePlayer@ pPlayer = cast<CBasePlayer@>(pEntity);
    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);

    if (!pClient.IsSemiclipped)
      pClient.ToggleSemiclip();

    this.m_flLastTouch = g_Engine.time + 0.2f;
  }

  void Think()
  {
    if (m_flLastTouch > 0 && m_flLastTouch < g_Engine.time)
    {
      m_flLastTouch = 0;
      CBasePlayer@ pPlayer = cast<CBasePlayer@>(this.Owner);
      SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);
      if (pClient.IsSemiclipped)
        pClient.ToggleSemiclip();
    }

    self.pev.nextthink = g_Engine.time + 0.4f;
  }
}