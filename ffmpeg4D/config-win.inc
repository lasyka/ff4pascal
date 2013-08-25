{* Libraries *}

{$DEFINE HaveFFmpeg}
{$IF Defined(HaveFFmpeg) and Defined(IncludeConstants)}
  av__codec = 'avcodec-54';
  LIBAVCODEC_VERSION_MAJOR   = 54;
  LIBAVCODEC_VERSION_MINOR   = 92;
  LIBAVCODEC_VERSION_RELEASE = 100;

  av__format = 'avformat-54';
  LIBAVFORMAT_VERSION_MAJOR   = 54;
  LIBAVFORMAT_VERSION_MINOR   = 63;
  LIBAVFORMAT_VERSION_RELEASE = 104;

  av__util = 'avutil-52';
  LIBAVUTIL_VERSION_MAJOR   = 52;
  LIBAVUTIL_VERSION_MINOR   = 18;
  LIBAVUTIL_VERSION_RELEASE = 100;
{$IFEND}

{$DEFINE HaveSWScale}
{$IF Defined(HaveSWScale) and Defined(IncludeConstants)}
  sw__scale = 'swscale-2';
  LIBSWSCALE_VERSION_MAJOR   = 2;
  LIBSWSCALE_VERSION_MINOR   = 2;
  LIBSWSCALE_VERSION_RELEASE = 100;
{$IFEND}
