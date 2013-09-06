unit avutil.samplefmt;

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
  ctypes,ffmpegconf;
(*
 * Audio Sample Formats
 *
 * @par
 * The data described by the sample format is always in native-endian order.
 * Sample values can be expressed by native C types, hence the lack of a signed
 * 24-bit sample format even though it is a common raw audio data format.
 *
 * @par
 * The floating-point formats are based on full volume being in the range
 * [-1.0, 1.0]. Any values outside this range are beyond full volume level.
 *
 * @par
 * The data layout as used in av_samples_fill_arrays() and elsewhere in FFmpeg
 * (such as AVFrame in libavcodec) is as follows:
 *
 * For planar sample formats, each audio channel is in a separate data plane,
 * and linesize is the buffer size, in bytes, for a single plane. All data
 * planes must be the same size. For packed sample formats, only the first data
 * plane is used, and samples for each channel are interleaved. In this case,
 * linesize is the buffer size, in bytes, for the 1 plane.
 *)

type
 PAVSampleFormat=^AVSampleFormat;
 AVSampleFormat =(
    AV_SAMPLE_FMT_NONE = -1,
    AV_SAMPLE_FMT_U8,          ///< unsigned 8 bits
    AV_SAMPLE_FMT_S16,         ///< signed 16 bits
    AV_SAMPLE_FMT_S32,         ///< signed 32 bits
    AV_SAMPLE_FMT_FLT,         ///< float
    AV_SAMPLE_FMT_DBL,         ///< double

    AV_SAMPLE_FMT_U8P,         ///< unsigned 8 bits, planar
    AV_SAMPLE_FMT_S16P,        ///< signed 16 bits, planar
    AV_SAMPLE_FMT_S32P,        ///< signed 32 bits, planar
    AV_SAMPLE_FMT_FLTP,        ///< float, planar
    AV_SAMPLE_FMT_DBLP,        ///< double, planar

    AV_SAMPLE_FMT_NB           ///< Number of sample formats. DO NOT USE if linking dynamically
);

(**
 * Return the name of sample_fmt, or NULL if sample_fmt is not
 * recognized.
 *)
function av_get_sample_fmt_name(sample_fmt:AVSampleFormat):pcchar;cdecl;external av__util;

(**
 * Return a sample format corresponding to name, or AV_SAMPLE_FMT_NONE
 * on error.
 *)
function av_get_sample_fmt(name:pcchar):AVSampleFormat;cdecl;external av__util;

(**
 * Return the planar<->packed alternative form of the given sample format, or
 * AV_SAMPLE_FMT_NONE on error. If the passed sample_fmt is already in the
 * requested planar/packed format, the format returned is the same as the
 * input.
 *)
function av_get_alt_sample_fmt( sample_fmt:AVSampleFormat; planar:cint):AVSampleFormat;cdecl;external av__util;

(**
 * Get the packed alternative form of the given sample format.
 *
 * If the passed sample_fmt is already in packed format, the format returned is
 * the same as the input.
 *
 * @return  the packed alternative form of the given sample format or
            AV_SAMPLE_FMT_NONE on error.
 *)
function av_get_packed_sample_fmt( sample_fmt:AVSampleFormat):AVSampleFormat;cdecl;external av__util;

(**
 * Get the planar alternative form of the given sample format.
 *
 * If the passed sample_fmt is already in planar format, the format returned is
 * the same as the input.
 *
 * @return  the planar alternative form of the given sample format or
            AV_SAMPLE_FMT_NONE on error.
 *)
function av_get_planar_sample_fmt( sample_fmt:AVSampleFormat):AVSampleFormat;cdecl;external av__util;

(**
 * Generate a string corresponding to the sample format with
 * sample_fmt, or a header if sample_fmt is negative.
 *
 * @param buf the buffer where to write the string
 * @param buf_size the size of buf
 * @param sample_fmt the number of the sample format to print the
 * corresponding info string, or a negative value to print the
 * corresponding header.
 * @return the pointer to the filled buffer or NULL if sample_fmt is
 * unknown or in case of other errors
 *)
function av_get_sample_fmt_string(buf:pcchar;  buf_size:cint;   sample_fmt:AVSampleFormat):pcchar; cdecl;external av__util;

{$IF FF_API_GET_BITS_PER_SAMPLE_FMT }
(**
 * @deprecated Use av_get_bytes_per_sample() instead.
 *)
function av_get_bits_per_sample_fmt(  sample_fmt:AVSampleFormat):cint;deprecated;  cdecl;external av__util;
{$IFEND}

(**
 * Return number of bytes per sample.
 *
 * @param sample_fmt the sample format
 * @return number of bytes per sample or zero if unknown for the given
 * sample format
 *)
