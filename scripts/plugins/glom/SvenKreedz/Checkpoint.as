namespace SKZCheckpoint
{

  final class Checkpoint
  {

    private uint m_uiFlags;
    private Vector m_vOrigin;
    private Vector m_vAngles;
    private Vector m_vViewOfs;
    private Vector m_vVelocity;
    private float m_flHealth;
    private float m_flArmorValue;

    private uint m_uiStartTime;

    private bool m_bSaved;

    Checkpoint()
    {
      m_uiStartTime = 0;
      m_bSaved = false;
    }

    ~Checkpoint()
    {

    }

    uint StartTime
    {
      get const { return m_uiStartTime; }
      set { m_uiStartTime = value; }
    }

    bool Save(CBasePlayer@ pPlayer, const uint uiStartTime)
    {
      if (pPlayer.pev.flags & FL_ONGROUND == 0)
      {
        SKZPrint::Notify(@pPlayer, "You must be on ground to save a checkpoint.");
        return false;
      }
      else if (!pPlayer.IsAlive())
      {
        SKZPrint::Notify(@pPlayer, "Can't save checkpoints while dead.");
        return false;
      }

      m_uiFlags = pPlayer.pev.flags;
      m_vOrigin = pPlayer.pev.origin;
      m_vAngles = pPlayer.pev.v_angle;
      m_vViewOfs = pPlayer.pev.view_ofs;
      m_vVelocity = pPlayer.pev.velocity;
      m_flHealth = pPlayer.pev.health;
      m_flArmorValue = pPlayer.pev.armorvalue;

      m_uiStartTime = uiStartTime;
      m_bSaved = true;

      SKZPrint::Notify(@pPlayer, "Checkpoint saved.");
      return true;
    }

    bool Load(CBasePlayer@ pPlayer)
    {
      if (!m_bSaved)
      {
        SKZPrint::Notify(@pPlayer, "No checkpoint saved.");
        return false;
      }

      if (m_uiFlags & FL_DUCKING != 0)
        pPlayer.pev.flags |= FL_DUCKING;

      pPlayer.pev.origin = m_vOrigin;
      pPlayer.pev.angles = m_vAngles;
      pPlayer.pev.v_angle = m_vAngles;
      pPlayer.pev.fixangle = FAM_FORCEVIEWANGLES;
      pPlayer.pev.view_ofs = m_vViewOfs;
      pPlayer.pev.velocity = Vector(0, 0, 0);
      pPlayer.pev.health = m_flHealth;
      pPlayer.pev.armorvalue = m_flArmorValue;

      SKZPrint::Notify(@pPlayer, "Checkpoint loaded.");
      return true;
    }

  }

}