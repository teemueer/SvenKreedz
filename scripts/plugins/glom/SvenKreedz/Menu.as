namespace SKZMenu
{
  enum menu_items {
    MENU_CP,
    MENU_TP,
    MENU_WEAPON,
    MENU_START,
    MENU_OBSERVE,
    MENU_PRO,
    MENU_NUB,
    MENU_INFO
  }

  final class Menu
  {
    private CTextMenu@ m_pMenu;

    CTextMenu@ Menu
    {
      get const { return m_pMenu; }
      set { @m_pMenu = @value; }
    }

    Menu()
    {
      CTextMenu pTemp(@MenuCallback);
      @this.Menu = @pTemp;

      this.Menu.SetTitle("KZ Menu");

      this.Menu.AddItem("Save checkpoint",  any(MENU_CP));
      this.Menu.AddItem("Load checkpoint",  any(MENU_TP));
      this.Menu.AddItem("Give weapon",      any(MENU_WEAPON));
      this.Menu.AddItem("Start",            any(MENU_START));
      this.Menu.AddItem("Observe",          any(MENU_OBSERVE));
      this.Menu.AddItem("Pro climbers",     any(MENU_PRO));
      this.Menu.AddItem("Nub climbers",     any(MENU_NUB));
      //this.Menu.AddItem("Map info",         any(MENU_INFO));

      this.Menu.Register();
    }

    void Open(CBasePlayer@ pPlayer)
    {
      this.Menu.Open(0, 0, @pPlayer);
    }
  }

  void MenuCallback(CTextMenu@ pMenu, CBasePlayer@ pPlayer, int iPage, const CTextMenuItem@ pItem)
  {
    SKZClient::Client@ pClient = SKZClient::GetClient(@pPlayer);

    if (pItem is null) {
      pClient.MenuOpen = false;
      return;
    }

    pClient.MenuOpen = true;

    uint uiAction;
    pItem.m_pUserData.retrieve(uiAction);

    switch (uiAction) {
      case MENU_CP:
        pClient.Save();
        break;
      case MENU_TP:
        pClient.Load();
        break;
      case MENU_WEAPON:
        pClient.GiveWeapon();
        break;
      case MENU_START:
        pClient.Respawn();
        break;
      case MENU_OBSERVE:
        pClient.ToggleObserver();
        break;
      case MENU_PRO:
        SKZRecord::PrintRecords(@pPlayer, SKZRecord::RECORD_PRO);
        break;
      case MENU_NUB:
        SKZRecord::PrintRecords(@pPlayer, SKZRecord::RECORD_NUB);
        break;
      case MENU_INFO:
        //PrintDetails(player);
        break;
    }

    pMenu.Open(0, 0, @pPlayer);
  }

}