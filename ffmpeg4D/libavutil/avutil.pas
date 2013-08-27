unit avutil;

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
  ctypes,ffmpegconf,rational;
(*
  * @file
  * external API header
*)

(*
  * @mainpage
  *
  * @section ffmpeg_intro Introduction
  *
  * This document describes the usage of the different libraries
  * provided by FFmpeg.
  *
  * @li @ref libavc "libavcodec" encoding/decoding library
  * @li @ref lavfi "libavfilter" graph based frame editing library
  * @li @ref libavf "libavformat" I/O and muxing/demuxing library
  * @li @ref lavd "libavdevice" special devices muxing/demuxing library
  * @li @ref lavu "libavutil" common utility library
  * @li @ref lswr "libswresample" audio resampling, format conversion and mixing
  * @li @ref lpp  "libpostproc" post processing library
  * @li @ref lsws "libswscale" color conversion and scaling library
*)

(* *
  * @defgroup lavu Common utility functions
  *
  * @brief
  * libavutil contains the code shared across all the other FFmpeg
  * libraries
  *
  * @note In order to use the functions provided by avutil you must include
  * the specific header.
  *
  * @{
  *
  * @defgroup lavu_crypto Crypto and Hashing
  *
  * @{
  * @}
  *
  * @defgroup lavu_math Maths
  * @{
  *
  * @}
  *
  * @defgroup lavu_string String Manipulation
  *
  * @{
  *
  * @}
  *
  * @defgroup lavu_mem Memory Management
  *
  * @{
  *
  * @}
  *
  * @defgroup lavu_data Data Structures
  * @{
  *
  * @}
  *
  * @defgroup lavu_audio Audio related
  *
  * @{
  *
  * @}
  *
  * @defgroup lavu_error Error Codes
  *
  * @{
  *
  * @}
  *
  * @defgroup lavu_misc Other
  *
  * @{
  *
  * @defgroup lavu_internal Internal
  *
  * Not exported functions, for internal usage only
  *
  * @{
  *
  * @}
*)

const
  FF_LAMBDA_SHIFT = 7;
  FF_LAMBDA_SCALE = (1 shl FF_LAMBDA_SHIFT);
  FF_QP2LAMBDA = 118;
  /// < factor to convert from H.263 QP to lambda
  FF_LAMBDA_MAX = (256 * 128 - 1);

  FF_QUALITY_SCALE = FF_LAMBDA_SCALE; // FIXME maybe remove

  (* *
    * @}
    * @defgroup lavu_time Timestamp specific
    *
    * FFmpeg internal timebase and timestamp definitions
    *
    * @{
  *)

  (* *
    * @brief Undefined timestamp value
    *
    * Usually reported by demuxer that work on containers that do not provide
    * either pts or dts.
  *)

  // AV_NOPTS_VALUE  =        ((int64_t)UINT64_C(0x8000000000000000));
  AV_NOPTS_VALUE = cint64(cuint64($8000000000000000));
  (* *
    * Internal time base represented as integer
  *)

  AV_TIME_BASE = 1000000;

  (* *
    * @addtogroup lavu_ver
    * @{
  *)

  (* *
    * @}
  *)

  (* *
    * @addtogroup lavu_media Media Type
    * @brief Media Type
  *)

Type
  AVMediaType = (
    AVMEDIA_TYPE_UNKNOWN = -1,
    /// < Usually treated as AVMEDIA_TYPE_DATA
    AVMEDIA_TYPE_VIDEO, AVMEDIA_TYPE_AUDIO, AVMEDIA_TYPE_DATA,
    /// < Opaque data information usually continuous
    AVMEDIA_TYPE_SUBTITLE, AVMEDIA_TYPE_ATTACHMENT,
    /// < Opaque data information usually sparse
    AVMEDIA_TYPE_NB);

  (* *
    * @defgroup lavu_const Constants
    * @{
    *
    * @defgroup lavu_enc Encoding specific
    *
    * @note those definition should move to avcodec
    * @{
  *)

  (* *
    * @}
    * @}
    * @defgroup lavu_picture Image related
    *
    * AVPicture types, pixel formats and basic image planes manipulation.
    *
    * @{
  *)

  AVPictureType = (
    AV_PICTURE_TYPE_NONE = 0,
    /// < Undefined
    AV_PICTURE_TYPE_I,
    /// < Intra
    AV_PICTURE_TYPE_P,
    /// < Predicted
    AV_PICTURE_TYPE_B,
    /// < Bi-dir predicted
    AV_PICTURE_TYPE_S,
    /// < S(GMC)-VOP MPEG4
    AV_PICTURE_TYPE_SI,
    /// < Switching Intra
    AV_PICTURE_TYPE_SP,
    /// < Switching Predicted
    AV_PICTURE_TYPE_BI
    /// < BI type
   );

(*
  Return the LIBAVUTIL_VERSION_INT constant.
*)
function avutil_version(): cuint;cdecl; external av__util;

(* *
  * Return the libavutil build-time configuration.
*)
function avutil_configuration(): pcchar; cdecl; external av__util;

(* *
  * Return the libavutil license.
*)
function avutil_license(): pcchar; cdecl; external av__util;

(* *
  * Return a string describing the media_type enum, NULL if media_type
  * is unknown.
*)
function av_get_media_type_string(media_type: AVMediaType): pcchar; cdecl;
  external av__util;

(* *
  * Return a single letter to describe the given picture type
  * pict_type.
  *
  * @param[in] pict_type the picture type @return a single character
  * representing the picture type, '?' if pict_type is unknown
*)
function av_get_picture_type_char(pict_type: AVPictureType): cchar; cdecl;
  external av__util;

function AV_TIME_BASE_Q: AVRational;


// TODO {$I common.pas}
// #include "error.h"
// #include "version.h"
// #include "mathematics.h"
// #include "rational.h"
// #include "intfloat_readwrite.h"
// #include "log.h"
// #include "pixfmt.h"

(* *
  * Return x default pointer in case p is NULL.
*)
// function av_x_if_null(const void *p, const void *x):pointer;inline;
// begin
// result:=pointer(IFTHEN(assigned(p),cint(p),cint(x)));
// //result:= (void *)(intptr_t)(p ? p : x);
// end;

implementation

function AV_TIME_BASE_Q: AVRational;
begin
 /// Result := AVRational(1, AV_TIME_BASE);
  Result.num:=1;
  Result.den:=AV_TIME_BASE;
end;

end.
