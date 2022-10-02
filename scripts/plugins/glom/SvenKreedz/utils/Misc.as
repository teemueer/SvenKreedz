namespace SKZMisc
{
  string OrdinalNumber(int iIndex)
  {
    string szLine;
    switch (iIndex)
    {
      case 1:
        snprintf(szLine, "%1st", iIndex);
        break;
      case 2:
        snprintf(szLine, "%1nd", iIndex);
        break;
      case 3:
        snprintf(szLine, "%1rd", iIndex);
        break;
      default:
        snprintf(szLine, "%1th", iIndex);
    }
    return szLine;
  }

  bool ColorsMatch(RGBA color1, RGBA color2)
  {
    return (color1.r == color2.r) && (color1.g == color2.g) && (color1.b == color2.b);
  }

  void Woop()
  {
    g_SoundSystem.PlaySound(null, CHAN_STATIC, "vox/woop.wav", 1.0f, ATTN_NONE, 0, 100);
  }
}