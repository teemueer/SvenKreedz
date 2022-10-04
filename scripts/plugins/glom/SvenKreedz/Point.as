namespace SKZPoint
{

  array<Point@> g_CurrentMapPoints;
  array<Point@> g_OtherMapPoints;

  array<uint> g_PointSystem = {25, 20, 16, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2};

  final class Point
  {
    private string m_szSteamId;
    private uint m_uiPoints;

    string SteamId
    {
      get const { return m_szSteamId; }
      set { m_szSteamId = value; }
    }

    uint Points
    {
      get const { return m_uiPoints; }
      set { m_uiPoints = value; }
    }

    Point(const string &in szSteamId, const uint uiPoints)
    {
      this.SteamId = szSteamId;
      this.Points = uiPoints;
    }

    bool opEquals(Point@ pPoint)
    {
      return this.SteamId == pPoint.SteamId;
    }

    const string opImplConv()
    {
      string szLine;
      snprintf(szLine, "%1\t%2", this.SteamId, this.Points);
      return szLine;
    }

    int opCmp(Point@ pPoint)
    {
      if (this.Points < pPoint.Points)
        return -1;
      else if (this.Points > pPoint.Points)
        return 1;
      else
        return 0;
    }
  }

  uint GetPointsByIndex(uint iIndex)
  {
    return iIndex < g_PointSystem.length()
      ? g_PointSystem[iIndex]
      : 1;
  }

  void LoadPoints()
  {
    g_CurrentMapPoints.resize(0);
    g_OtherMapPoints.resize(0);

    array<SKZRecord::Record@>@ records = SKZRecord::GetRecords(SKZRecord::RECORD_PRO);

    for (uint i = 0; i < records.length(); ++i)
      g_CurrentMapPoints.insertLast(Point(records[i].SteamId, GetPointsByIndex(i)));

    const array<string> lines = SKZFile::ReadLines(SKZConfig::szPoints);
    for (uint i = 0; i < lines.length(); ++i)
    {
      const array<string> fields = lines[i].Split("\t");

      const string szSteamId = fields[0];
      uint uiPoints = atoi(fields[1]);

      Point@ pPoint = Point(szSteamId, uiPoints);

      int iIndex = g_CurrentMapPoints.find(@pPoint);
      if (iIndex >= 0)
        pPoint.Points -= g_CurrentMapPoints[iIndex].Points;

      g_OtherMapPoints.insertLast(@pPoint);
    }
  }

  void SavePoints()
  {
    array<Point@> points;

    for (uint i = 0; i < g_OtherMapPoints.length(); ++i)
      points.insertLast(g_OtherMapPoints[i]);

    for (uint i = 0; i < g_CurrentMapPoints.length(); ++i)
    {
      Point@ pPoint = g_CurrentMapPoints[i];
      int iIndex = points.find(@pPoint);
      if (iIndex >= 0)
        points[iIndex].Points += pPoint.Points;
      else
        points.insertLast(@pPoint);
    }

    points.sortDesc();
    SKZFile::WriteLines(SKZConfig::szPoints, @points);
  }

  void RecalculateCurrentMapPoints()
  {
    g_CurrentMapPoints.resize(0);
    array<SKZRecord::Record@>@ records = SKZRecord::GetRecords(SKZRecord::RECORD_PRO);
    for (uint i = 0; i < records.length(); ++i)
    {
      const string szSteamId = records[i].SteamId;
      const uint uiPoints = GetPointsByIndex(i);
      g_CurrentMapPoints.insertLast(Point(szSteamId, uiPoints));
    }
  }

  void UpdateFrags(SKZClient::Client@ pClient)
  {
    string szSteamId = pClient.SteamId;
    uint uiFrags = 0;

    int iIndex = g_OtherMapPoints.find(Point(szSteamId, 0));
    uiFrags += iIndex >= 0 ? g_OtherMapPoints[iIndex].Points : 0;

    iIndex = g_CurrentMapPoints.find(Point(szSteamId, 0));
    uiFrags += iIndex >= 0 ? g_CurrentMapPoints[iIndex].Points : 0;

    CBasePlayer@ pPlayer = pClient.Player;
    if (pPlayer !is null)
      pClient.Player.pev.frags = uiFrags;
  }

  void UpdateFrags()
  {
    for (uint i = 0; i < SKZClient::g_Clients.length(); ++i)
    {
      SKZClient::Client@ pClient = SKZClient::g_Clients[i];
      if (pClient !is null)
        UpdateFrags(@pClient);
    }
  }

}