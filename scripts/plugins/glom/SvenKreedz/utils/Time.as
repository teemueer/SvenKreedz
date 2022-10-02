namespace SKZTime
{

  uint Now()
  {
    return uint(g_Engine.time * 1000);
  }

  const string HMS(const uint uiTime)
  {
    float flTime = uiTime / 1000.0;

    int uiH = int(flTime / (60 * 60));
    int uiM = int(flTime / 60) % 60;
    float flS = flTime % 60;

    string szM = formatInt(uiM, "0", 2);
    string szS = formatFloat(flS, "0", 6, 3);

    string szHms;
    if (uiH > 0)
      snprintf(szHms, "%1:%2:%3", uiH, szM, szS);
    else if (uiM > 0)
      snprintf(szHms, "%1:%2", uiM, szS);
    else
      szHms = szS;

    return szHms;
  }

  const string YMD(const uint uiDate)
  {
    DateTime pDateTime = DateTime();
    pDateTime.SetUnixTimestamp(uiDate);
    string szYmd;
    pDateTime.Format(szYmd, "%Y/%m/%d");
    return szYmd;
}

}