function av_get_bytes_per_sample(sample_fmt:AVSampleFormat ):cint;cdecl;external av__util;

(**
 * Check if the sample format is planar.
 *
 * @param sample_fmt the sample format to inspect
 * @return 1 if the sample format is planar, 0 if it is interleaved
 *)
function av_sample_fmt_is_planar(sample_fmt:AVSampleFormat ):cint;cdecl;external av__util;

(**
 * Get the required buffer size for the given audio parameters.
 *
 * @param[out] linesize calculated linesize, may be NULL
 * @param nb_channels   the number of channels
 * @param nb_samples    the number of samples in a single channel
 * @param sample_fmt    the sample format
 * @param align         buffer size alignment (0 = default, 1 = no alignment)
 * @return              required buffer size, or negative error code on failure
 *)
function av_samples_get_buffer_size(linesize:pcint; nb_channels:cint;  nb_samples:cint;
                               sample_fmt:AVSampleFormat; align:cint):cint;cdecl;external av__util;

(**
 * Fill plane data pointers and linesize for samples with sample
 * format sample_fmt.
 *
 * The audio_data array is filled with the pointers to the samples data planes:
 * for planar, set the start point of each channel's data within the buffer,
 * for packed, set the start point of the entire buffer only.
 *
 * The value pointed to by linesize is set to the aligned size of each
 * channel's data buffer for planar layout, or to the aligned size of the
 * buffer for all channels for packed layout.
 *
 * The buffer in buf must be big enough to contain all the samples
 * (use av_samples_get_buffer_size() to compute its minimum size),
 * otherwise the audio_data pointers will point to invalid data.
 *
 * @see enum AVSampleFormat
 * The documentation for AVSampleFormat describes the data layout.
 *
 * @param[out] audio_data  array to be filled with the pointer for each channel
 * @param[out] linesize    calculated linesize, may be NULL
 * @param buf              the pointer to a buffer containing the samples
 * @param nb_channels      the number of channels
 * @param nb_samples       the number of samples in a single channel
 * @param sample_fmt       the sample format
 * @param align            buffer size alignment (0 = default, 1 = no alignment)
 * @return                 >=0 on success or a negative error code on failure
 * @todo return minimum size in bytes required for the buffer in case
 * of success at the next bump
 *)
function av_samples_fill_arrays(audio_data:array of pcuint8; linesize:pcint;
                           buf:pcuint8;
                           nb_channels:cint;  nb_samples:cint;
                           sample_fmt:AVSampleFormat; align:cint):cint;cdecl;external av__util;

(**
 * Allocate a samples buffer for nb_samples samples, and fill data pointers and
 * linesize accordingly.
 * The allocated samples buffer can be freed by using av_freep(&audio_data[0])
 * Allocated data will be initialized to silence.
 *
 * @see enum AVSampleFormat
 * The documentation for AVSampleFormat describes the data layout.
 *
 * @param[out] audio_data  array to be filled with the pointer for each channel
 * @param[out] linesize    aligned size for audio buffer(s), may be NULL
 * @param nb_channels      number of audio channels
 * @param nb_samples       number of samples per channel
 * @param align            buffer size alignment (0 = default, 1 = no alignment)
 * @return                 >=0 on success or a negative error code on failure
 * @todo return the size of the allocated buffer in case of success at the next bump
 * @see av_samples_fill_arrays()
 *)
function av_samples_alloc(audio_data:array of pcuint8; linesize:pcint; nb_channels:cint;
                     nb_samples:cint; sample_fmt:AVSampleFormat;  align:cint):cint; cdecl;external av__util;

(**
 * Copy samples from src to dst.
 *
 * @param dst destination array of pointers to data planes
 * @param src source array of pointers to data planes
 * @param dst_offset offset in samples at which the data will be written to dst
 * @param src_offset offset in samples at which the data will be read from src
 * @param nb_samples number of samples to be copied
 * @param nb_channels number of audio channels
 * @param sample_fmt audio sample format
 *)
function av_samples_copy(dst:array of pcuint8; src:array of pcuint8; dst_offset:cint;
                    src_offset:cint; nb_samples:cint; nb_channels:cint;
                    sample_fmt:AVSampleFormat ):cint; cdecl;external av__util;

(**
 * Fill an audio buffer with silence.
 *
 * @param audio_data  array of pointers to data planes
 * @param offset      offset in samples at which to start filling
 * @param nb_samples  number of samples to fill
 * @param nb_channels number of audio channels
 * @param sample_fmt  audio sample format
 *)
function av_samples_set_silence(audio_data:array of pcuint8; offset:cint;  nb_samples:cint;
                           nb_channels:cint; sample_fmt:AVSampleFormat ):cint;cdecl;external av__util;

implementation

end.
