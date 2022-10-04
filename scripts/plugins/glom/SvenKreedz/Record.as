namespace SKZRecord
{
  enum RECORD
  {
    RECORD_PRO,
    RECORD_NUB
  }

  dictionary g_Records = {
    {RECORD_PRO, array<Record@>()},
    {RECORD_NUB, array<Record@>()}
  };

  final class Record
  {

    private string m_szName;
    private string m_szSteamId;
    private uint m_uiTime;
    private uint m_uiTp;
    private uint m_uiCp;
    private uint m_uiDate;

    string Name
    {
      get const { return m_szName; }
    }

    string SteamId
    {
      get const { return m_szSteamId; }
    }

    uint Time
    {
      get const { return m_uiTime; }
    }

    uint Cp
    {
      get const { return m_uiCp; }
    }

    uint Tp
    {
      get const { return m_uiTp; }
    }

    uint Date
    {
      get const { return m_uiDate; }
    }

    bool IsPro
    {
      get const { return m_uiTp == 0; }
    }

    Record(const string& in szName, const string& in szSteamId, const uint uiTime,
      const uint uiCp, const uint uiTp, const uint uiDate = UnixTimestamp())
    {
      m_szName = szName;
      m_szSteamId = szSteamId;
      m_uiTime = uiTime;
      m_uiTp = uiCp;
      m_uiCp = uiTp;
      m_uiDate = uiDate;
    }

    Record(const string& in szSteamId)
    {
      m_szSteamId = szSteamId;
    }

    ~Record()
    {
      if (DEBUG) g_Game.AlertMessage(at_console, "[%1] ~Record()\n", m_szName);
    }

    bool opEquals(Record@ pRecord)
    {
      return this.SteamId == pRecord.SteamId;
    }

    int opCmp(Record@ pRecord)
    {
      if (this.Time < pRecord.Time)
        return -1;
      else if (this.Time > pRecord.Time)
        return 1;
      else
        return 0;
    }

    const string opImplConv()
    {
      string szLine;
      snprintf(szLine, "%1\t%2\t%3\t%4\t%5\t%6",
        this.Name, this.SteamId, this.Time, this.Cp, this.Tp, this.Date);
      return szLine;
    }

    array<string> @opCast()
    {
      return this.IsPro
        ? array<string> = {this.Name, this.SteamId, SKZTime::HMS(this.Time), SKZTime::YMD(this.Date)}
        : array<string> = {this.Name, this.SteamId, SKZTime::HMS(this.Time), string(this.Cp), string(this.Cp), SKZTime::YMD(this.Date)};
    }
  }

  bool UpdateRecords(Record@ pRecord)
  {
    if (DEBUG) g_Game.AlertMessage(at_console, "UpdateRecords()\n");

    array<Record@>@ records;
    g_Records.get(pRecord.IsPro ? RECORD_PRO : RECORD_NUB, @records);

    string szDiff;
    string szCpTp;

    if (records.length() > 0)
    {
      const Record@ pTopRecord = @records[0];
      pRecord.Time < pTopRecord.Time
        ? snprintf(szDiff, "(-%1)", SKZTime::HMS(pTopRecord.Time - pRecord.Time))
        : snprintf(szDiff, "(+%1)", SKZTime::HMS(pRecord.Time - pTopRecord.Time));
    }

    if (!pRecord.IsPro)
      snprintf(szCpTp, "(%1 cp, %2 tp)", pRecord.Cp, pRecord.Tp);

    int iIndex = records.find(@pRecord);

    if (iIndex != -1)
    {
      Record@ pOldRecord = @records[iIndex];
      if (pRecord.Time < pOldRecord.Time)
        @records[iIndex] = @pRecord;
      else
      {
        SKZPrint::Chat("%1 finished the map in %2 %3 %4", pRecord.Name, SKZTime::HMS(pRecord.Time), szDiff, szCpTp);
        return false;
      }
    }
    else
      records.insertLast(@pRecord);

    records.sortAsc();
    iIndex = records.find(@pRecord);

    if (pRecord.IsPro)
    {
      SKZPrint::Chat("%1 got %2 place with %3 %4", pRecord.Name, SKZMisc::OrdinalNumber(iIndex + 1), SKZTime::HMS(pRecord.Time), szDiff);
      SKZPoint::RecalculateCurrentMapPoints();
      SKZPoint::UpdateFrags();
      SKZPoint::SavePoints();
    }
    else
      SKZPrint::Chat("%1 finished the map in %2 %3 %4", pRecord.Name, SKZTime::HMS(pRecord.Time), szDiff, szCpTp);

    SaveRecords();
    SKZMisc::Woop();

    return true;
  }

  void LoadRecords()
  {
    if (DEBUG) g_Game.AlertMessage(at_console, "LoadRecords()\n");

    array<Record@>@ proRecords = cast<array<Record@>@>(g_Records[RECORD_PRO]);
    array<Record@>@ nubRecords = cast<array<Record@>@>(g_Records[RECORD_NUB]);

    proRecords.resize(0);
    nubRecords.resize(0);

    const array<string> lines = SKZFile::ReadLines(SKZConfig::szRecords + g_Engine.mapname);
    for (uint i = 0; i < lines.length(); ++i)
    {
      const array<string> fields = lines[i].Split("\t");

      const string szName = fields[0];
      const string szSteamId = fields[1];
      const uint uiTime = atoi(fields[2]);
      const uint uiCp = atoi(fields[3]);
      const uint uiTp = atoi(fields[4]);
      const uint uiDate = atoi(fields[5]);

      Record@ pRecord = Record(szName, szSteamId, uiTime, uiCp, uiTp, uiDate);

      pRecord.IsPro
        ? proRecords.insertLast(@pRecord)
        : nubRecords.insertLast(@pRecord);
    }

    proRecords.sortAsc();
    nubRecords.sortAsc();
  }

  void SaveRecords()
  {
    if (DEBUG) g_Game.AlertMessage(at_console, "UpdateRecords()\n");

    array<string> allRecords;
    const array<RECORD> recordTypes = {RECORD_PRO, RECORD_NUB};

    for (uint i = 0; i < recordTypes.length(); ++i)
    {
      const array<Record@>@ records = cast<array<Record@>@>(g_Records[recordTypes[i]]);
      for (uint j = 0; j < records.length(); ++j)
        allRecords.insertLast(@records[j]);
    }

    SKZFile::WriteLines(SKZConfig::szRecords + g_Engine.mapname, @allRecords);
  }

  void PrintRecords(CBasePlayer@ pPlayer, RECORD recordType)
  {
    if (pPlayer is null)
      return;

    const array<Record@>@ records = cast<array<Record@>@>(g_Records[recordType]);

    if (records.length() == 0)
    {
      SKZPrint::Notify(@pPlayer, "No %1 records for '%2' yet.", recordType == RECORD_PRO ? "pro" : "nub", g_Engine.mapname);
      return;
    }

    array<array<string>@> data;

    recordType == RECORD_PRO
      ? data.insertLast(array<string> = {"#", "NAME", "STEAMID", "TIME", "DATE"})
      : data.insertLast(array<string> = {"#", "NAME", "STEAMID", "TIME", "CP", "TP", "DATE"});

    for (uint i = 0; i < records.length(); ++i)
    {
      array<string> record = cast<array<string>>(records[i]);
      record.insertAt(0, string(i + 1) + ".");
      data.insertLast(@record);
    }

    array<uint> lengths;
    for (uint i = 0; i < data.length(); ++i)
    {
      for (uint j = 0; j < data[i].length(); ++j)
      {
        const uint length = data[i][j].Length();
        if (j >= lengths.length())
          lengths.insertLast(length);
        else if (lengths[j] < length)
          lengths[j] = length;
      }
    }

    string szHr;
    for (uint i = 0; i < lengths.length(); ++i)
    {
      for (uint j = 0; j < lengths[i]; ++j)
        szHr += "-";
      if (i < lengths.length() - 1)
        szHr += "-+-";
    }

    SKZPrint::Notify(@pPlayer, "%1 records for '%2' printed in console.", recordType == RECORD_PRO ? "Pro" : "Nub", g_Engine.mapname);

    SKZPrint::Console(@pPlayer, "");
    for (uint i = 0; i < data.length(); ++i)
    {
      string szLine;
      for (uint j = 0; j < data[i].length(); ++j)
      {
        const string value = data[i][j];
        szLine += value;
        for (uint k = 0; k < (lengths[j] - value.Length()); ++k)
          szLine += " ";
        
        if (j + 1 < data[i].length())
          szLine += " | ";
      }
      SKZPrint::Console(@pPlayer, szLine);
      if (i == 0)
        SKZPrint::Console(@pPlayer, szHr);
    }
    SKZPrint::Console(@pPlayer, "");
  }

  array<Record@>@ GetRecords(RECORD recordType)
  {
    return cast<array<Record@>@>(g_Records[recordType]);
  }

}