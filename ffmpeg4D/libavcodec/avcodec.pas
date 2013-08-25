unit avcodec;

{$IFDEF FPC}
{$MODE DELPHI }
{$PACKENUM 4}    (* use 4-byte enums *)
{$PACKRECORDS C} (* C/C++-compatible record packing *)
{$ELSE}
{$MINENUMSIZE 4} (* use 4-byte enums *)
{$ENDIF}
{$IFDEF DARWIN}
{$linklib libavcodec}
{$ENDIF}

interface

uses
  ctypes, common, ffmpegconf;

(* *
  * @defgroup libavc Encoding/Decoding Library
  * @{
  *
  * @defgroup lavc_decoding Decoding
  * @{
  * @}
  *
  * @defgroup lavc_encoding Encoding
  * @{
  * @}
  *
  * @defgroup lavc_codec Codecs
  * @{
  * @defgroup lavc_codec_native Native Codecs
  * @{
  * @}
  * @defgroup lavc_codec_wrappers External library wrappers
  * @{
  * @}
  * @defgroup lavc_codec_hwaccel Hardware Accelerators bridge
  * @{
  * @}
  * @}
  * @defgroup lavc_internal Internal
  * @{
  * @}
  * @}
  *
*)
CONST
  FF_DECODE_ERROR_INVALID_BITSTREAM = 1;
  FF_DECODE_ERROR_MISSING_REFERENCE = 2;
  (* *
    * Codec uses only intra compression.
    * Video codecs only.
  *)
  AV_CODEC_PROP_INTRA_ONLY = (1 shl 0);
  (* *
    * Codec supports lossy compression. Audio and video codecs only.
    * @note a codec may support both lossy and lossless
    * compression modes
  *)
  AV_CODEC_PROP_LOSSY = (1 shl 1);
  (* *
    * Codec supports lossless compression. Audio and video codecs only.
  *)
  AV_CODEC_PROP_LOSSLESS = (1 shl 2);
  (* *
    * Subtitle codec is bitmap based
  *)
  AV_CODEC_PROP_BITMAP_SUB = (1 shl 16);

{$IF FF_API_OLD_DECODE_AUDIO}
  (* in bytes *)
  AVCODEC_MAX_AUDIO_FRAME_SIZE = 192000; // 1 second of 48khz 32bit audio
{$IFEND}
  (* *
    * @ingroup lavc_decoding
    * Required number of additionally allocated bytes at the end of the input bitstream for decoding.
    * This is mainly needed because some optimized bitstream readers read
    * 32 or 64 bit at once and could read over the end.<br>
    * Note: If the first 23 bits of the additional bytes are not 0, then damaged
    * MPEG bitstreams could cause overread and segfault.
  *)
  FF_INPUT_BUFFER_PADDING_SIZE = 16;

  (* *
    * @ingroup lavc_encoding
    * minimum encoding buffer size
    * Used to avoid some checks during header writing.
  *)
  FF_MIN_BUFFER_SIZE = 16384;
  FF_MAX_B_FRAMES = 16;

  (* encoding support
    These flags can be passed in AVCodecContext.flags before initialization.
    Note: Not everything is supported yet.
  *)
  CODEC_FLAG_QSCALE = $0002;
  /// < Use fixed qscale.
  CODEC_FLAG_4MV = $0004;
  /// < 4 MV per MB allowed / advanced prediction for H.263.
  CODEC_FLAG_QPEL = $0010;
  /// < Use qpel MC.
  CODEC_FLAG_GMC = $0020;
  /// < Use GMC.
  CODEC_FLAG_MV0 = $0040;
  /// < Always try a MB with MV=<0,0>.

  (* *
    * The parent program guarantees that the input for B-frames containing
    * streams is not written to for at least s->max_b_frames+1 frames, if
    * this is not set the input will be copied.
  *)
  CODEC_FLAG_INPUT_PRESERVED = $0100;
  CODEC_FLAG_PASS1 = $0200;
  /// < Use internal 2pass ratecontrol in first pass mode.
  CODEC_FLAG_PASS2 = $0400;
  /// < Use internal 2pass ratecontrol in second pass mode.
  CODEC_FLAG_GRAY = $2000;
  /// < Only decode/encode grayscale.
  CODEC_FLAG_EMU_EDGE = $4000;
  /// < Don't draw edges.
  CODEC_FLAG_PSNR = $8000;
  /// < error[?] variables will be set during encoding.
  CODEC_FLAG_TRUNCATED = $00010000;
  (* * Input bitstream might be truncated at a random
    location instead of only at frame boundaries. *)
  CODEC_FLAG_NORMALIZE_AQP = $00020000;
  /// < Normalize adaptive quantization.
  CODEC_FLAG_INTERLACED_DCT = $00040000;
  /// < Use interlaced DCT.
  CODEC_FLAG_LOW_DELAY = $00080000;
  /// < Force low delay.
  CODEC_FLAG_GLOBAL_HEADER = $00400000;
  /// < Place global headers in extradata instead of every keyframe.
  CODEC_FLAG_BITEXACT = $00800000;
  /// < Use only bitexact stuff (except (I)DCT).
  (* Fx : Flag for h263+ extra options *)
  CODEC_FLAG_AC_PRED = $01000000;
  /// < H.263 advanced intra coding / MPEG-4 AC prediction
  CODEC_FLAG_LOOP_FILTER = $00000800;
  /// < loop filter
  CODEC_FLAG_INTERLACED_ME = $20000000;
  /// < interlaced motion estimation
  CODEC_FLAG_CLOSED_GOP = $80000000;
  CODEC_FLAG2_FAST = $00000001;
  /// < Allow non spec compliant speedup tricks.
  CODEC_FLAG2_NO_OUTPUT = $00000004;
  /// < Skip bitstream encoding.
  CODEC_FLAG2_LOCAL_HEADER = $00000008;
  /// < Place global headers at every keyframe instead of in extradata.
  CODEC_FLAG2_DROP_FRAME_TIMECODE = $00002000;
  /// < timecode is in drop frame format. DEPRECATED!!!!
  CODEC_FLAG2_IGNORE_CROP = $00010000;
  /// < Discard cropping information from SPS.

{$IF FF_API_MPV_GLOBAL_OPTS}
  CODEC_FLAG_CBP_RD = $04000000;
  /// < Use rate distortion optimization for cbp.
  CODEC_FLAG_QP_RD = $08000000;
  /// < Use rate distortion optimization for qp selectioon.
  CODEC_FLAG2_STRICT_GOP = $00000002;
  /// < Strictly enforce GOP size.
  CODEC_FLAG2_SKIP_RD = $00004000;
  /// < RD optimal MB level residual skipping
{$IFEND}
  CODEC_FLAG2_CHUNKS = $00008000;
  /// < Input bitstream might be truncated at a packet boundaries instead of only at frame boundaries.
  CODEC_FLAG2_SHOW_ALL = $00400000;
  /// < Show all frames before the first keyframe

  (* Unsupported options :
    *              Syntax Arithmetic coding (SAC)
    *              Reference Picture Selection
    *              Independent Segment Decoding *)

  // * codec capabilities *)
  CODEC_CAP_DRAW_HORIZ_BAND = $0001;
  /// < Decoder can use draw_horiz_band callback.
  (* *
    * Codec uses get_buffer() for allocating buffers and supports custom allocators.
    * If not set, it might not use get_buffer() at all or use operations that
    * assume the buffer was allocated by avcodec_default_get_buffer.
  *)
  CODEC_CAP_DR1 = $0002;
  CODEC_CAP_TRUNCATED = $0008;
  // * Codec can export data for HW decoding (XvMC). *)
  CODEC_CAP_HWACCEL = $0010;
  (* *
    * Encoder or decoder requires flushing with NULL input at the end in order to
    * give the complete and correct output.
    *
    * NOTE: If this flag is not set, the codec is guaranteed to never be fed with
    *       with NULL data. The user can still send NULL data to the public encode
    *       or decode function, but libavcodec will not pass it along to the codec
    *       unless this flag is set.
    *
    * Decoders:
    * The decoder has a non-zero delay and needs to be fed with avpkt->data=NULL,
    * avpkt->size=0 at the end to get the delayed data until the decoder no longer
    * returns frames.
    *
    * Encoders:
    * The encoder needs to be fed with NULL data at the end of encoding until the
    * encoder no longer returns data.
    *
    * NOTE: For encoders implementing the AVCodec.encode2() function, setting this
    *       flag also means that the encoder must set the pts and duration for
    *       each output packet. If this flag is not set, the pts and duration will
    *       be determined by libavcodec from the input frame.
  *)
  CODEC_CAP_DELAY = $0020;
  (* *
    * Codec can be fed a final frame with a smaller size.
    * This can be used to prevent truncation of the last audio samples.
  *)
  CODEC_CAP_SMALL_LAST_FRAME = $0040;
  (* *
    * Codec can export data for HW decoding (VDPAU).
  *)
  CODEC_CAP_HWACCEL_VDPAU = $0080;
  (* *
    * Codec can output multiple frames per AVPacket
    * Normally demuxers return one frame at a time, demuxers which do not do
    * are connected to a parser to split what they return into proper frames.
    * This flag is reserved to the very rare category of codecs which have a
    * bitstream that cannot be split into frames without timeconsuming
    * operations like full decoding. Demuxers carring such bitstreams thus
    * may return multiple frames in a packet. This has many disadvantages like
    * prohibiting stream copy in many cases thus it should only be considered
    * as a last resort.
  *)
  CODEC_CAP_SUBFRAMES = $0100;
  (* *
    * Codec is experimental and is thus avoided in favor of non experimental
    * encoders
  *)
  CODEC_CAP_EXPERIMENTAL = $0200;
  (* *
    * Codec should fill in channel configuration and samplerate instead of container
  *)
  CODEC_CAP_CHANNEL_CONF = $0400;

  (* *
    * Codec is able to deal with negative linesizes
  *)
  CODEC_CAP_NEG_LINESIZES = $0800;

  (* *
    * Codec supports frame-level multithreading.
  *)
  CODEC_CAP_FRAME_THREADS = $1000;
  (* *
    * Codec supports slice-based (or partition-based) multithreading.
  *)
  CODEC_CAP_SLICE_THREADS = $2000;
  (* *
    * Codec supports changed parameters at any point.
  *)
  CODEC_CAP_PARAM_CHANGE = $4000;
  (* *
    * Codec supports avctx->thread_count == 0 (auto).
  *)
  CODEC_CAP_AUTO_THREADS = $8000;
  (* *
    * Audio encoder supports receiving a different number of samples in each call.
  *)
  CODEC_CAP_VARIABLE_FRAME_SIZE = $10000;
  (* *
    * Codec is intra only.
  *)
  CODEC_CAP_INTRA_ONLY = $40000000;
  (* *
    * Codec is lossless.
  *)
  CODEC_CAP_LOSSLESS = $80000000;

  // The following defines may change, don't expect compatibility if you use them.
  MB_TYPE_INTRA4x4 = $0001;
  MB_TYPE_INTRA16x16 = $0002; // FIXME H.264-specific
  MB_TYPE_INTRA_PCM = $0004; // FIXME H.264-specific
  MB_TYPE_16x16 = $0008;
  MB_TYPE_16x8 = $0010;
  MB_TYPE_8x16 = $0020;
  MB_TYPE_8x8 = $0040;
  MB_TYPE_INTERLACED = $0080;
  MB_TYPE_DIRECT2 = $0100; // FIXME
  MB_TYPE_ACPRED = $0200;
  MB_TYPE_GMC = $0400;
  MB_TYPE_SKIP = $0800;
  MB_TYPE_P0L0 = $1000;
  MB_TYPE_P1L0 = $2000;
  MB_TYPE_P0L1 = $4000;
  MB_TYPE_P1L1 = $8000;
  MB_TYPE_L0 = (MB_TYPE_P0L0 OR MB_TYPE_P1L0);
  MB_TYPE_L1 = (MB_TYPE_P0L1 OR MB_TYPE_P1L1);
  MB_TYPE_L0L1 = (MB_TYPE_L0 OR MB_TYPE_L1);
  MB_TYPE_QUANT = $00010000;
  MB_TYPE_CBP = $00020000;
  // Note bits 24-31 are reserved for codec specific use (h264 ref0, mpeg1 0mv, ...)

  FF_QSCALE_TYPE_MPEG1 = 0;
  FF_QSCALE_TYPE_MPEG2 = 1;
  FF_QSCALE_TYPE_H264 = 2;
  FF_QSCALE_TYPE_VP56 = 3;

  FF_BUFFER_TYPE_INTERNAL = 1;
  FF_BUFFER_TYPE_USER = 2;
  /// < direct rendering buffers (image is (de)allocated by user)
  FF_BUFFER_TYPE_SHARED = 4;
  /// < Buffer from somewhere else; don't deallocate image (data/base), all other tables are not shared.
  FF_BUFFER_TYPE_COPY = 8;
  /// < Just a (modified) copy of some other buffer, don't deallocate anything.

  FF_BUFFER_HINTS_VALID = $01;
  // Buffer hints value is meaningful (if 0 ignore).
  FF_BUFFER_HINTS_READABLE = $02; // Codec will read from buffer.
  FF_BUFFER_HINTS_PRESERVE = $04; // User must not alter buffer content.
  FF_BUFFER_HINTS_REUSABLE = $08; // Codec will reuse the buffer (update).

  AV_PKT_FLAG_KEY = $0001;
  /// < The packet contains a keyframe
  AV_PKT_FLAG_CORRUPT = $0002;
  /// < The packet content is corrupted
  AV_NUM_DATA_POINTERS = 8;
  FF_COMPRESSION_DEFAULT = -1;
  FF_ASPECT_EXTENDED = 15;
  FF_RC_STRATEGY_XVID = 1;
  FF_PRED_LEFT = 0;
  FF_PRED_PLANE = 1;
  FF_PRED_MEDIAN = 2;
  FF_CMP_SAD = 0;
  FF_CMP_SSE = 1;
  FF_CMP_SATD = 2;
  FF_CMP_DCT = 3;
  FF_CMP_PSNR = 4;
  FF_CMP_BIT = 5;
  FF_CMP_RD = 6;
  FF_CMP_ZERO = 7;
  FF_CMP_VSAD = 8;
  FF_CMP_VSSE = 9;
  FF_CMP_NSSE = 10;
  FF_CMP_W53 = 11;
  FF_CMP_W97 = 12;
  FF_CMP_DCTMAX = 13;
  FF_CMP_DCT264 = 14;
  FF_CMP_CHROMA = 256;

  FF_DTG_AFD_SAME = 8;
  FF_DTG_AFD_4_3 = 9;
  FF_DTG_AFD_16_9 = 10;
  FF_DTG_AFD_14_9 = 11;
  FF_DTG_AFD_4_3_SP_14_9 = 13;
  FF_DTG_AFD_16_9_SP_14_9 = 14;
  FF_DTG_AFD_SP_4_3 = 15;
  FF_DEFAULT_QUANT_BIAS = 999999;

  FF_SUB_CHARENC_MODE_DO_NOTHING = -1;
  /// < do nothing (demuxer outputs a stream supposed to be already in UTF-8, or the codec is bitmap for instance)
  FF_SUB_CHARENC_MODE_AUTOMATIC = 0;
  /// < libavcodec will select the mode itself
  FF_SUB_CHARENC_MODE_PRE_DECODER = 1;
  /// < the AVPacket data needs to be recoded to UTF-8 before being fed to the decoder, requires iconv
  FF_LEVEL_UNKNOWN = -99;
  FF_PROFILE_UNKNOWN = -99;
  FF_PROFILE_RESERVED = -100;

  FF_PROFILE_AAC_MAIN = 0;
  FF_PROFILE_AAC_LOW = 1;
  FF_PROFILE_AAC_SSR = 2;
  FF_PROFILE_AAC_LTP = 3;
  FF_PROFILE_AAC_HE = 4;
  FF_PROFILE_AAC_HE_V2 = 28;
  FF_PROFILE_AAC_LD = 22;
  FF_PROFILE_AAC_ELD = 38;

  FF_PROFILE_DTS = 20;
  FF_PROFILE_DTS_ES = 30;
  FF_PROFILE_DTS_96_24 = 40;
  FF_PROFILE_DTS_HD_HRA = 50;
  FF_PROFILE_DTS_HD_MA = 60;

  FF_PROFILE_MPEG2_422 = 0;
  FF_PROFILE_MPEG2_HIGH = 1;
  FF_PROFILE_MPEG2_SS = 2;
  FF_PROFILE_MPEG2_SNR_SCALABLE = 3;
  FF_PROFILE_MPEG2_MAIN = 4;
  FF_PROFILE_MPEG2_SIMPLE = 5;

  FF_PROFILE_H264_CONSTRAINED = (1 shl 9); // 8+1; constraint_set1_flag
  FF_PROFILE_H264_INTRA = (1 shl 11); // 8+3; constraint_set3_flag

  FF_PROFILE_H264_BASELINE = 66;
  FF_PROFILE_H264_CONSTRAINED_BASELINE = (66 OR FF_PROFILE_H264_CONSTRAINED);
  FF_PROFILE_H264_MAIN = 77;
  FF_PROFILE_H264_EXTENDED = 88;
  FF_PROFILE_H264_HIGH = 100;
  FF_PROFILE_H264_HIGH_10 = 110;
  FF_PROFILE_H264_HIGH_10_INTRA = (110 OR FF_PROFILE_H264_INTRA);
  FF_PROFILE_H264_HIGH_422 = 122;
  FF_PROFILE_H264_HIGH_422_INTRA = (122 OR FF_PROFILE_H264_INTRA);
  FF_PROFILE_H264_HIGH_444 = 144;
  FF_PROFILE_H264_HIGH_444_PREDICTIVE = 244;
  FF_PROFILE_H264_HIGH_444_INTRA = (244 OR FF_PROFILE_H264_INTRA);
  FF_PROFILE_H264_CAVLC_444 = 44;

  FF_PROFILE_VC1_SIMPLE = 0;
  FF_PROFILE_VC1_MAIN = 1;
  FF_PROFILE_VC1_COMPLEX = 2;
  FF_PROFILE_VC1_ADVANCED = 3;

  FF_PROFILE_MPEG4_SIMPLE = 0;
  FF_PROFILE_MPEG4_SIMPLE_SCALABLE = 1;
  FF_PROFILE_MPEG4_CORE = 2;
  FF_PROFILE_MPEG4_MAIN = 3;
  FF_PROFILE_MPEG4_N_BIT = 4;
  FF_PROFILE_MPEG4_SCALABLE_TEXTURE = 5;
  FF_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION = 6;
  FF_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE = 7;
  FF_PROFILE_MPEG4_HYBRID = 8;
  FF_PROFILE_MPEG4_ADVANCED_REAL_TIME = 9;
  FF_PROFILE_MPEG4_CORE_SCALABLE = 10;
  FF_PROFILE_MPEG4_ADVANCED_CODING = 11;
  FF_PROFILE_MPEG4_ADVANCED_CORE = 12;
  FF_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE = 13;
  FF_PROFILE_MPEG4_SIMPLE_STUDIO = 14;
  FF_PROFILE_MPEG4_ADVANCED_SIMPLE = 15;
  FF_THREAD_FRAME = 1;
  /// < Decode more than one frame at once
  FF_THREAD_SLICE = 2;
  /// < Decode more than one part of a single frame at once
  FF_IDCT_AUTO = 0;
  FF_IDCT_INT = 1;
  FF_IDCT_SIMPLE = 2;
  FF_IDCT_SIMPLEMMX = 3;
  FF_IDCT_LIBMPEG2MMX = 4;
{$IF FF_API_MMI}
  FF_IDCT_MMI = 5;
{$IFEND}
  FF_IDCT_ARM = 7;
  FF_IDCT_ALTIVEC = 8;
  FF_IDCT_SH4 = 9;
  FF_IDCT_SIMPLEARM = 10;
  FF_IDCT_IPP = 13;
  FF_IDCT_XVIDMMX = 14;
  FF_IDCT_SIMPLEARMV5TE = 16;
  FF_IDCT_SIMPLEARMV6 = 17;
  FF_IDCT_SIMPLEVIS = 18;
  FF_IDCT_FAAN = 20;
  FF_IDCT_SIMPLENEON = 22;
  FF_IDCT_SIMPLEALPHA = 23;
{$IF FF_API_IDCT}
  FF_IDCT_H264 = 11;
  FF_IDCT_VP3 = 12;
  FF_IDCT_CAVS = 15;
  FF_IDCT_WMV2 = 19;
  FF_IDCT_EA = 21;
  FF_IDCT_BINK = 24;
{$IFEND}
  FF_DCT_AUTO = 0;
  FF_DCT_FASTINT = 1;
  FF_DCT_INT = 2;
  FF_DCT_MMX = 3;
  FF_DCT_ALTIVEC = 5;
  FF_DCT_FAAN = 6;
  AV_EF_CRCCHECK = (1 shl 0);
  AV_EF_BITSTREAM = (1 shl 1);
  AV_EF_BUFFER = (1 shl 2);
  AV_EF_EXPLODE = (1 shl 3);

  AV_EF_CAREFUL = (1 shl 16);
  AV_EF_COMPLIANT = (1 shl 17);
  AV_EF_AGGRESSIVE = (1 shl 18);
  FF_DEBUG_VIS_MV_P_FOR = $00000001;
  // visualize forward predicted MVs of P frames
  FF_DEBUG_VIS_MV_B_FOR = $00000002;
  // visualize forward predicted MVs of B frames
  FF_DEBUG_VIS_MV_B_BACK = $00000004;
  // visualize backward predicted MVs of B frames
  FF_DEBUG_PICT_INFO = 1;
  FF_DEBUG_RC = 2;
  FF_DEBUG_BITSTREAM = 4;
  FF_DEBUG_MB_TYPE = 8;
  FF_DEBUG_QP = 16;
  FF_DEBUG_MV = 32;
  FF_DEBUG_DCT_COEFF = $00000040;
  FF_DEBUG_SKIP = $00000080;
  FF_DEBUG_STARTCODE = $00000100;
  FF_DEBUG_PTS = $00000200;
  FF_DEBUG_ER = $00000400;
  FF_DEBUG_MMCO = $00000800;
  FF_DEBUG_BUGS = $00001000;
  FF_DEBUG_VIS_QP = $00002000;
  FF_DEBUG_VIS_MB_TYPE = $00004000;
  FF_DEBUG_BUFFERS = $00008000;
  FF_DEBUG_THREADS = $00010000;
  FF_COMPLIANCE_VERY_STRICT = 2;
  /// < Strictly conform to an older more strict version of the spec or reference software.
  FF_COMPLIANCE_STRICT = 1;
  /// < Strictly conform to all the things in the spec no matter what consequences.
  FF_COMPLIANCE_NORMAL = 0;
  FF_COMPLIANCE_UNOFFICIAL = -1;
  /// < Allow unofficial extensions
  FF_COMPLIANCE_EXPERIMENTAL = -2;
  /// < Allow nonstandardized experimental things.
  FF_BUG_AUTODETECT = 1;
  /// < autodetection
  FF_BUG_OLD_MSMPEG4 = 2;
  FF_BUG_XVID_ILACE = 4;
  FF_BUG_UMP4 = 8;
  FF_BUG_NO_PADDING = 16;
  FF_BUG_AMV = 32;
  FF_BUG_AC_VLC = 0;
  /// < Will be removed, libavcodec can now handle these non-compliant files by default.
  FF_BUG_QPEL_CHROMA = 64;
  FF_BUG_STD_QPEL = 128;
  FF_BUG_QPEL_CHROMA2 = 256;
  FF_BUG_DIRECT_BLOCKSIZE = 512;
  FF_BUG_EDGE = 1024;
  FF_BUG_HPEL_CHROMA = 2048;
  FF_BUG_DC_CLIP = 4096;
  FF_BUG_MS = 8192;
  /// < Work around various bugs in Microsoft's broken decoders.
  FF_BUG_TRUNCATED = 16384;
  FF_MB_DECISION_SIMPLE = 0;
  /// < uses mb_cmp
  FF_MB_DECISION_BITS = 1;
  /// < chooses the one which needs the fewest bits
  FF_MB_DECISION_RD = 2;
  /// < rate distortion
  SLICE_FLAG_CODED_ORDER = $0001;
  /// < draw_horiz_band() is called in coded order instead of display
  SLICE_FLAG_ALLOW_FIELD = $0002;
  /// < allow draw_horiz_band() with field slices (MPEG2 field pics)
  SLICE_FLAG_ALLOW_PLANE = $0004;
  /// < allow draw_horiz_band() with 1 component at a time (SVQ1)

  FF_CODER_TYPE_VLC = 0;
  FF_CODER_TYPE_AC = 1;
  FF_CODER_TYPE_RAW = 2;
  FF_CODER_TYPE_RLE = 3;
  FF_CODER_TYPE_DEFLATE = 4;

  FF_EC_GUESS_MVS = 1;
  FF_EC_DEBLOCK = 2;

  AV_SUBTITLE_FLAG_FORCED = $00000001;

  AV_PARSER_PTS_NB = 4;
  PARSER_FLAG_COMPLETE_FRAMES = $0001;
  PARSER_FLAG_ONCE = $0002;
  /// Set if the parser has a valid file offset
  PARSER_FLAG_FETCHED_OFFSET = $0004;
  PARSER_FLAG_USE_CODEC_TS = $1000;

  FF_LOSS_RESOLUTION = $0001; (* *< loss due to resolution change *)
  FF_LOSS_DEPTH = $0002; (* *< loss due to color depth change *)
  FF_LOSS_COLORSPACE = $0004; (* *< loss due to color space conversion *)
  FF_LOSS_ALPHA = $0008; (* *< loss of alpha bits *)
  FF_LOSS_COLORQUANT = $0010; (* *< loss due to color quantization *)
  FF_LOSS_CHROMA = $0020; (* *< loss of chroma (e.g. RGB to gray conversion) *)

