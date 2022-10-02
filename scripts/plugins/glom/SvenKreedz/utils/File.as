namespace SKZFile
{
  array<string> ReadLines(const string& in szFilepath)
  {
    File@ pFile = g_FileSystem.OpenFile(szFilepath, OpenFile::READ);
    array<string> lines;

    while (pFile !is null && !pFile.EOFReached())
    {
      string szLine;
      pFile.ReadLine(szLine);
      szLine.Trim();
      if (szLine != "")
        lines.insertLast(szLine);
    }

    return lines;
  }

  void WriteLines(const string& in szFilepath, const array<string>@ lines)
  {
    File@ pFile = g_FileSystem.OpenFile(szFilepath, OpenFile::WRITE);
    if (pFile !is null)
    {
      for (uint i = 0; i < lines.length(); ++i)
        pFile.Write(lines[i] + "\n");
    }
  }

  void WriteLines(const string& in szFilepath, array<SKZPoint::Point@>@ points)
  {
    File@ pFile = g_FileSystem.OpenFile(szFilepath, OpenFile::WRITE);
    if (pFile !is null)
    {
      for (uint i = 0; i < points.length(); ++i)
      {
        string szLine = string(points[i]);
        pFile.Write(szLine + "\n");
      }
    }
  }
}