Type
  (* *
    * @defgroup lavc_core Core functions/structures.
    * @ingroup libavc
    *
    * Basic definitions, functions for querying libavcodec capabilities,
    * allocating core structures, etc.
    * @{
  *)

  (* *
    * Identify the syntax and semantics of the bitstream.
    * The principle is roughly:
    * Two decoders with the same ID can decode the same streams.
    * Two encoders with the same ID can encode compatible streams.
    * There may be slight deviations from the principle due to implementation
    * details.
    *
    * If you add a codec ID to this list, add it so that
    * 1. no value of a existing codec ID changes (that would break ABI),
    * 2. Give it a value which when taken as ASCII is recognized uniquely by a human as this specific codec.
    *    This ensures that 2 forks can independently add AVCodecIDs without producing conflicts.
    *
    * After adding new codec IDs, do not forget to add an entry to the codec
    * descriptor list and bump libavcodec minor version.
  *)
  AVCodecID = (AV_CODEC_ID_NONE,
    // * video codecs *)
    AV_CODEC_ID_MPEG1VIDEO, AV_CODEC_ID_MPEG2VIDEO,
    /// < preferred ID for MPEG-1/2 video decoding
    AV_CODEC_ID_MPEG2VIDEO_XVMC, AV_CODEC_ID_H261, AV_CODEC_ID_H263,
    AV_CODEC_ID_RV10, AV_CODEC_ID_RV20, AV_CODEC_ID_MJPEG, AV_CODEC_ID_MJPEGB,
    AV_CODEC_ID_LJPEG, AV_CODEC_ID_SP5X, AV_CODEC_ID_JPEGLS, AV_CODEC_ID_MPEG4,
    AV_CODEC_ID_RAWVIDEO, AV_CODEC_ID_MSMPEG4V1, AV_CODEC_ID_MSMPEG4V2,
    AV_CODEC_ID_MSMPEG4V3, AV_CODEC_ID_WMV1, AV_CODEC_ID_WMV2,
    AV_CODEC_ID_H263P, AV_CODEC_ID_H263I, AV_CODEC_ID_FLV1, AV_CODEC_ID_SVQ1,
    AV_CODEC_ID_SVQ3, AV_CODEC_ID_DVVIDEO, AV_CODEC_ID_HUFFYUV,
    AV_CODEC_ID_CYUV, AV_CODEC_ID_H264, AV_CODEC_ID_INDEO3, AV_CODEC_ID_VP3,
    AV_CODEC_ID_THEORA, AV_CODEC_ID_ASV1, AV_CODEC_ID_ASV2, AV_CODEC_ID_FFV1,
    AV_CODEC_ID_4XM, AV_CODEC_ID_VCR1, AV_CODEC_ID_CLJR, AV_CODEC_ID_MDEC,
    AV_CODEC_ID_ROQ, AV_CODEC_ID_INTERPLAY_VIDEO, AV_CODEC_ID_XAN_WC3,
    AV_CODEC_ID_XAN_WC4, AV_CODEC_ID_RPZA, AV_CODEC_ID_CINEPAK,
    AV_CODEC_ID_WS_VQA, AV_CODEC_ID_MSRLE, AV_CODEC_ID_MSVIDEO1,
    AV_CODEC_ID_IDCIN, AV_CODEC_ID_8BPS, AV_CODEC_ID_SMC, AV_CODEC_ID_FLIC,
    AV_CODEC_ID_TRUEMOTION1, AV_CODEC_ID_VMDVIDEO, AV_CODEC_ID_MSZH,
    AV_CODEC_ID_ZLIB, AV_CODEC_ID_QTRLE, AV_CODEC_ID_SNOW, AV_CODEC_ID_TSCC,
    AV_CODEC_ID_ULTI, AV_CODEC_ID_QDRAW, AV_CODEC_ID_VIXL, AV_CODEC_ID_QPEG,
    AV_CODEC_ID_PNG, AV_CODEC_ID_PPM, AV_CODEC_ID_PBM, AV_CODEC_ID_PGM,
    AV_CODEC_ID_PGMYUV, AV_CODEC_ID_PAM, AV_CODEC_ID_FFVHUFF, AV_CODEC_ID_RV30,
    AV_CODEC_ID_RV40, AV_CODEC_ID_VC1, AV_CODEC_ID_WMV3, AV_CODEC_ID_LOCO,
    AV_CODEC_ID_WNV1, AV_CODEC_ID_AASC, AV_CODEC_ID_INDEO2, AV_CODEC_ID_FRAPS,
    AV_CODEC_ID_TRUEMOTION2, AV_CODEC_ID_BMP, AV_CODEC_ID_CSCD,
    AV_CODEC_ID_MMVIDEO, AV_CODEC_ID_ZMBV, AV_CODEC_ID_AVS,
    AV_CODEC_ID_SMACKVIDEO, AV_CODEC_ID_NUV, AV_CODEC_ID_KMVC,
    AV_CODEC_ID_FLASHSV, AV_CODEC_ID_CAVS, AV_CODEC_ID_JPEG2000,
    AV_CODEC_ID_VMNC, AV_CODEC_ID_VP5, AV_CODEC_ID_VP6, AV_CODEC_ID_VP6F,
    AV_CODEC_ID_TARGA, AV_CODEC_ID_DSICINVIDEO, AV_CODEC_ID_TIERTEXSEQVIDEO,
    AV_CODEC_ID_TIFF, AV_CODEC_ID_GIF, AV_CODEC_ID_DXA, AV_CODEC_ID_DNXHD,
    AV_CODEC_ID_THP, AV_CODEC_ID_SGI, AV_CODEC_ID_C93, AV_CODEC_ID_BETHSOFTVID,
    AV_CODEC_ID_PTX, AV_CODEC_ID_TXD, AV_CODEC_ID_VP6A, AV_CODEC_ID_AMV,
    AV_CODEC_ID_VB, AV_CODEC_ID_PCX, AV_CODEC_ID_SUNRAST, AV_CODEC_ID_INDEO4,
    AV_CODEC_ID_INDEO5, AV_CODEC_ID_MIMIC, AV_CODEC_ID_RL2,
    AV_CODEC_ID_ESCAPE124, AV_CODEC_ID_DIRAC, AV_CODEC_ID_BFI, AV_CODEC_ID_CMV,
    AV_CODEC_ID_MOTIONPIXELS, AV_CODEC_ID_TGV, AV_CODEC_ID_TGQ, AV_CODEC_ID_TQI,
    AV_CODEC_ID_AURA, AV_CODEC_ID_AURA2, AV_CODEC_ID_V210X, AV_CODEC_ID_TMV,
    AV_CODEC_ID_V210, AV_CODEC_ID_DPX, AV_CODEC_ID_MAD, AV_CODEC_ID_FRWU,
    AV_CODEC_ID_FLASHSV2, AV_CODEC_ID_CDGRAPHICS, AV_CODEC_ID_R210,
    AV_CODEC_ID_ANM, AV_CODEC_ID_BINKVIDEO, AV_CODEC_ID_IFF_ILBM,
    AV_CODEC_ID_IFF_BYTERUN1, AV_CODEC_ID_KGV1, AV_CODEC_ID_YOP,
    AV_CODEC_ID_VP8, AV_CODEC_ID_PICTOR, AV_CODEC_ID_ANSI,
    AV_CODEC_ID_A64_MULTI, AV_CODEC_ID_A64_MULTI5, AV_CODEC_ID_R10K,
    AV_CODEC_ID_MXPEG, AV_CODEC_ID_LAGARITH, AV_CODEC_ID_PRORES, AV_CODEC_ID_JV,
    AV_CODEC_ID_DFA, AV_CODEC_ID_WMV3IMAGE, AV_CODEC_ID_VC1IMAGE,
    AV_CODEC_ID_UTVIDEO, AV_CODEC_ID_BMV_VIDEO, AV_CODEC_ID_VBLE,
    AV_CODEC_ID_DXTORY, AV_CODEC_ID_V410, AV_CODEC_ID_XWD, AV_CODEC_ID_CDXL,
    AV_CODEC_ID_XBM, AV_CODEC_ID_ZEROCODEC, AV_CODEC_ID_MSS1, AV_CODEC_ID_MSA1,
    AV_CODEC_ID_TSCC2, AV_CODEC_ID_MTS2, AV_CODEC_ID_CLLC, AV_CODEC_ID_MSS2,
    AV_CODEC_ID_VP9,
    // TODO  ##########################################
    // AV_CODEC_ID_BRENDER_PIX = MKBETAG('B', 'P', 'I', 'X'),
    // AV_CODEC_ID_Y41P = MKBETAG('Y', '4', '1', 'P'),
    // AV_CODEC_ID_ESCAPE130 = MKBETAG('E', '1', '3', '0'),
    // AV_CODEC_ID_EXR = MKBETAG('0', 'E', 'X', 'R'),
    // AV_CODEC_ID_AVRP = MKBETAG('A','V', 'R', 'P'),
    // AV_CODEC_ID_012V = MKBETAG('0', '1', '2', 'V'),
    // AV_CODEC_ID_G2M = MKBETAG(0,'G', '2', 'M'),
    // AV_CODEC_ID_AVUI = MKBETAG('A', 'V', 'U', 'I'),
    // AV_CODEC_ID_AYUV = MKBETAG('A', 'Y', 'U', 'V'),
    // AV_CODEC_ID_TARGA_Y216 = MKBETAG('T', '2', '1', '6'),
    // AV_CODEC_ID_V308 = MKBETAG('V', '3', '0', '8'),
    // AV_CODEC_ID_V408 = MKBETAG('V', '4', '0', '8'),
    // AV_CODEC_ID_YUV4 = MKBETAG('Y', 'U', 'V', '4'),
    // AV_CODEC_ID_SANM = MKBETAG('S', 'A', 'N', 'M'),
    // AV_CODEC_ID_PAF_VIDEO = MKBETAG('P', 'A', 'F', 'V'),
    // AV_CODEC_ID_AVRN = MKBETAG('A', 'V', 'R', 'n'),
    // AV_CODEC_ID_CPIA = MKBETAG('C', 'P', 'I', 'A'),
    // AV_CODEC_ID_XFACE = MKBETAG('X', 'F', 'A', 'C'),
    // AV_CODEC_ID_SGIRLE = MKBETAG('S', 'G', 'I', 'R'),
    // AV_CODEC_ID_MVC1 = MKBETAG('M', 'V', 'C', '1'),
    // AV_CODEC_ID_MVC2 = MKBETAG('M', 'V', 'C', '2'),

    // * various PCM "codecs" *)
    AV_CODEC_ID_FIRST_AUDIO = $10000,
    /// < A dummy id pointing at the start of audio codecs
    AV_CODEC_ID_PCM_S16LE = $10000, AV_CODEC_ID_PCM_S16BE,
    AV_CODEC_ID_PCM_U16LE, AV_CODEC_ID_PCM_U16BE, AV_CODEC_ID_PCM_S8,
    AV_CODEC_ID_PCM_U8, AV_CODEC_ID_PCM_MULAW, AV_CODEC_ID_PCM_ALAW,
    AV_CODEC_ID_PCM_S32LE, AV_CODEC_ID_PCM_S32BE, AV_CODEC_ID_PCM_U32LE,
    AV_CODEC_ID_PCM_U32BE, AV_CODEC_ID_PCM_S24LE, AV_CODEC_ID_PCM_S24BE,
    AV_CODEC_ID_PCM_U24LE, AV_CODEC_ID_PCM_U24BE, AV_CODEC_ID_PCM_S24DAUD,
    AV_CODEC_ID_PCM_ZORK, AV_CODEC_ID_PCM_S16LE_PLANAR, AV_CODEC_ID_PCM_DVD,
    AV_CODEC_ID_PCM_F32BE, AV_CODEC_ID_PCM_F32LE, AV_CODEC_ID_PCM_F64BE,
    AV_CODEC_ID_PCM_F64LE, AV_CODEC_ID_PCM_BLURAY, AV_CODEC_ID_PCM_LXF,
    AV_CODEC_ID_S302M, AV_CODEC_ID_PCM_S8_PLANAR,

    // TODO ############################
    // AV_CODEC_ID_PCM_S24LE_PLANAR = MKBETAG(24, 'P', 'S', 'P'),
    // AV_CODEC_ID_PCM_S32LE_PLANAR = MKBETAG(32, 'P', 'S', 'P'),
    // AV_CODEC_ID_PCM_S16BE_PLANAR = MKBETAG('P', 'S', 'P', 16),

    // * various ADPCM codecs *)
    AV_CODEC_ID_ADPCM_IMA_QT = $11000, AV_CODEC_ID_ADPCM_IMA_WAV,
    AV_CODEC_ID_ADPCM_IMA_DK3, AV_CODEC_ID_ADPCM_IMA_DK4,
    AV_CODEC_ID_ADPCM_IMA_WS, AV_CODEC_ID_ADPCM_IMA_SMJPEG,
    AV_CODEC_ID_ADPCM_MS, AV_CODEC_ID_ADPCM_4XM, AV_CODEC_ID_ADPCM_XA,
    AV_CODEC_ID_ADPCM_ADX, AV_CODEC_ID_ADPCM_EA, AV_CODEC_ID_ADPCM_G726,
    AV_CODEC_ID_ADPCM_CT, AV_CODEC_ID_ADPCM_SWF, AV_CODEC_ID_ADPCM_YAMAHA,
    AV_CODEC_ID_ADPCM_SBPRO_4, AV_CODEC_ID_ADPCM_SBPRO_3,
    AV_CODEC_ID_ADPCM_SBPRO_2, AV_CODEC_ID_ADPCM_THP, AV_CODEC_ID_ADPCM_IMA_AMV,
    AV_CODEC_ID_ADPCM_EA_R1, AV_CODEC_ID_ADPCM_EA_R3, AV_CODEC_ID_ADPCM_EA_R2,
    AV_CODEC_ID_ADPCM_IMA_EA_SEAD, AV_CODEC_ID_ADPCM_IMA_EA_EACS,
    AV_CODEC_ID_ADPCM_EA_XAS, AV_CODEC_ID_ADPCM_EA_MAXIS_XA,
    AV_CODEC_ID_ADPCM_IMA_ISS, AV_CODEC_ID_ADPCM_G722,
    AV_CODEC_ID_ADPCM_IMA_APC,

    // TODO
    // AV_CODEC_ID_VIMA = MKBETAG('V', 'I', 'M', 'A'),
    // AV_CODEC_ID_ADPCM_AFC = MKBETAG('A', 'F', 'C', ' '),
    // AV_CODEC_ID_ADPCM_IMA_OKI = MKBETAG('O', 'K', 'I', ' '),

    // * AMR *)
    AV_CODEC_ID_AMR_NB = $12000, AV_CODEC_ID_AMR_WB,

    // * RealAudio codecs*)
    AV_CODEC_ID_RA_144 = $13000, AV_CODEC_ID_RA_288,

    // * various DPCM codecs *)
    AV_CODEC_ID_ROQ_DPCM = $14000, AV_CODEC_ID_INTERPLAY_DPCM,
    AV_CODEC_ID_XAN_DPCM, AV_CODEC_ID_SOL_DPCM,

    // * audio codecs *)
    AV_CODEC_ID_MP2 = $15000, AV_CODEC_ID_MP3,
    /// < preferred ID for decoding MPEG audio layer 1, 2 or 3
    AV_CODEC_ID_AAC, AV_CODEC_ID_AC3, AV_CODEC_ID_DTS, AV_CODEC_ID_VORBIS,
    AV_CODEC_ID_DVAUDIO, AV_CODEC_ID_WMAV1, AV_CODEC_ID_WMAV2,
    AV_CODEC_ID_MACE3, AV_CODEC_ID_MACE6, AV_CODEC_ID_VMDAUDIO,
    AV_CODEC_ID_FLAC, AV_CODEC_ID_MP3ADU, AV_CODEC_ID_MP3ON4,
    AV_CODEC_ID_SHORTEN, AV_CODEC_ID_ALAC, AV_CODEC_ID_WESTWOOD_SND1,
    AV_CODEC_ID_GSM,
    /// < as in Berlin toast format
    AV_CODEC_ID_QDM2, AV_CODEC_ID_COOK, AV_CODEC_ID_TRUESPEECH, AV_CODEC_ID_TTA,
    AV_CODEC_ID_SMACKAUDIO, AV_CODEC_ID_QCELP, AV_CODEC_ID_WAVPACK,
    AV_CODEC_ID_DSICINAUDIO, AV_CODEC_ID_IMC, AV_CODEC_ID_MUSEPACK7,
    AV_CODEC_ID_MLP, AV_CODEC_ID_GSM_MS, (* as found in WAV *)
    AV_CODEC_ID_ATRAC3, AV_CODEC_ID_VOXWARE, AV_CODEC_ID_APE,
    AV_CODEC_ID_NELLYMOSER, AV_CODEC_ID_MUSEPACK8, AV_CODEC_ID_SPEEX,
    AV_CODEC_ID_WMAVOICE, AV_CODEC_ID_WMAPRO, AV_CODEC_ID_WMALOSSLESS,
    AV_CODEC_ID_ATRAC3P, AV_CODEC_ID_EAC3, AV_CODEC_ID_SIPR, AV_CODEC_ID_MP1,
    AV_CODEC_ID_TWINVQ, AV_CODEC_ID_TRUEHD, AV_CODEC_ID_MP4ALS,
    AV_CODEC_ID_ATRAC1, AV_CODEC_ID_BINKAUDIO_RDFT, AV_CODEC_ID_BINKAUDIO_DCT,
    AV_CODEC_ID_AAC_LATM, AV_CODEC_ID_QDMC, AV_CODEC_ID_CELT,
    AV_CODEC_ID_G723_1, AV_CODEC_ID_G729, AV_CODEC_ID_8SVX_EXP,
    AV_CODEC_ID_8SVX_FIB, AV_CODEC_ID_BMV_AUDIO, AV_CODEC_ID_RALF,
    AV_CODEC_ID_IAC, AV_CODEC_ID_ILBC, AV_CODEC_ID_OPUS_DEPRECATED,
    AV_CODEC_ID_COMFORT_NOISE, AV_CODEC_ID_TAK_DEPRECATED,

    // AV_CODEC_ID_FFWAVESYNTH = MKBETAG('F', 'F','W', 'S'),
{$IF LIBAVCODEC_VERSION_MAJOR <= 54}
    // AV_CODEC_ID_8SVX_RAW = MKBETAG('8', 'S', 'V', 'X'),
{$IFEND}
    // AV_CODEC_ID_SONIC = MKBETAG('S', 'O', 'N', 'C'),
    // AV_CODEC_ID_SONIC_LS = MKBETAG('S', 'O', 'N', 'L'),
    // AV_CODEC_ID_PAF_AUDIO = MKBETAG('P', 'A', 'F', 'A'),
    // AV_CODEC_ID_OPUS = MKBETAG('O', 'P', 'U', 'S'),
    // AV_CODEC_ID_TAK = MKBETAG('t','B', 'a', 'K'),
    // AV_CODEC_ID_EVRC = MKBETAG('s', 'e', 'v', 'c'),
    // AV_CODEC_ID_SMV = MKBETAG('s', 's', 'm', 'v'),

    // * subtitle codecs *)
    AV_CODEC_ID_FIRST_SUBTITLE = $17000,
    /// < A dummy ID pointing at the start of subtitle codecs.
    AV_CODEC_ID_DVD_SUBTITLE = $17000, AV_CODEC_ID_DVB_SUBTITLE,
    AV_CODEC_ID_TEXT,
    /// < raw UTF-8 text
    AV_CODEC_ID_XSUB, AV_CODEC_ID_SSA, AV_CODEC_ID_MOV_TEXT,
    AV_CODEC_ID_HDMV_PGS_SUBTITLE, AV_CODEC_ID_DVB_TELETEXT, AV_CODEC_ID_SRT,

    // AV_CODEC_ID_MICRODVD = MKBETAG('m', 'D', 'V', 'D'),
    // AV_CODEC_ID_EIA_608 = MKBETAG('c', '6', '0', '8'),
    // AV_CODEC_ID_JACOSUB = MKBETAG('J', 'S', 'U', 'B'),
    // AV_CODEC_ID_SAMI = MKBETAG('S', 'A', 'M', 'I'),
    // AV_CODEC_ID_REALTEXT = MKBETAG('R', 'T', 'X', 'T'),
    // AV_CODEC_ID_SUBVIEWER1 = MKBETAG('S', 'b', 'V', '1'),
    // AV_CODEC_ID_SUBVIEWER = MKBETAG('S', 'u', 'b', 'V'),
    // AV_CODEC_ID_SUBRIP = MKBETAG('S', 'R', 'i', 'p'),
    // AV_CODEC_ID_WEBVTT = MKBETAG('W', 'V', 'T', 'T'),
    // AV_CODEC_ID_MPL2 = MKBETAG('M', 'P', 'L', '2'),
    // AV_CODEC_ID_VPLAYER = MKBETAG('V', 'P', 'l', 'r'),
    // AV_CODEC_ID_PJS = MKBETAG('P', 'h', 'J', 'S'),

    // * other specific kind of codecs (generally used for attachments) *)
    AV_CODEC_ID_FIRST_UNKNOWN = $18000,
    /// < A dummy ID pointing at the start of various fake codecs.
    AV_CODEC_ID_TTF = $18000,

    // AV_CODEC_ID_BINTEXT = MKBETAG('B', 'T', 'X', 'T'),
    // AV_CODEC_ID_XBIN = MKBETAG('X', 'B', 'I', 'N'),
    // AV_CODEC_ID_IDF = MKBETAG(0,'I', 'D', 'F'),
    // AV_CODEC_ID_OTF = MKBETAG(0, 'O', 'T', 'F'),
    // AV_CODEC_ID_SMPTE_KLV = MKBETAG('K', 'L', 'V', 'A'),

    AV_CODEC_ID_PROBE = $19000,
    /// < codec_id is not known (like AV_CODEC_ID_NONE) but lavf should attempt to identify it

    AV_CODEC_ID_MPEG2TS = $20000,
    // **< _FAKE_ codec to indicate a raw MPEG-2 TS * stream (only used by libavformat) *)
    AV_CODEC_ID_MPEG4SYSTEMS = $20001,
    // **< _FAKE_ codec to indicate a MPEG-4 Systems * stream (only used by libavformat) *)
    AV_CODEC_ID_FFMETADATA = $21000
    /// < Dummy codec for streams containing only metadata information.
{$IF FF_API_CODEC_ID }
    , {$I "old_codec_ids.inc"}
{$ENDIF}
  );

{$IF FF_API_CODEC_ID}
  CodecID = AVCodecID;
{$IFEND}

  (* *
    * This struct describes the properties of a single codec described by an
    * AVCodecID.
    * @see avcodec_get_descriptor()
  *)
  AVCodecDescriptor = record
    id: AVCodecID;
    avtype: AVMediaType;
    (* *
      * Name of the codec described by this descriptor. It is non-empty and
      * unique for each codec descriptor. It should contain alphanumeric
      * characters and '_' only.
    *)
    name: pcchar;
    (* *
      * A more descriptive name for this codec. May be NULL.
    *)
    long_name: pcchar;
    (* *
      * Codec properties, a combination of AV_CODEC_PROP_* flags.
    *)
    props: cint;
  end;

  (* *
    * @ingroup lavc_encoding
    * motion estimation type.
  *)
  Motion_Est_ID = (ME_ZERO = 1,
    /// < no search, that is use 0,0 vector whenever one is needed
    ME_FULL, ME_LOG, ME_PHODS, ME_EPZS,
    /// < enhanced predictive zonal search
    ME_X1,
    /// < reserved for experiments
    ME_HEX,
    /// < hexagon based search
    ME_UMH,
    /// < uneven multi-hexagon search
    ME_ITER,
    /// < iterative search
    ME_TESA
    /// < transformed exhaustive search algorithm
    );

  (* *
    * @ingroup lavc_decoding
  *)
  AVDiscard = (
    (* We leave some space between them for extensions (drop some
      * keyframes for intra-only or drop just some bidir frames). *)
    AVDISCARD_NONE = -16,
    /// < discard nothing
    AVDISCARD_DEFAULT = 0,
    /// < discard useless packets like 0 size packets in avi
    AVDISCARD_NONREF = 8,
    /// < discard all non reference
    AVDISCARD_BIDIR = 16,
    /// < discard all bidirectional frames
    AVDISCARD_NONKEY = 32,
    /// < discard all frames except keyframes
    AVDISCARD_ALL = 48
    /// < discard all
    );

  AVColorPrimaries = (AVCOL_PRI_BT709 = 1,
    /// < also ITU-R BT1361 / IEC 61966-2-4 / SMPTE RP177 Annex B
    AVCOL_PRI_UNSPECIFIED = 2, AVCOL_PRI_BT470M = 4, AVCOL_PRI_BT470BG = 5,
    /// < also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM
    AVCOL_PRI_SMPTE170M = 6,
    /// < also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC
    AVCOL_PRI_SMPTE240M = 7,
    /// < functionally identical to above
    AVCOL_PRI_FILM = 8, AVCOL_PRI_NB
    /// < Not part of ABI
    );

  AVColorTransferCharacteristic = (AVCOL_TRC_BT709 = 1,
    /// < also ITU-R BT1361
    AVCOL_TRC_UNSPECIFIED = 2, AVCOL_TRC_GAMMA22 = 4,
    /// < also ITU-R BT470M / ITU-R BT1700 625 PAL & SECAM
    AVCOL_TRC_GAMMA28 = 5,
    /// < also ITU-R BT470BG
    AVCOL_TRC_SMPTE240M = 7, AVCOL_TRC_NB
    /// < Not part of ABI
    );

  AVColorSpace = (AVCOL_SPC_RGB = 0, AVCOL_SPC_BT709 = 1,
    /// < also ITU-R BT1361 / IEC 61966-2-4 xvYCC709 / SMPTE RP177 Annex B
    AVCOL_SPC_UNSPECIFIED = 2, AVCOL_SPC_FCC = 4, AVCOL_SPC_BT470BG = 5,
    /// < also ITU-R BT601-6 625 / ITU-R BT1358 625 / ITU-R BT1700 625 PAL & SECAM / IEC 61966-2-4 xvYCC601
    AVCOL_SPC_SMPTE170M = 6,
    /// < also ITU-R BT601-6 525 / ITU-R BT1358 525 / ITU-R BT1700 NTSC / functionally identical to above
    AVCOL_SPC_SMPTE240M = 7, AVCOL_SPC_YCOCG = 8,
    /// < Used by Dirac / VC-2 and H.264 FRext, see ITU-T SG16
    AVCOL_SPC_NB
    /// < Not part of ABI
    );

  AVCOL_SPC_YCGCO = AVCOL_SPC_YCOCG;

  AVColorRange = (AVCOL_RANGE_UNSPECIFIED = 0, AVCOL_RANGE_MPEG = 1,
    /// < the normal 219*2^(n-8) "MPEG" YUV ranges
    AVCOL_RANGE_JPEG = 2,
    /// < the normal     2^n-1   "JPEG" YUV ranges
    AVCOL_RANGE_NB
    /// < Not part of ABI
    );

  (* *
    *  X   X      3 4 X      X are luma samples,
    *             1 2        1-6 are possible chroma positions
    *  X   X      5 6 X      0 is undefined/unknown position
  *)
  AVChromaLocation = (AVCHROMA_LOC_UNSPECIFIED = 0, AVCHROMA_LOC_LEFT = 1,
    /// < mpeg2/4, h264 default
    AVCHROMA_LOC_CENTER = 2,
    /// < mpeg1, jpeg, h263
    AVCHROMA_LOC_TOPLEFT = 3,
    /// < DV
    AVCHROMA_LOC_TOP = 4, AVCHROMA_LOC_BOTTOMLEFT = 5, AVCHROMA_LOC_BOTTOM = 6,
    AVCHROMA_LOC_NB
    /// < Not part of ABI
    );

  AVAudioServiceType = (AV_AUDIO_SERVICE_TYPE_MAIN = 0,
    AV_AUDIO_SERVICE_TYPE_EFFECTS = 1,
    AV_AUDIO_SERVICE_TYPE_VISUALLY_IMPAIRED = 2,
    AV_AUDIO_SERVICE_TYPE_HEARING_IMPAIRED = 3,
    AV_AUDIO_SERVICE_TYPE_DIALOGUE = 4, AV_AUDIO_SERVICE_TYPE_COMMENTARY = 5,
    AV_AUDIO_SERVICE_TYPE_EMERGENCY = 6, AV_AUDIO_SERVICE_TYPE_VOICE_OVER = 7,
    AV_AUDIO_SERVICE_TYPE_KARAOKE = 8, AV_AUDIO_SERVICE_TYPE_NB
    /// < Not part of ABI
    );

  (* *
    * @ingroup lavc_encoding
  *)
  RcOverride = record
    start_frame: cint;
    end_frame: cint;
    qscale: cint;
    // If this is 0 then quality_factor will be used instead.
    quality_factor: cfloat;
  end;

  (* *
    * Pan Scan area.
    * This specifies the area which should be displayed.
    * Note there may be multiple such areas for one frame.
  *)
  AVPanScan = record
    (* *
      * id
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    id: cint;

    (* *
      * width and height in 1/16 pel
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    width: cint;
    height: cint;

    (* *
      * position of the top left corner in 1/16 pel for up to 3 fields/frames
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    position: array [0 .. 2, 0 .. 1] of cint16;
  end;

  (* *
    * @defgroup lavc_packet AVPacket
    *
    * Types and functions for working with AVPacket.
    * @{
  *)
  AVPacketSideDataType = (AV_PKT_DATA_PALETTE, AV_PKT_DATA_NEW_EXTRADATA,

    (* *
      * An AV_PKT_DATA_PARAM_CHANGE side data packet is laid out as follows:
      * @code
      * u32le param_flags
      * if (param_flags & AV_SIDE_DATA_PARAM_CHANGE_CHANNEL_COUNT)
      *     s32le channel_count
      * if (param_flags & AV_SIDE_DATA_PARAM_CHANGE_CHANNEL_LAYOUT)
      *     u64le channel_layout
      * if (param_flags & AV_SIDE_DATA_PARAM_CHANGE_SAMPLE_RATE)
      *     s32le sample_rate
      * if (param_flags & AV_SIDE_DATA_PARAM_CHANGE_DIMENSIONS)
      *     s32le width
      *     s32le height
      * @endcode
    *)
    AV_PKT_DATA_PARAM_CHANGE,

    (* *
      * An AV_PKT_DATA_H263_MB_INFO side data packet contains a number of
      * structures with info about macroblocks relevant to splitting the
      * packet into smaller packets on macroblock edges (e.g. as for RFC 2190).
      * That is, it does not necessarily contain info about all macroblocks,
      * as long as the distance between macroblocks in the info is smaller
      * than the target payload size.
      * Each MB info structure is 12 bytes, and is laid out as follows:
      * @code
      * u32le bit offset from the start of the packet
      * u8    current quantizer at the start of the macroblock
      * u8    GOB number
      * u16le macroblock address within the GOB
      * u8    horizontal MV predictor
      * u8    vertical MV predictor
      * u8    horizontal MV predictor for block number 3
      * u8    vertical MV predictor for block number 3
      * @endcode
    *)
    AV_PKT_DATA_H263_MB_INFO,

    (* *
      * Recommmends skipping the specified number of samples
      * @code
      * u32le number of samples to skip from start of this packet
      * u32le number of samples to skip from end of this packet
      * u8    reason for start skip
      * u8    reason for end   skip (0=padding silence, 1=convergence)
      * @endcode
    *)
    AV_PKT_DATA_SKIP_SAMPLES = 70,

    (* *
      * An AV_PKT_DATA_JP_DUALMONO side data packet indicates that
      * the packet may contain "dual mono" audio specific to Japanese DTV
      * and if it is true, recommends only the selected channel to be used.
      * @code
      * u8    selected channels (0=mail/left, 1=sub/right, 2=both)
      * @endcode
    *)
    AV_PKT_DATA_JP_DUALMONO,

    (* *
      * A list of zero terminated key/value strings. There is no end marker for
      * the list, so it is required to rely on the side data size to stop.
    *)
    AV_PKT_DATA_STRINGS_METADATA,

    (* *
      * Subtitle event position
      * @code
      * u32le x1
      * u32le y1
      * u32le x2
      * u32le y2
      * @endcode
    *)
    AV_PKT_DATA_SUBTITLE_POSITION,

    (* *
      * Data found in BlockAdditional element of matroska container. There is
      * no end marker for the data, so it is required to rely on the side data
      * size to recognize the end. 8 byte id (as found in BlockAddId) followed
      * by data.
    *)
    AV_PKT_DATA_MATROSKA_BLOCKADDITIONAL);

  PSideData = ^TSideData;

  TSideData = record
    data: cuint8;
    size: cint;
    avtype: AVPacketSideDataType;
  end;

  PDestructFunc = procedure(avp: PAVPacket);

  (* *
    * This structure stores compressed data. It is typically exported by demuxers
    * and then passed as input to decoders, or received as output from encoders and
    * then passed to muxers.
    *
    * For video, it should typically contain one compressed frame. For audio it may
    * contain several compressed frames.
    *
    * AVPacket is one of the few structs in FFmpeg, whose size is a part of public
    * ABI. Thus it may be allocated on stack and no new fields can be added to it
    * without libavcodec and libavformat major bump.
    *
    * The semantics of data ownership depends on the destruct field.
    * If it is set, the packet data is dynamically allocated and is valid
    * indefinitely until av_free_packet() is called (which in turn calls the
    * destruct callback to free the data). If destruct is not set, the packet data
    * is typically backed by some static buffer somewhere and is only valid for a
    * limited time (e.g. until the next read call when demuxing).
    *
    * The side data is always allocated with av_malloc() and is freed in
    * av_free_packet().
  *)
  AVPacket = record
    (* *
      * Presentation timestamp in AVStream->time_base units; the time at which
      * the decompressed packet will be presented to the user.
      * Can be AV_NOPTS_VALUE if it is not stored in the file.
      * pts MUST be larger or equal to dts as presentation cannot happen before
      * decompression, unless one wants to view hex dumps. Some formats misuse
      * the terms dts and pts/cts to mean something different. Such timestamps
      * must be converted to true pts/dts before they are stored in AVPacket.
    *)
    pts: cint64;
    (* *
      * Decompression timestamp in AVStream->time_base units; the time at which
      * the packet is decompressed.
      * Can be AV_NOPTS_VALUE if it is not stored in the file.
    *)
    dts: cint64;
    data: cuint8;
    asize: cint;
    stream_index: cint;
    (* *
      * A combination of AV_PKT_FLAG values
    *)
    flags: cint;
    (* *
      * Additional packet data that can be provided by the container.
      * Packet can contain several types of side information.
    *)
    side_data: PSideData;

    side_data_elems: cint;

    (* *
      * Duration of this packet in AVStream->time_base units, 0 if unknown.
      * Equals next_pts - this_pts in presentation order.
    *)
    duration: cint;
    destruct: PDestructFunc;

    priv: Pointer;
    pos: cint64;
    /// < byte position in stream, -1 if unknown

    (* *
      * Time difference in AVStream->time_base units from the pts of this
      * packet to the point at which the output from the decoder has converged
      * independent from the availability of previous frames. That is, the
      * frames are virtually identical no matter if decoding started from
      * the very first frame or from this keyframe.
      * Is AV_NOPTS_VALUE if unknown.
      * This field is not the display duration of the current packet.
      * This field has no meaning if the packet does not have AV_PKT_FLAG_KEY
      * set.
      *
      * The purpose of this field is to allow seeking in streams that have no
      * keyframes in the conventional sense. It corresponds to the
      * recovery point SEI in H.264 and match_time_delta in NUT. It is also
      * essential for some types of subtitle streams to ensure that all
      * subtitles are correctly displayed after seeking.
    *)
    convergence_duration: cint64;
  end;

  AVSideDataParamChangeFlags = (AV_SIDE_DATA_PARAM_CHANGE_CHANNEL_COUNT = $0001,
    AV_SIDE_DATA_PARAM_CHANGE_CHANNEL_LAYOUT = $0002,
    AV_SIDE_DATA_PARAM_CHANGE_SAMPLE_RATE = $0004,
    AV_SIDE_DATA_PARAM_CHANGE_DIMENSIONS = $0008);

  PMotionArry = ^MotionArry;
  MotionArry = array [0 .. 1] of cint16;

  (* *
    * This structure describes decoded (raw) audio or video data.
    *
    * AVFrame must be allocated using avcodec_alloc_frame() and freed with
    * avcodec_free_frame(). Note that this allocates only the AVFrame itself. The
    * buffers for the data must be managed through other means.
    *
    * AVFrame is typically allocated once and then reused multiple times to hold
    * different data (e.g. a single AVFrame to hold frames received from a
    * decoder). In such a case, avcodec_get_frame_defaults() should be used to
    * reset the frame to its original clean state before it is reused again.
    *
    * sizeof(AVFrame) is not a part of the public ABI, so new fields may be added
    * to the end with a minor bump.
    * Similarly fields that are marked as to be only accessed by
    * av_opt_ptr() can be reordered. This allows 2 forks to add fields
    * without breaking compatibility with each other.
  *)
  AVFrame = record

    (* *
      * pointer to the picture/channel planes.
      * This might be different from the first allocated byte
      * - encoding: Set by user
      * - decoding: set by AVCodecContext.get_buffer()
    *)
    data: array [0 .. AV_NUM_DATA_POINTERS - 1] of pcuint8;

    (* *
      * Size, in bytes, of the data for each picture/channel plane.
      *
      * For audio, only linesize[0] may be set. For planar audio, each channel
      * plane must be the same size.
      *
      * - encoding: Set by user
      * - decoding: set by AVCodecContext.get_buffer()
    *)
    linesize: array [0 .. AV_NUM_DATA_POINTERS - 1] of cint;

    (* *
      * pointers to the data planes/channels.
      *
      * For video, this should simply point to data[].
      *
      * For planar audio, each channel has a separate data pointer, and
      * linesize[0] contains the size of each channel buffer.
      * For packed audio, there is just one data pointer, and linesize[0]
      * contains the total size of the buffer for all channels.
      *
      * Note: Both data and extended_data will always be set by get_buffer(),
      * but for planar audio with more channels that can fit in data,
      * extended_data must be used by the decoder in order to access all
      * channels.
      *
      * encoding: set by user
      * decoding: set by AVCodecContext.get_buffer()
    *)
    extended_data: array of pcuint8;

    (* *
      * width and height of the video frame
      * - encoding: unused
      * - decoding: Read by user.
    *)
    width, height: cint;

    (* *
      * number of audio samples (per channel) described by this frame
      * - encoding: Set by user
      * - decoding: Set by libavcodec
    *)
    nb_samples: cint;

    (* *
      * format of the frame, -1 if unknown or unset
      * Values correspond to enum AVPixelFormat for video frames,
      * enum AVSampleFormat for audio)
      * - encoding: unused
      * - decoding: Read by user.
    *)
    format: cint;

    (* *
      * 1 -> keyframe, 0-> not
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    key_frame: cint;

    (* *
      * Picture type of the frame, see ?_TYPE below.
      * - encoding: Set by libavcodec. for coded_picture (and set by user for input).
      * - decoding: Set by libavcodec.
    *)
    pict_type: AVPictureType;

    (* *
      * pointer to the first allocated byte of the picture. Can be used in get_buffer/release_buffer.
      * This isn't used by libavcodec unless the default get/release_buffer() is used.
      * - encoding:
      * - decoding:
    *)
    base: array [0 .. AV_NUM_DATA_POINTERS - 1] of pcuint8;

    (* *
      * sample aspect ratio for the video frame, 0/1 if unknown/unspecified
      * - encoding: unused
      * - decoding: Read by user.
    *)
    sample_aspect_ratio: AVRational;

    (* *
      * presentation timestamp in time_base units (time when frame should be shown to user)
      * If AV_NOPTS_VALUE then frame_rate = 1/time_base will be assumed.
      * - encoding: MUST be set by user.
      * - decoding: Set by libavcodec.
    *)
    pts: cint64;

    (* *
      * pts copied from the AVPacket that was decoded to produce this frame
      * - encoding: unused
      * - decoding: Read by user.
    *)
    pkt_pts: cint64;

    (* *
      * dts copied from the AVPacket that triggered returning this frame
      * - encoding: unused
      * - decoding: Read by user.
    *)
    pkt_dts: cint64;

    (* *
      * picture number in bitstream order
      * - encoding: set by
      * - decoding: Set by libavcodec.
    *)
    coded_picture_number: cint;
    (* *
      * picture number in display order
      * - encoding: set by
      * - decoding: Set by libavcodec.
    *)
    display_picture_number: cint;

    (* *
      * quality (between 1 (good) and FF_LAMBDA_MAX (bad))
      * - encoding: Set by libavcodec. for coded_picture (and set by user for input).
      * - decoding: Set by libavcodec.
    *)
    quality: cint;

    (* *
      * is this picture used as reference
      * The values for this are the same as the MpegEncContext.picture_structure
      * variable, that is 1->top field, 2->bottom field, 3->frame/both fields.
      * Set to 4 for delayed, non-reference frames.
      * - encoding: unused
      * - decoding: Set by libavcodec. (before get_buffer() call)).
    *)
    reference: cint;

    (* *
      * QP table
      * - encoding: unused
      * - decoding: Set by libavcodec.
    *)
    qscale_table: pcint8;
    (* *
      * QP store stride
      * - encoding: unused
      * - decoding: Set by libavcodec.
    *)
    qstride: cint;

    (* *
      *
    *)
    qscale_type: cint;

    (* *
      * mbskip_table[mb]>=1 if MB didn't change
      * stride= mb_width = (width+15)>>4
      * - encoding: unused
      * - decoding: Set by libavcodec.
    *)
    mbskip_table: pcuint8;

    (* *
      * motion vector table
      * @code
      * example:
      * int mv_sample_log2= 4 - motion_subsample_log2;
      * int mb_width= (width+15)>>4;
      * int mv_stride= (mb_width << mv_sample_log2) + 1;
      * motion_val[direction][x + y*mv_stride][0->mv_x, 1->mv_y];
      * @endcode
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    motion_val: array [0 .. 1] of PMotionArry;
    // int16_t (*motion_val[2])[2];   //定义一个数组 motion_val，其内部为2个数组的指针，分别指向int16_t (*)//[2]数组类型

    (* *
      * macroblock type table
      * mb_type_base + mb_width + 2
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    mb_type: pcuint32;

    (* *
      * DCT coefficients
      * - encoding: unused
      * - decoding: Set by libavcodec.
    *)
    dct_coeff: pcshort;

    (* *
      * motion reference frame index
      * the order in which these are stored can depend on the codec.
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    ref_index: array [0 .. 1] of cint8;

    (* *
      * for some private data of the user
      * - encoding: unused
      * - decoding: Set by user.
    *)
    opaque: Pointer;

    (* *
      * error
      * - encoding: Set by libavcodec. if flags&CODEC_FLAG_PSNR.
      * - decoding: unused
    *)
    error: array [0 .. AV_NUM_DATA_POINTERS - 1] of cuint64;

    (* *
      * type of the buffer (to keep track of who has to deallocate data[*])
      * - encoding: Set by the one who allocates it.
      * - decoding: Set by the one who allocates it.
      * Note: User allocated (direct rendering) & internal buffers cannot coexist currently.
    *)
    atype: cint;

    (* *
      * When decoding, this signals how much the picture must be delayed.
      * extra_delay = repeat_pict / (2*fps)
      * - encoding: unused
      * - decoding: Set by libavcodec.
    *)
    repeat_pict: cint;

    (* *
      * The content of the picture is interlaced.
      * - encoding: Set by user.
      * - decoding: Set by libavcodec. (default 0)
    *)
    interlaced_frame: cint;

    (* *
      * If the content is interlaced, is top field displayed first.
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    top_field_first: cint;

    (* *
      * Tell user application that palette has changed from previous frame.
      * - encoding: ??? (no palette-enabled encoder yet)
      * - decoding: Set by libavcodec. (default 0).
    *)
    palette_has_changed: cint;

    (* *
      * codec suggestion on buffer type if != 0
      * - encoding: unused
      * - decoding: Set by libavcodec. (before get_buffer() call)).
    *)
    buffer_hints: cint;

    (* *
      * Pan scan.
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    pan_scan: PAVPanScan;

    (* *
      * reordered opaque 64bit (generally an integer or a double precision float
      * PTS but can be anything).
      * The user sets AVCodecContext.reordered_opaque to represent the input at
      * that time,
      * the decoder reorders values as needed and sets AVFrame.reordered_opaque
      * to exactly one of the values provided by the user through AVCodecContext.reordered_opaque
      * @deprecated in favor of pkt_pts
      * - encoding: unused
      * - decoding: Read by user.
    *)
    reordered_opaque: cint64;

    (* *
      * hardware accelerator private data (FFmpeg-allocated)
      * - encoding: unused
      * - decoding: Set by libavcodec
    *)
    hwaccel_picture_private: Pointer;

    (* *
      * the AVCodecContext which ff_thread_get_buffer() was last called on
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    owner: PAVCodecContext;

    (* *
      * used by multithreading to store frame-specific info
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    thread_opaque: Pointer;

    (* *
      * log2 of the size of the block which a single vector in motion_val represents:
      * (4->16x16, 3->8x8, 2-> 4x4, 1-> 2x2)
      * - encoding: unused
      * - decoding: Set by libavcodec.
    *)
    motion_subsample_log2: cuint8;

    (* *
      * Sample rate of the audio data.
      *
      * - encoding: unused
      * - decoding: read by user
    *)
    sample_rate: cint;

    (* *
      * Channel layout of the audio data.
      *
      * - encoding: unused
      * - decoding: read by user.
    *)
    channel_layout: cuint64;

    (* *
      * frame timestamp estimated using various heuristics, in stream time base
      * Code outside libavcodec should access this field using:
      * av_frame_get_best_effort_timestamp(frame)
      * - encoding: unused
      * - decoding: set by libavcodec, read by user.
    *)
    best_effort_timestamp: cint64;

    (* *
      * reordered pos from the last AVPacket that has been input into the decoder
      * Code outside libavcodec should access this field using:
      * av_frame_get_pkt_pos(frame)
      * - encoding: unused
      * - decoding: Read by user.
    *)
    pkt_pos: cint64;

    (* *
      * duration of the corresponding packet, expressed in
      * AVStream->time_base units, 0 if unknown.
      * Code outside libavcodec should access this field using:
      * av_frame_get_pkt_duration(frame)
      * - encoding: unused
      * - decoding: Read by user.
    *)
    pkt_duration: cint64;

    (* *
      * metadata.
      * Code outside libavcodec should access this field using:
      * av_frame_get_metadata(frame)
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    metadata: PAVDictionary;

    (* *
      * decode error flags of the frame, set to a combination of
      * FF_DECODE_ERROR_xxx flags if the decoder produced a frame, but there
      * were errors during the decoding.
      * Code outside libavcodec should access this field using:
      * av_frame_get_decode_error_flags(frame)
      * - encoding: unused
      * - decoding: set by libavcodec, read by user.
    *)
    decode_error_flags: cint;

    (* *
      * number of audio channels, only used for audio.
      * Code outside libavcodec should access this field using:
      * av_frame_get_channels(frame)
      * - encoding: unused
      * - decoding: Read by user.
    *)
    channels: cint;

    (* *
      * size of the corresponding packet containing the compressed
      * frame. It must be accessed using av_frame_get_pkt_size() and
      * av_frame_set_pkt_size().
      * It is set to a negative value if unknown.
      * - encoding: unused
      * - decoding: set by libavcodec, read by user.
    *)
    pkt_size: cint;
  end;

  AVCodecInternal = record
  end;

  PAVFrame = ^AVFrame;

  PAVCodecContext = ^AVCodecContext;

  AVFieldOrder = (AV_FIELD_UNKNOWN, AV_FIELD_PROGRESSIVE, AV_FIELD_TT,
    // < Top coded_first, top displayed first
    AV_FIELD_BB, // < Bottom coded first, bottom displayed first
    AV_FIELD_TB, // < Top coded first, bottom displayed first
    AV_FIELD_BT // < Bottom coded first, top displayed first
    );

  PDrawHorizBandFunc = procedure(s: PAVCodecContext; src: PAVFrame;
    offset: array [0 .. AV_NUM_DATA_POINTERS - 1] of cint; y: cint; atype: cint;
    height: cint);

  PGetFormatFunc = function(s: PAVCodecContext; fmt: PAVPixelFormat)
    : AVPixelFormat;

  PGetBufferFunc = function(c: PAVCodecContext; pic: PAVFrame): cint;
  PReleaseBufferFunc = procedure(c: PAVCodecContext; pic: PAVFrame);
  PRegetBufferFunc = function(c: PAVCodecContext; pic: PAVFrame): cint;
  PRtpCallbackFunc = procedure(avctx: PAVCodecContext; data: Pointer;
    asize: cint; mb_nb: cint);
  PExecArgFunc = function(c2: PAVCodecContext; arg: Pointer): cint;
  PExecuteFunc = function(c: PAVCodecContext; func: PExecArgFunc; arg2: Pointer;
    ret: pcint; count: cint; asize: cint): cint;
  PExec2ArgFunc = function(c2: PAVCodecContext; arg: Pointer; jobnr: cint;
    threadnr: cint): cint;
  PExecute2Func = function(c: PAVCodecContext; func: PExec2ArgFunc;
    arg2: Pointer; ret: pcint; count: cint): cint;

  PInitStaticDataProc = procedure(codec: PAVCodec);
  PUpdateThreadContextFunc = function(dst: PAVCodecContext;
    src: PAVCodecContext): cint;
  PInitThreadCopyFunc = function(avctx: PAVCodecContext): cint;
  PInitFunc = function(avctx: PAVCodecContext): cint;
  PEncodeSubFunc = function(avctx: PAVCodecContext; buf: pcuint8;
    buf_size: cint; sub: PAVSubtitle): cint;

  PEncode2Func = function(avctx: PAVCodecContext; avpkt: PAVPacket;
    frame: PAVFrame; got_packet_ptr: pcint): cint;
  PdecodeFunc = function(avctx: PAVCodecContext; outdata: Pointer;
    outdata_size: pcint; avpkt: PAVPacket): cint;
  PCloseFunc = function(avctx: PAVCodecContext): cint;
  PFlushProc = procedure(avctx: PAVCodecContext);
  PEndFrameFunc = function(avctx: PAVCodecContext): cint;

  PDecodeSliceFunc = function(avctx: PAVCodecContext; buf: pcuint8;
    buf_size: cuint32): cint;
  PStartFrameFunc = function(avctx: PAVCodecContext; buf: pcuint8;
    buf_size: cuint32): cint;

  PAvLockmgrRegCbFunc = function(mutex: array of Pointer; op AVLockOp): cint;

  PFilterFunc = function(bsfc: PAVBitStreamFilterContext;
    avctx: PAVCodecContext; args: pcchar; poutbuf: array of pcuint8;
    poutbuf_size: pcint; buf: pcuint8; buf_size: cint; keyframe: cint): cint;
  PCloseProc = procedure(bsfc: PAVBitStreamFilterContext);

  PParserInitFunc = function(s: PAVCodecParserContext): cint;
  PParserParseFunc = function(s: PAVCodecParserContext; avctx: PAVCodecContext;
    poutbuf: ppcuint8; poutbuf_size: pcint; buf: pcuint8; buf_size: cint): cint;
  PParserCloseProc = procedure(s: PAVCodecParserContext);
  PSplitFunc = function(avctx: PAVCodecContext; buf: pcuint8;
    buf_size: cint;): cint;

  PAvcodecDefault2ArgFunc = function(c2: PAVCodecContext; arg2: Pointer;
    a1: cint; a2: cint): cint;
  PAvcodecDefaultArgFunc = function(c2: PAVCodecContext; arg2: Pointer): cint;

  (* *
    * main external API structure.
    * New fields can be added to the end with minor version bumps.
    * Removal, reordering and changes to existing fields require a major
    * version bump.
    * Please use AVOptions (av_opt* / av_set/get*()) to access these fields from user
    * applications.
    * sizeof(AVCodecContext) must not be used outside libav*.
  *)
  AVCodecContext = record
    (* *
      * information on struct for av_log
      * - set by avcodec_alloc_context3
    *)
    av_class: PAVClass;
    log_level_offset: cint;

    codec_type: AVMediaType; (* see AVMEDIA_TYPE_xxx *)
    codec: PAVCodec;
    codec_name: array [0 .. 31] of cchar;
    codec_id: AVCodecID;
    (* see AV_CODEC_ID_xxx *)

    (* *
      * fourcc (LSB first, so "ABCD" -> ('D'<<24) + ('C'<<16) + ('B'<<8) + 'A').
      * This is used to work around some encoder bugs.
      * A demuxer should set this to what is stored in the field used to identify the codec.
      * If there are multiple such fields in a container then the demuxer should choose the one
      * which maximizes the information about the used codec.
      * If the codec tag field in a container is larger than 32 bits then the demuxer should
      * remap the longer ID to 32 bits with a table or other structure. Alternatively a new
      * extra_codec_tag + size could be added but for this a clear advantage must be demonstrated
      * first.
      * - encoding: Set by user, if not then the default based on codec_id will be used.
      * - decoding: Set by user, will be converted to uppercase by libavcodec during init.
    *)
    codec_tag: cuint;

    (* *
      * fourcc from the AVI stream header (LSB first, so "ABCD" -> ('D'<<24) + ('C'<<16) + ('B'<<8) + 'A').
      * This is used to work around some encoder bugs.
      * - encoding: unused
      * - decoding: Set by user, will be converted to uppercase by libavcodec during init.
    *)
    stream_codec_tag: cuint;

{$IF FF_API_SUB_ID}
    (* *
      * @deprecated this field is unused
    *)
    attribute_deprecated int sub_id;
{$IFEND}
    priv_data: Pointer;

    (* *
      * Private context used for internal data.
      *
      * Unlike priv_data, this is not codec-specific. It is used in general
      * libavcodec functions.
    *)
    internal: PAVCodecInternal;

    (* *
      * Private data of the user, can be used to carry app specific stuff.
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    opaque: Pointer;

    (* *
      * the average bitrate
      * - encoding: Set by user; unused for constant quantizer encoding.
      * - decoding: Set by libavcodec. 0 or some bitrate if this info is available in the stream.
    *)
    bit_rate: cint;

    (* *
      * number of bits the bitstream is allowed to diverge from the reference.
      *           the reference can be CBR (for CBR pass1) or VBR (for pass2)
      * - encoding: Set by user; unused for constant quantizer encoding.
      * - decoding: unused
    *)
    bit_rate_tolerance: cint;

    (* *
      * Global quality for codecs which cannot change it per frame.
      * This should be proportional to MPEG-1/2/4 qscale.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    global_quality: cint;

    (* *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    compression_level: cint;

    (* *
      * CODEC_FLAG_*.
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    flags: cint;

    (* *
      * CODEC_FLAG2_*
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    flags2: cint;

    (* *
      * some codecs need / can use extradata like Huffman tables.
      * mjpeg: Huffman tables
      * rv10: additional flags
      * mpeg4: global headers (they can be in the bitstream or here)
      * The allocated memory should be FF_INPUT_BUFFER_PADDING_SIZE bytes larger
      * than extradata_size to avoid prolems if it is read with the bitstream reader.
      * The bytewise contents of extradata must not depend on the architecture or CPU endianness.
      * - encoding: Set/allocated/freed by libavcodec.
      * - decoding: Set/allocated/freed by user.
    *)
    extradata: pcuint8;
    extradata_size: cint;

    (* *
      * This is the fundamental unit of time (in seconds) in terms
      * of which frame timestamps are represented. For fixed-fps content,
      * timebase should be 1/framerate and timestamp increments should be
      * identically 1.
      * - encoding: MUST be set by user.
      * - decoding: Set by libavcodec.
    *)
    time_base: AVRational;

    (* *
      * For some codecs, the time base is closer to the field rate than the frame rate.
      * Most notably, H.264 and MPEG-2 specify time_base as half of frame duration
      * if no telecine is used ...
      *
      * Set to time_base ticks per frame. Default 1, e.g., H.264/MPEG-2 set it to 2.
    *)
    ticks_per_frame: cint;

    (* *
      * Codec delay.
      *
      * Encoding: Number of frames delay there will be from the encoder input to
      *           the decoder output. (we assume the decoder matches the spec)
      * Decoding: Number of frames delay in addition to what a standard decoder
      *           as specified in the spec would produce.
      *
      * Video:
      *   Number of frames the decoded output will be delayed relative to the
      *   encoded input.
      *
      * Audio:
      *   For encoding, this is the number of "priming" samples added to the
      *   beginning of the stream. The decoded output will be delayed by this
      *   many samples relative to the input to the encoder. Note that this
      *   field is purely informational and does not directly affect the pts
      *   output by the encoder, which should always be based on the actual
      *   presentation time, including any delay.
      *   For decoding, this is the number of samples the decoder needs to
      *   output before the decoder's output is valid. When seeking, you should
      *   start decoding this many samples prior to your desired seek point.
      *
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    delay: cint;

    (* video only *)
    (* *
      * picture width / height.
      * - encoding: MUST be set by user.
      * - decoding: Set by libavcodec.
      * Note: For compatibility it is possible to set this instead of
      * coded_width/height before decoding.
    *)
    width, height: cint;

    (* *
      * Bitstream width / height, may be different from width/height if lowres enabled.
      * - encoding: unused
      * - decoding: Set by user before init if known. Codec should override / dynamically change if needed.
    *)
    coded_width, coded_height: cint;

    (* *
      * the number of pictures in a group of pictures, or 0 for intra_only
      * - encoding: Set by user.
      * - decoding: unused
    *)
    gop_size: cint;

    (* *
      * Pixel format, see AV_PIX_FMT_xxx.
      * May be set by the demuxer if known from headers.
      * May be overridden by the decoder if it knows better.
      * - encoding: Set by user.
      * - decoding: Set by user if known, overridden by libavcodec if known
    *)
    pix_fmt: AVPixelFormat;

    (* *
      * Motion estimation algorithm used for video coding.
      * 1 (zero), 2 (full), 3 (log), 4 (phods), 5 (epzs), 6 (x1), 7 (hex),
      * 8 (umh), 9 (iter), 10 (tesa) [7, 8, 10 are x264 specific, 9 is snow specific]
      * - encoding: MUST be set by user.
      * - decoding: unused
    *)
    me_method: cint;

    (* *
      * If non NULL, 'draw_horiz_band' is called by the libavcodec
      * decoder to draw a horizontal band. It improves cache usage. Not
      * all codecs can do that. You must check the codec capabilities
      * beforehand.
      * When multithreading is used, it may be called from multiple threads
      * at the same time; threads might draw different parts of the same AVFrame,
      * or multiple AVFrames, and there is no guarantee that slices will be drawn
      * in order.
      * The function is also used by hardware acceleration APIs.
      * It is called at least once during frame decoding to pass
      * the data needed for hardware render.
      * In that mode instead of pixel data, AVFrame points to
      * a structure specific to the acceleration API. The application
      * reads the structure and can change some fields to indicate progress
      * or mark state.
      * - encoding: unused
      * - decoding: Set by user.
      * @param height the height of the slice
      * @param y the y position of the slice
      * @param type 1->top field, 2->bottom field, 3->frame
      * @param offset offset into the AVFrame.data from which the slice should be read
    *)
    draw_horiz_band: PDrawHorizBandFunc;

    (* *
      * callback to negotiate the pixelFormat
      * @param fmt is the list of formats which are supported by the codec,
      * it is terminated by -1 as 0 is a valid format, the formats are ordered by quality.
      * The first is always the native one.
      * @return the chosen format
      * - encoding: unused
      * - decoding: Set by user, if not set the native format will be chosen.
    *)
    get_format: PGetFormatFunc;
    // enum AVPixelFormat (*get_format)(struct AVCodecContext *s, const enum AVPixelFormat * fmt);

    (* *
      * maximum number of B-frames between non-B-frames
      * Note: The output will be delayed by max_b_frames+1 relative to the input.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    max_b_frames: cint;

    (* *
      * qscale factor between IP and B-frames
      * If > 0 then the last P-frame quantizer will be used (q= lastp_q*factor+offset).
      * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
      * - encoding: Set by user.
      * - decoding: unused
    *)
    b_quant_factor: cfloat;

    (* * obsolete FIXME remove *)
    rc_strategy: cint;

    b_frame_strategy: cint;

{$IF FF_API_MPV_GLOBAL_OPTS}
    (* *
      * luma single coefficient elimination threshold
      * - encoding: Set by user.
      * - decoding: unused
    *)
    luma_elim_threshold: cint;
    deprecated;

    (* *
      * chroma single coeff elimination threshold
      * - encoding: Set by user.
      * - decoding: unused
    *)
    chroma_elim_threshold: cint;
    deprecated;
{$IFEND}
    (* *
      * qscale offset between IP and B-frames
      * - encoding: Set by user.
      * - decoding: unused
    *)
    b_quant_offset: cfloat;

    (* *
      * Size of the frame reordering buffer in the decoder.
      * For MPEG-2 it is 1 IPB or 0 low delay IP.
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    has_b_frames: cint;

    (* *
      * 0-> h263 quant 1-> mpeg quant
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mpeg_quant: cint;

    (* *
      * qscale factor between P and I-frames
      * If > 0 then the last p frame quantizer will be used (q= lastp_q*factor+offset).
      * If < 0 then normal ratecontrol will be done (q= -normal_q*factor+offset).
      * - encoding: Set by user.
      * - decoding: unused
    *)
    i_quant_factor: cfloat;

    (* *
      * qscale offset between P and I-frames
      * - encoding: Set by user.
      * - decoding: unused
    *)
    i_quant_offset: cfloat;

    (* *
      * luminance masking (0-> disabled)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    lumi_masking: cfloat;

    (* *
      * temporary complexity masking (0-> disabled)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    temporal_cplx_masking: cfloat;

    (* *
      * spatial complexity masking (0-> disabled)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    spatial_cplx_masking: cfloat;

    (* *
      * p block masking (0-> disabled)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    p_masking: cfloat;

    (* *
      * darkness masking (0-> disabled)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    dark_masking: cfloat;

    (* *
      * slice count
      * - encoding: Set by libavcodec.
      * - decoding: Set by user (or 0).
    *)
    slice_count: cint;
    (* *
      * prediction method (needed for huffyuv)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    prediction_method: cint;

    (* *
      * slice offsets in the frame in bytes
      * - encoding: Set/allocated by libavcodec.
      * - decoding: Set/allocated by user (or NULL).
    *)
    slice_offset: pcint;

    (* *
      * sample aspect ratio (0 if unknown)
      * That is the width of a pixel divided by the height of the pixel.
      * Numerator and denominator must be relatively prime and smaller than 256 for some video standards.
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    sample_aspect_ratio: AVRational;

    (* *
      * motion estimation comparison function
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_cmp: cint;
    (* *
      * subpixel motion estimation comparison function
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_sub_cmp: cint;
    (* *
      * macroblock comparison function (not supported yet)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mb_cmp: cint;
    (* *
      * interlaced DCT comparison function
      * - encoding: Set by user.
      * - decoding: unused
    *)
    ildct_cmp: cint;

    (* *
      * ME diamond size & shape
      * - encoding: Set by user.
      * - decoding: unused
    *)
    dia_size: cint;

    (* *
      * amount of previous MV predictors (2a+1 x 2a+1 square)
      * - encoding: Set by user.
      * - decoding: unused
    *)
    last_predictor_count: cint;

    (* *
      * prepass for motion estimation
      * - encoding: Set by user.
      * - decoding: unused
    *)
    pre_me: cint;

    (* *
      * motion estimation prepass comparison function
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_pre_cmp: cint;

    (* *
      * ME prepass diamond size & shape
      * - encoding: Set by user.
      * - decoding: unused
    *)
    pre_dia_size: cint;

    (* *
      * subpel ME quality
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_subpel_quality: cint;

    (* *
      * DTG active format information (additional aspect ratio
      * information only used in DVB MPEG-2 transport streams)
      * 0 if not set.
      *
      * - encoding: unused
      * - decoding: Set by decoder.
    *)
    dtg_active_format: cint;

    (* *
      * maximum motion estimation search range in subpel units
      * If 0 then no limit.
      *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_range: cint;

    (* *
      * intra quantizer bias
      * - encoding: Set by user.
      * - decoding: unused
    *)
    intra_quant_bias: cint;

    (* *
      * inter quantizer bias
      * - encoding: Set by user.
      * - decoding: unused
    *)
    inter_quant_bias: cint;

{$IF FF_API_COLOR_TABLE_ID}
    (* *
      * color table ID
      * - encoding: unused
      * - decoding: Which clrtable should be used for 8bit RGB images.
      *             Tables have to be stored somewhere. FIXME
    *)
    color_table_id: cint;
    deprecated;
{$IFEND}
    (* *
      * slice flags
      * - encoding: unused
      * - decoding: Set by user.
    *)
    slice_flags: cint;

    (* *
      * XVideo Motion Acceleration
      * - encoding: forbidden
      * - decoding: set by decoder
    *)
    xvmc_acceleration: cint;

    (* *
      * macroblock decision mode
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mb_decision: cint;

    (* *
      * custom intra quantization matrix
      * - encoding: Set by user, can be NULL.
      * - decoding: Set by libavcodec.
    *)
    intra_matrix: pcuint16;

    (* *
      * custom inter quantization matrix
      * - encoding: Set by user, can be NULL.
      * - decoding: Set by libavcodec.
    *)
    inter_matrix: pcuint16;

    (* *
      * scene change detection threshold
      * 0 is default, larger means fewer detected scene changes.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    scenechange_threshold: cint;

    (* *
      * noise reduction strength
      * - encoding: Set by user.
      * - decoding: unused
    *)
    noise_reduction: cint;

{$IF FF_API_INTER_THRESHOLD}
    (* *
      * @deprecated this field is unused
    *)
    inter_threshold: cint;
    deprecated;
{$IFEND}
{$IF FF_API_MPV_GLOBAL_OPTS}
    (* *
      * @deprecated use mpegvideo private options instead
    *)
    quantizer_noise_shaping: cint;
    deprecated;
{$IFEND}
    (* *
      * Motion estimation threshold below which no motion estimation is
      * performed, but instead the user specified motion vectors are used.
      *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_threshold: cint;

    (* *
      * Macroblock threshold below which the user specified macroblock types will be used.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mb_threshold: cint;

    (* *
      * precision of the intra DC coefficient - 8
      * - encoding: Set by user.
      * - decoding: unused
    *)
    intra_dc_precision: cint;

    (* *
      * Number of macroblock rows at the top which are skipped.
      * - encoding: unused
      * - decoding: Set by user.
    *)
    skip_top: cint;

    (* *
      * Number of macroblock rows at the bottom which are skipped.
      * - encoding: unused
      * - decoding: Set by user.
    *)
    skip_bottom: cint;

    (* *
      * Border processing masking, raises the quantizer for mbs on the borders
      * of the picture.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    border_masking: cfloat;

    (* *
      * minimum MB lagrange multipler
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mb_lmin: cint;

    (* *
      * maximum MB lagrange multipler
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mb_lmax: cint;

    (* *
      *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    me_penalty_compensation: cint;

    (* *
      *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    bidir_refine: cint;

    (* *
      *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    brd_scale: cint;

    (* *
      * minimum GOP size
      * - encoding: Set by user.
      * - decoding: unused
    *)
    keyint_min: cint;

    (* *
      * number of reference frames
      * - encoding: Set by user.
      * - decoding: Set by lavc.
    *)
    refs: cint;

    (* *
      * chroma qp offset from luma
      * - encoding: Set by user.
      * - decoding: unused
    *)
    chromaoffset: cint;

    (* *
      * Multiplied by qscale for each frame and added to scene_change_score.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    scenechange_factor: cint;

    (* *
      *
      * Note: Value depends upon the compare function used for fullpel ME.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    mv0_threshold: cint;

    (* *
      * Adjust sensitivity of b_frame_strategy 1.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    b_sensitivity: cint;

    (* *
      * Chromaticity coordinates of the source primaries.
      * - encoding: Set by user
      * - decoding: Set by libavcodec
    *)
    color_primaries: AVColorPrimaries;

    (* *
      * Color Transfer Characteristic.
      * - encoding: Set by user
      * - decoding: Set by libavcodec
    *)
    color_trc: AVColorTransferCharacteristic;

    (* *
      * YUV colorspace type.
      * - encoding: Set by user
      * - decoding: Set by libavcodec
    *)
    colorspace: AVColorSpace;

    (* *
      * MPEG vs JPEG YUV range.
      * - encoding: Set by user
      * - decoding: Set by libavcodec
    *)
    color_range: AVColorRange;

    (* *
      * This defines the location of chroma samples.
      * - encoding: Set by user
      * - decoding: Set by libavcodec
    *)
    chroma_sample_location: AVChromaLocation;

    (* *
      * Number of slices.
      * Indicates number of picture subdivisions. Used for parallelized
      * decoding.
      * - encoding: Set by user
      * - decoding: unused
    *)
    slices: cint;

    (* * Field order
      * - encoding: set by libavcodec
      * - decoding: Set by user.
    *)
    field_order: AVFieldOrder;

    (* audio only *)
    sample_rate: cint;
    /// < samples per second
    channels: cint;
    /// < number of audio channels

    (* *
      * audio sample format
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    sample_fmt: AVSampleFormat;
    /// < sample format

    (* The following data should not be initialized. *)
    (* *
      * Number of samples per channel in an audio frame.
      *
      * - encoding: set by libavcodec in avcodec_open2(). Each submitted frame
      *   except the last must contain exactly frame_size samples per channel.
      *   May be 0 when the codec has CODEC_CAP_VARIABLE_FRAME_SIZE set, then the
      *   frame size is not restricted.
      * - decoding: may be set by some decoders to indicate constant frame size
    *)
    frame_size: cint;

    (* *
      * Frame counter, set by libavcodec.
      *
      * - decoding: total number of frames returned from the decoder so far.
      * - encoding: total number of frames passed to the encoder so far.
      *
      *   @note the counter is not incremented if encoding/decoding resulted in
      *   an error.
    *)
    frame_number: cint;

    (* *
      * number of bytes per packet if constant and known or 0
      * Used by some WAV based audio codecs.
    *)
    block_align: cint;

    (* *
      * Audio cutoff bandwidth (0 means "automatic")
      * - encoding: Set by user.
      * - decoding: unused
    *)
    cutoff: cint;

{$IF FF_API_REQUEST_CHANNELS
  (**
  * Decoder should decode to this many channels if it can (0 for default)
  * - encoding: unused
  * - decoding: Set by user.
  * @deprecated Deprecated in favor of request_channel_layout.
  *)
  request_channels:cint;
  {$IFEND}
    (* *
      * Audio channel layout.
      * - encoding: set by user.
      * - decoding: set by user, may be overwritten by libavcodec.
    *)
    uint64_t channel_layout: cuint64;

    (* *
      * Request decoder to use this channel layout if it can (0 for default)
      * - encoding: unused
      * - decoding: Set by user.
    *)
    uint64_t request_channel_layout: cuint64;

    (* *
      * Type of service that the audio stream conveys.
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    audio_service_type: AVAudioServiceType;

    (* *
      * desired sample format
      * - encoding: Not used.
      * - decoding: Set by user.
      * Decoder will decode to this format if it can.
    *)
    request_sample_fmt: AVSampleFormat;

    (* *
      * Called at the beginning of each frame to get a buffer for it.
      *
      * The function will set AVFrame.data[], AVFrame.linesize[].
      * AVFrame.extended_data[] must also be set, but it should be the same as
      * AVFrame.data[] except for planar audio with more channels than can fit
      * in AVFrame.data[]. In that case, AVFrame.data[] shall still contain as
      * many data pointers as it can hold.
      *
      * if CODEC_CAP_DR1 is not set then get_buffer() must call
      * avcodec_default_get_buffer() instead of providing buffers allocated by
      * some other means.
      *
      * AVFrame.data[] should be 32- or 16-byte-aligned unless the CPU doesn't
      * need it. avcodec_default_get_buffer() aligns the output buffer properly,
      * but if get_buffer() is overridden then alignment considerations should
      * be taken into account.
      *
      * @see avcodec_default_get_buffer()
      *
      * Video:
      *
      * If pic.reference is set then the frame will be read later by libavcodec.
      * avcodec_align_dimensions2() should be used to find the required width and
      * height, as they normally need to be rounded up to the next multiple of 16.
      *
      * If frame multithreading is used and thread_safe_callbacks is set,
      * it may be called from a different thread, but not from more than one at
      * once. Does not need to be reentrant.
      *
      * @see release_buffer(), reget_buffer()
      * @see avcodec_align_dimensions2()
      *
      * Audio:
      *
      * Decoders request a buffer of a particular size by setting
      * AVFrame.nb_samples prior to calling get_buffer(). The decoder may,
      * however, utilize only part of the buffer by setting AVFrame.nb_samples
      * to a smaller value in the output frame.
      *
      * Decoders cannot use the buffer after returning from
      * avcodec_decode_audio4(), so they will not call release_buffer(), as it
      * is assumed to be released immediately upon return. In some rare cases,
      * a decoder may need to call get_buffer() more than once in a single
      * call to avcodec_decode_audio4(). In that case, when get_buffer() is
      * called again after it has already been called once, the previously
      * acquired buffer is assumed to be released at that time and may not be
      * reused by the decoder.
      *
      * As a convenience, av_samples_get_buffer_size() and
      * av_samples_fill_arrays() in libavutil may be used by custom get_buffer()
      * functions to find the required data size and to fill data pointers and
      * linesize. In AVFrame.linesize, only linesize[0] may be set for audio
      * since all planes must be the same size.
      *
      * @see av_samples_get_buffer_size(), av_samples_fill_arrays()
      *
      * - encoding: unused
      * - decoding: Set by libavcodec, user can override.
    *)
    get_buffer: PGetBufferFunc;

    (* *
      * Called to release buffers which were allocated with get_buffer.
      * A released buffer can be reused in get_buffer().
      * pic.data[*] must be set to NULL.
      * May be called from a different thread if frame multithreading is used,
      * but not by more than one thread at once, so does not need to be reentrant.
      * - encoding: unused
      * - decoding: Set by libavcodec, user can override.
    *)
    release_buffer: PReleaseBufferFunc;

    (* *
      * Called at the beginning of a frame to get cr buffer for it.
      * Buffer type (size, hints) must be the same. libavcodec won't check it.
      * libavcodec will pass previous buffer in pic, function should return
      * same buffer or new buffer with old frame "painted" into it.
      * If pic.data[0] == NULL must behave like get_buffer().
      * if CODEC_CAP_DR1 is not set then reget_buffer() must call
      * avcodec_default_reget_buffer() instead of providing buffers allocated by
      * some other means.
      * - encoding: unused
      * - decoding: Set by libavcodec, user can override.
    *)
    reget_buffer: PRegetBufferFunc;

    (* - encoding parameters *)
    qcompress: cfloat;
    /// < amount of qscale change between easy & hard scenes (0.0-1.0)
    qblur: cfloat;
    /// < amount of qscale smoothing over time (0.0-1.0)

    (* *
      * minimum quantizer
      * - encoding: Set by user.
      * - decoding: unused
    *)
    qmin: cint;

    (* *
      * maximum quantizer
      * - encoding: Set by user.
      * - decoding: unused
    *)
    qmax: cint;

    (* *
      * maximum quantizer difference between frames
      * - encoding: Set by user.
      * - decoding: unused
    *)
    max_qdiff: cint;

    (* *
      * ratecontrol qmin qmax limiting method
      * 0-> clipping, 1-> use a nice continuous function to limit qscale wthin qmin/qmax.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    rc_qsquish: cfloat;

    rc_qmod_amp: cfloat;
    rc_qmod_freq: cint;

    (* *
      * decoder bitstream buffer size
      * - encoding: Set by user.
      * - decoding: unused
    *)
    rc_buffer_size: cint;

    (* *
      * ratecontrol override, see RcOverride
      * - encoding: Allocated/set/freed by user.
      * - decoding: unused
    *)
    rc_override_count: cint;
    rc_override: PRCOverride;

    (* *
      * rate control equation
      * - encoding: Set by user
      * - decoding: unused
    *)
    rc_eq: pcchar;

    (* *
      * maximum bitrate
      * - encoding: Set by user.
      * - decoding: unused
    *)
    rc_max_rate: cint;

    (* *
      * minimum bitrate
      * - encoding: Set by user.
      * - decoding: unused
    *)
    rc_min_rate: cint;

    rc_buffer_aggressivity: cfloat;

    (* *
      * initial complexity for pass1 ratecontrol
      * - encoding: Set by user.
      * - decoding: unused
    *)
    rc_initial_cplx: cfloat;

    (* *
      * Ratecontrol attempt to use, at maximum, <value> of what can be used without an underflow.
      * - encoding: Set by user.
      * - decoding: unused.
    *)
    rc_max_available_vbv_use: cfloat;

    (* *
      * Ratecontrol attempt to use, at least, <value> times the amount needed to prevent a vbv overflow.
      * - encoding: Set by user.
      * - decoding: unused.
    *)
    rc_min_vbv_overflow_use: cfloat;

    (* *
      * Number of bits which should be loaded into the rc buffer before decoding starts.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    rc_initial_buffer_occupancy: cint;

    (* *
      * coder type
      * - encoding: Set by user.
      * - decoding: unused
    *)
    coder_type: cint;

    (* *
      * context model
      * - encoding: Set by user.
      * - decoding: unused
    *)
    context_model: cint;

    (* *
      * minimum Lagrange multipler
      * - encoding: Set by user.
      * - decoding: unused
    *)
    lmin: cint;

    (* *
      * maximum Lagrange multipler
      * - encoding: Set by user.
      * - decoding: unused
    *)
    lmax: cint;

    (* *
      * frame skip threshold
      * - encoding: Set by user.
      * - decoding: unused
    *)
    frame_skip_threshold: cint;

    (* *
      * frame skip factor
      * - encoding: Set by user.
      * - decoding: unused
    *)
    frame_skip_factor: cint;

    (* *
      * frame skip exponent
      * - encoding: Set by user.
      * - decoding: unused
    *)
    frame_skip_exp: cint;

    (* *
      * frame skip comparison function
      * - encoding: Set by user.
      * - decoding: unused
    *)
    frame_skip_cmp: cint;

    (* *
      * trellis RD quantization
      * - encoding: Set by user.
      * - decoding: unused
    *)
    trellis: cint;

    (* *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    min_prediction_order: cint;

    (* *
      * - encoding: Set by user.
      * - decoding: unused
    *)
    max_prediction_order: cint;

    (* *
      * GOP timecode frame start number
      * - encoding: Set by user, in non drop frame format
      * - decoding: Set by libavcodec (timecode in the 25 bits format, -1 if unset)
    *)
    int64_t timecode_frame_start: cint64;

    (* The RTP callback: This function is called *)
    (* every time the encoder has a packet to send. *)
    (* It depends on the encoder if the data starts *)
    (* with a Start Code (it should). H.263 does. *)
    (* mb_nb contains the number of macroblocks *)
    (* encoded in the RTP payload. *)
    // void (*rtp_callback)(struct AVCodecContext *avctx, void *data, int size, int mb_nb);
    rtp_callback: PRtpCallbackFunc;

    rtp_payload_size: cint;

    (* The size of the RTP payload: the coder will *)
    (* do its best to deliver a chunk with size *)
    (* below rtp_payload_size, the chunk will start *)
    (* with a start code on some codecs like H.263. *)
    (* This doesn't take account of any particular *)
    (* headers inside the transmitted RTP payload. *)

    (* statistics, used for 2-pass encoding *)
    mv_bits: cint;
    header_bits: cint;
    i_tex_bits: cint;
    p_tex_bits: cint;
    i_count: cint;
    p_count: cint;
    skip_count: cint;
    misc_bits: cint;

    (* *
      * number of bits used for the previously encoded frame
      * - encoding: Set by libavcodec.
      * - decoding: unused
    *)
    frame_bits: cint;

    (* *
      * pass1 encoding statistics output buffer
      * - encoding: Set by libavcodec.
      * - decoding: unused
    *)
    stats_out: pcchar;

    (* *
      * pass2 encoding statistics input buffer
      * Concatenated stuff from stats_out of pass1 should be placed here.
      * - encoding: Allocated/set/freed by user.
      * - decoding: unused
    *)
    stats_in: pcchar;

    (* *
      * Work around bugs in encoders which sometimes cannot be detected automatically.
      * - encoding: Set by user
      * - decoding: Set by user
    *)
    workaround_bugs: cint;

    (* *
      * strictly follow the standard (MPEG4, ...).
      * - encoding: Set by user.
      * - decoding: Set by user.
      * Setting this to STRICT or higher means the encoder and decoder will
      * generally do stupid things, whereas setting it to unofficial or lower
      * will mean the encoder might produce output that is not supported by all
      * spec-compliant decoders. Decoders don't differentiate between normal,
      * unofficial and experimental (that is, they always try to decode things
      * when they can) unless they are explicitly asked to behave stupidly
      * (=strictly conform to the specs)
    *)
    strict_std_compliance: cint;

    (* *
      * error concealment flags
      * - encoding: unused
      * - decoding: Set by user.
    *)
    error_concealment: cint;

    (* *
      * debug
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    debug: cint;

    (* *
      * debug
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    debug_mv: cint;

    (* *
      * Error recognition; may misdetect some more or less valid parts as errors.
      * - encoding: unused
      * - decoding: Set by user.
    *)
    err_recognition: cint;

    (* *
      * opaque 64bit number (generally a PTS) that will be reordered and
      * output in AVFrame.reordered_opaque
      * @deprecated in favor of pkt_pts
      * - encoding: unused
      * - decoding: Set by user.
    *)
    int64_t reordered_opaque: cint64;

    (* *
      * Hardware accelerator in use
      * - encoding: unused.
      * - decoding: Set by libavcodec
    *)
    hwaccel: PAVHWAccel;

    (* *
      * Hardware accelerator context.
      * For some hardware accelerators, a global context needs to be
      * provided by the user. In that case, this holds display-dependent
      * data FFmpeg cannot instantiate itself. Please refer to the
      * FFmpeg HW accelerator documentation to know how to fill this
      * is. e.g. for VA API, this is a struct vaapi_context.
      * - encoding: unused
      * - decoding: Set by user
    *)
    hwaccel_context: Pointer;

    (* *
      * error
      * - encoding: Set by libavcodec if flags&CODEC_FLAG_PSNR.
      * - decoding: unused
    *)
    error: array [0 .. AV_NUM_DATA_POINTERS - 1] of cuint64;

    (* *
      * DCT algorithm, see FF_DCT_* below
      * - encoding: Set by user.
      * - decoding: unused
    *)
    dct_algo: cint;

    (* *
      * IDCT algorithm, see FF_IDCT_* below.
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    idct_algo: cint;

{$IF FF_API_DSP_MASK}
    (* *
      * Unused.
      * @deprecated use av_set_cpu_flags_mask() instead.
    *)
    dsp_mask: cuint;
    deprecated;
{$IFEND}
    (* *
      * bits per sample/pixel from the demuxer (needed for huffyuv).
      * - encoding: Set by libavcodec.
      * - decoding: Set by user.
    *)
    bits_per_coded_sample: cint;

    (* *
      * Bits per sample/pixel of internal libavcodec pixel/sample format.
      * - encoding: set by user.
      * - decoding: set by libavcodec.
    *)
    bits_per_raw_sample: cint;

    (* *
      * low resolution decoding, 1-> 1/2 size, 2->1/4 size
      * - encoding: unused
      * - decoding: Set by user.
    *)
    lowres: cint;

    (* *
      * the picture in the bitstream
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    coded_frame: PAVFrame;

    (* *
      * thread count
      * is used to decide how many independent tasks should be passed to execute()
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    thread_count: cint;

    (* *
      * Which multithreading methods to use.
      * Use of FF_THREAD_FRAME will increase decoding delay by one frame per thread,
      * so clients which cannot provide future frames should not use it.
      *
      * - encoding: Set by user, otherwise the default is used.
      * - decoding: Set by user, otherwise the default is used.
    *)
    thread_type: cint;

    (* *
      * Which multithreading methods are in use by the codec.
      * - encoding: Set by libavcodec.
      * - decoding: Set by libavcodec.
    *)
    active_thread_type: cint;

    (* *
      * Set by the client if its custom get_buffer() callback can be called
      * synchronously from another thread, which allows faster multithreaded decoding.
      * draw_horiz_band() will be called from other threads regardless of this setting.
      * Ignored if the default get_buffer() is used.
      * - encoding: Set by user.
      * - decoding: Set by user.
    *)
    thread_safe_callbacks: cint;

    (* *
      * The codec may call this to execute several independent things.
      * It will return only after finishing all tasks.
      * The user may replace this with some multithreaded implementation,
      * the default implementation will execute the parts serially.
      * @param count the number of things to execute
      * - encoding: Set by libavcodec, user can override.
      * - decoding: Set by libavcodec, user can override.
    *)
    execute: PExecuteFunc;
    // int (*execute)(struct AVCodecContext *c, int (*func)(struct AVCodecContext *c2, void *arg), void *arg2, int *ret, int count, int size);

    (* *
      * The codec may call this to execute several independent things.
      * It will return only after finishing all tasks.
      * The user may replace this with some multithreaded implementation,
      * the default implementation will execute the parts serially.
      * Also see avcodec_thread_init and e.g. the --enable-pthread configure option.
      * @param c context passed also to func
      * @param count the number of things to execute
      * @param arg2 argument passed unchanged to func
      * @param ret return values of executed functions, must have space for "count" values. May be NULL.
      * @param func function that will be called count times, with jobnr from 0 to count-1.
      *             threadnr will be in the range 0 to c->thread_count-1 < MAX_THREADS and so that no
      *             two instances of func executing at the same time will have the same threadnr.
      * @return always 0 currently, but code should handle a future improvement where when any call to func
      *         returns < 0 no further calls to func may be done and < 0 is returned.
      * - encoding: Set by libavcodec, user can override.
      * - decoding: Set by libavcodec, user can override.
    *)
    execute2: PExecute2Func;

    (* *
      * thread opaque
      * Can be used by execute() to store some per AVCodecContext stuff.
      * - encoding: set by execute()
      * - decoding: set by execute()
    *)
    thread_opaque: Pointer;

    (* *
      * noise vs. sse weight for the nsse comparsion function
      * - encoding: Set by user.
      * - decoding: unused
    *)
    nsse_weight: cint;

    (* *
      * profile
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    profile: cint;

    (* *
      * level
      * - encoding: Set by user.
      * - decoding: Set by libavcodec.
    *)
    level: cint;

    (* *
      *
      * - encoding: unused
      * - decoding: Set by user.
    *)
    skip_loop_filter: AVDiscard;

    (* *
      *
      * - encoding: unused
      * - decoding: Set by user.
    *)
    skip_idct: AVDiscard;

    (* *
      *
      * - encoding: unused
      * - decoding: Set by user.
    *)
    skip_frame: AVDiscard;

    (* *
      * Header containing style information for text subtitles.
      * For SUBTITLE_ASS subtitle type, it should contain the whole ASS
      * [Script Info] and [V4+ Styles] section, plus the [Events] line and
      * the Format line following. It shouldn't include any Dialogue line.
      * - encoding: Set/allocated/freed by user (before avcodec_open2())
      * - decoding: Set/allocated/freed by libavcodec (by avcodec_open2())
    *)
    subtitle_header: pcuint8;
    subtitle_header_size: cint;

    (* *
      * Simulates errors in the bitstream to test error concealment.
      * - encoding: Set by user.
      * - decoding: unused
    *)
    error_rate: cint;

    (* *
      * Current packet as passed into the decoder, to avoid having
      * to pass the packet into every function. Currently only valid
      * inside lavc and get/release_buffer callbacks.
      * - decoding: set by avcodec_decode_*, read by get_buffer() for setting pkt_pts
      * - encoding: unused
    *)
    pkt: PAVPacket;

    (* *
      * VBV delay coded in the last frame (in periods of a 27 MHz clock).
      * Used for compliant TS muxing.
      * - encoding: Set by libavcodec.
      * - decoding: unused.
    *)
    vbv_delay: cuint64;

    (* *
      * Timebase in which pkt_dts/pts and AVPacket.dts/pts are.
      * Code outside libavcodec should access this field using:
      * av_codec_{get,set } _pkt_timebase(avctx) * -encoding unused. *-decodimg set by user *)

    pkt_timebase: AVRational;

    (* *
      * AVCodecDescriptor
      * Code outside libavcodec should access this field using:
      * av_codec_{get,set}_codec_descriptor(avctx)
      * - encoding: unused.
      * - decoding: set by libavcodec.
    *)
    codec_descriptor: PAVCodecDescriptor;

    (* *
      * Current statistics for PTS correction.
      * - decoding: maintained and used by libavcodec, not intended to be used by user apps
      * - encoding: unused
    *)
    pts_correction_num_faulty_pts: cint64;
    /// Number of incorrect PTS values so far
    pts_correction_num_faulty_dts: cint64;
    /// Number of incorrect DTS values so far
    pts_correction_last_pts: cint64;
    /// PTS of the last frame
    pts_correction_last_dts: cint64;
    /// DTS of the last frame

    (* *
      * Current frame metadata.
      * - decoding: maintained and used by libavcodec, not intended to be used by user apps
      * - encoding: unused
    *)
    metadata: PAVDictionary;

    (* *
      * Character encoding of the input subtitles file.
      * - decoding: set by user
      * - encoding: unused
    *)
    sub_charenc: pcchar;

    (* *
      * Subtitles character encoding mode. Formats or codecs might be adjusting
      * this setting (if they are doing the conversion themselves for instance).
      * - decoding: set by libavcodec
      * - encoding: unused
    *)
    sub_charenc_mode: cint;

  end;

  (* *
    * AVProfile.
  *)
  AVProfile = record
    profile: cint;
    name: pcchar;
    /// < short name for the profile
  end;

  // typedef struct AVCodecDefault AVCodecDefault;

  // struct AVSubtitle;

  (* *
    * AVCodec.
  *)
  avcodec = record
    (* *
      * Name of the codec implementation.
      * The name is globally unique among encoders and among decoders (but an
      * encoder and a decoder can share the same name).
      * This is the primary way to find a codec from the user perspective.
    *)
    name: pcchar;
    (* *
      * Descriptive name for the codec, meant to be more human readable than name.
      * You should use the NULL_IF_CONFIG_SMALL() macro to define it.
    *)
    long_name: pcchar;
    avtype: AVMediaType;
    id: AVCodecID;
    (* *
      * Codec capabilities.
      * see CODEC_CAP_*
    *)
    capabilities: cint;
    supported_framerates: PAVRational;
    /// < array of supported framerates, or NULL if any, array is terminated by {0,0 }
    pix_fmts: PAVPixelFormat;
    /// < array of supported pixel formats, or NULL if unknown, array is terminated by -1
    supported_samplerates: pcint;
    /// < array of supported audio samplerates, or NULL if unknown, array is terminated by 0
    sample_fmts: PAVSampleFormat;
    /// < array of supported sample formats, or NULL if unknown, array is terminated by -1
    channel_layouts: pcuint64;
    /// < array of support channel layouts, or NULL if unknown. array is terminated by 0
    max_lowres: cuint8;
    /// < maximum value for lowres supported by the decoder
    priv_class: PAVClass;
    /// < AVClass for the private context
    profiles: PAVProfile;
    /// < array of recognized profiles, or NULL if unknown, array is terminated by {FF_PROFILE_UNKNOWN}

    (* ****************************************************************
      * No fields below this line are part of the public API. They
      * may not be used outside of libavcodec and can be changed and
      * removed at will.
      * New public fields should be added right above.
      *****************************************************************
    *)
    priv_data_size: cint;
    next: PAVCodec;
    (* *
      * @name Frame-level threading support functions
      * @{
    *)
    (* *
      * If defined, called on thread contexts when they are created.
      * If the codec allocates writable tables in init(), re-allocate them here.
      * priv_data will be set to a copy of the original.
    *)
    init_thread_copy: PInitThreadCopyFunc;

    (* *
      * Copy necessary context variables from a previous thread context to the current one.
      * If not defined, the next thread will start automatically; otherwise, the codec
      * must call ff_thread_finish_setup().
      *
      * dst and src will (rarely) point to the same context, in which case memcpy should be skipped.
    *)
    update_thread_context: PUpdateThreadContextFunc;

    (* * @} *)

    (* *
      * Private codec-specific defaults.
    *)
    defaults: PAVCodecDefault;

    (* *
      * Initialize codec static data, called from avcodec_register().
    *)
    init_static_data: PInitStaticDataFunc;

    init: PInitFunc;
    encode_sub: PEncodeSubFunc;
    (* *
      * Encode data to an AVPacket.
      *
      * @param      avctx          codec context
      * @param      avpkt          output AVPacket (may contain a user-provided buffer)
      * @param[in]  frame          AVFrame containing the raw data to be encoded
      * @param[out] got_packet_ptr encoder sets to 0 or 1 to indicate that a
      *                            non-empty packet was returned in avpkt.
      * @return 0 on success, negative error code on failure
    *)
    encode2: PEncode2Func;
    decode: PdecodeFunc;
    close: PCloseFunc;

    (* *
      * Flush buffers.
      * Will be called when seeking
    *)
    flush: PFlushProc;

  end;

  (* *
    * AVHWAccel.
  *)
  AVHWAccel = record
    (* *
      * Name of the hardware accelerated codec.
      * The name is globally unique among encoders and among decoders (but an
      * encoder and a decoder can share the same name).
    *)
    name: pcchar;

    (* *
      * Type of codec implemented by the hardware accelerator.
      *
      * See AVMEDIA_TYPE_xxx
    *)
    avtype: AVMediaType;

    (* *
      * Codec implemented by the hardware accelerator.
      *
      * See AV_CODEC_ID_xxx
    *)
    id: AVCodecID;

    (* *
      * Supported pixel format.
      *
      * Only hardware accelerated formats are supported here.
    *)
    pix_fmt: AVPixelFormat;

    (* *
      * Hardware accelerated codec capabilities.
      * see FF_HWACCEL_CODEC_CAP_*
    *)
    capabilities: cint;

    next: PAVHWAccel;

    (* *
      * Called at the beginning of each frame or field picture.
      *
      * Meaningful frame information (codec specific) is guaranteed to
      * be parsed at this point. This function is mandatory.
      *
      * Note that buf can be NULL along with buf_size set to 0.
      * Otherwise, this means the whole frame is available at this point.
      *
      * @param avctx the codec context
      * @param buf the frame data buffer base
      * @param buf_size the size of the frame in bytes
      * @return zero if successful, a negative value otherwise
    *)
    start_frame: PStartFrameFunc;

    (* *
      * Callback for each slice.
      *
      * Meaningful slice information (codec specific) is guaranteed to
      * be parsed at this point. This function is mandatory.
      *
      * @param avctx the codec context
      * @param buf the slice data buffer base
      * @param buf_size the size of the slice in bytes
      * @return zero if successful, a negative value otherwise
    *)
    decode_slice: PDecodeSliceFunc;

    (* *
      * Called at the end of each frame or field picture.
      *
      * The whole picture is parsed at this point and can now be sent
      * to the hardware accelerator. This function is mandatory.
      *
      * @param avctx the codec context
      * @return zero if successful, a negative value otherwise
    *)
    end_frame: PEndFrameFunc;

    (* *
      * Size of HW accelerator private data.
      *
      * Private data is allocated with av_mallocz() before
      * AVCodecContext.get_buffer() and deallocated after
      * AVCodecContext.release_buffer().
    *)
    priv_data_size: cint;

  end;

  (* *
    * @defgroup lavc_picture AVPicture
    *
    * Functions for working with AVPicture
    * @{
  *)

  (* *
    * four components are given, that's all.
    * the last component is alpha
  *)
  AVPicture = record
    data: array [0 .. AV_NUM_DATA_POINTERS - 1] of pcuint8;
    linesize: array [0 .. AV_NUM_DATA_POINTERS - 1] of cint;
    /// < number of bytes per line
  end

  (* *
    * @}
  *)

  AVSubtitleType = (SUBTITLE_NONE,

  SUBTITLE_BITMAP,
  /// < A bitmap, pict will be set

  (* *
    * Plain text, the text field must be set by the decoder and is
    * authoritative. ass and pict fields may contain approximations.
  *)
  SUBTITLE_TEXT,

  (* *
    * Formatted text, the ass field must be set by the decoder and is
    * authoritative. pict and text fields may contain approximations.
  *)
  SUBTITLE_ASS };

  AVSubtitleRect = record x: cint;
  /// < top left corner  of pict, undefined when pict is not set
  y: cint;
  /// < top left corner  of pict, undefined when pict is not set
  w: cint;
  /// < width            of pict, undefined when pict is not set
  h: cint;
  /// < height           of pict, undefined when pict is not set
  nb_colors: cint;
  /// < number of colors in pict, undefined when pict is not set

  (* *
    * data+linesize for the bitmap of this subtitle.
    * can be set for text/ass as well once they where rendered
  *)
  pict: AVPicture; avtype: AVSubtitleType;

  text: pcchar;
  /// < 0 terminated plain UTF-8 text

  (* *
    * 0 terminated ASS/SSA compatible event line.
    * The presentation of this is unaffected by the other values in this
    * struct.
  *)
  ass: pcchar;

  flags: cint; end;

  AVSubtitle = record format: cuint16; (* 0 = graphics *)
  start_display_time: cuint32; (* relative to packet pts, in ms *)
  end_display_time: cuint32; (* relative to packet pts, in ms *)
  num_rects: cuint; rects: PPAVSubtitleRect; pts: cint64;
  /// < Same as packet pts, in AV_TIME_BASE
end;

  (* *
    * @defgroup lavc_parsing Frame parsing
    * @{
  *)

  AVCodecParserContext = record priv_data: Pointer; parser: PAVCodecParser;
  frame_offset: cint64; (* offset of the current frame *)
  cur_offset: cint64; (* current offset
    (incremented by each av_parser_parse()) *)
  next_frame_offset: cint64; (* offset of the next frame *)
  (* video info *)
  pict_type: cint; (* XXX: Put it back in AVCodecContext. *)
  (* *
    * This field is used for proper frame duration computation in lavf.
    * It signals, how much longer the frame duration of the current frame
    * is compared to normal frame duration.
    *
    * frame_duration = (1 + repeat_pict) * time_base
    *
    * It is used by codecs like H.264 to display telecined material.
  *)
  repeat_pict: cint; (* XXX: Put it back in AVCodecContext. *)
  pts: cint64; (* pts of the current frame *)
  dts: cint64; (* dts of the current frame *)

  (* private data *)
  last_pts: cint64; last_dts: cint64; fetch_timestamp: cint;

  cur_frame_start_index: cint;
  cur_frame_offset: array [0 .. AV_PARSER_PTS_NB - 1] of cint64;
  cur_frame_pts: array [0 .. AV_PARSER_PTS_NB - 1] of cint64;
  cur_frame_dts: array [0 .. AV_PARSER_PTS_NB - 1] of cint64;

  flags: cint;

  offset: cint64;
  /// < byte offset from starting packet start
  cur_frame_end: array [0 .. AV_PARSER_PTS_NB - 1] of cint64;

  (* *
    * Set by parser to 1 for key frames and 0 for non-key frames.
    * It is initialized to -1, so if the parser doesn't set this flag,
    * old-style fallback using AV_PICTURE_TYPE_I picture type as key frames
    * will be used.
  *)
  key_frame: cint;

  (* *
    * Time difference in stream time base units from the pts of this
    * packet to the point at which the output from the decoder has converged
    * independent from the availability of previous frames. That is, the
    * frames are virtually identical no matter if decoding started from
    * the very first frame or from this keyframe.
    * Is AV_NOPTS_VALUE if unknown.
    * This field is not the display duration of the current frame.
    * This field has no meaning if the packet does not have AV_PKT_FLAG_KEY
    * set.
    *
    * The purpose of this field is to allow seeking in streams that have no
    * keyframes in the conventional sense. It corresponds to the
    * recovery point SEI in H.264 and match_time_delta in NUT. It is also
    * essential for some types of subtitle streams to ensure that all
    * subtitles are correctly displayed after seeking.
  *)
  convergence_duration: cint64;

  // Timestamp generation support:
  (* *
    * Synchronization point for start of timestamp generation.
    *
    * Set to >0 for sync point, 0 for no sync point and <0 for undefined
    * (default).
    *
    * For example, this corresponds to presence of H.264 buffering period
    * SEI message.
  *)
  dts_sync_point: cint;

  (* *
    * Offset of the current timestamp against last timestamp sync point in
    * units of AVCodecContext.time_base.
    *
    * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
    * contain a valid timestamp offset.
    *
    * Note that the timestamp of sync point has usually a nonzero
    * dts_ref_dts_delta, which refers to the previous sync point. Offset of
    * the next frame after timestamp sync point will be usually 1.
    *
    * For example, this corresponds to H.264 cpb_removal_delay.
  *)
  dts_ref_dts_delta: cint;

  (* *
    * Presentation delay of current frame in units of AVCodecContext.time_base.
    *
    * Set to INT_MIN when dts_sync_point unused. Otherwise, it must
    * contain valid non-negative timestamp delta (presentation time of a frame
    * must not lie in the past).
    *
    * This delay represents the difference between decoding and presentation
    * time of the frame.
    *
    * For example, this corresponds to H.264 dpb_output_delay.
  *)
  pts_dts_delta: cint;

  (* *
    * Position of the packet in file.
    *
    * Analogous to cur_frame_pts/dts
  *)
  cur_frame_pos: array [0 .. AV_PARSER_PTS_NB - 1] of cint64;

  (* *
    * Byte position of currently parsed frame in stream.
  *)
  pos: cint64;

  (* *
    * Previous frame byte position.
  *)
  last_pos: cint64;

  (* *
    * Duration of the current frame.
    * For audio, this is in units of 1 / AVCodecContext.sample_rate.
    * For all other types, this is in units of AVCodecContext.time_base.
  *)
  duration: cint; end;

  AVCodecParser = record codec_ids: array [0 .. 4] of cint;
  (* several codec IDs are permitted *)
  priv_data_size: cint; parser_init: PParserInitFunc;
  parser_parse: PParserParseFunc; parser_close: PParserCloseProc;
  split: PSplitFunc; next: PAVCodercParser; end;

  (* *
    * @}
  *)

{$IF FF_API_AVCODEC_RESAMPLE}
  (* *
    * @defgroup lavc_resample Audio resampling
    * @ingroup libavc
    * @deprecated use libswresample instead
    *
    * @{
  *)
  // struct ReSampleContext;
  // struct AVResampleContext;

  ReSampleContext = ReSampleContext;
  (* *
    * @}
  *)
{$IFEND}
  (* *
    * @addtogroup lavc_picture
    * @{
  *)

  (* *
    * @}
  *)

  (* *
    * @defgroup lavc_misc Utility functions
    * @ingroup libavc
    *
    * Miscellaneous utility functions related to both encoding and decoding
    * (or neither).
    * @{
  *)

  (* *
    * @defgroup lavc_misc_pixfmt Pixel formats
    *
    * Functions for working with pixel formats.
    * @{
  *)

  AVBitStreamFilterContext = record priv_data: Pointer;
  filter: PAVBitStreamFilter; parser: PAVCodecParserContext;
  next: PAVBitStreamFilterContext; end;

  AVBitStreamFilter = record name: pcchar; priv_data_size: cint;
  filter: PFilterFunc; close: PCloseProc; next: PAVBitStreamFilter; end;

  (* *
    * Lock operation used by lockmgr
  *)
  AVLockOp = (AV_LOCK_CREATE,
  /// < Create a mutex
  AV_LOCK_OBTAIN,
  /// < Lock the mutex
  AV_LOCK_RELEASE,
  /// < Unlock the mutex
  AV_LOCK_DESTROY
  /// < Free mutex resources
  );

{$I avcodec_imports.inc}
  implementation

end.
