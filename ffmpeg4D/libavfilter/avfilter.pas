unit avfilter;

interface
uses
 ctypes, avutil.opt, avutil, rational, dict,avutil.samplefmt,pixfmt,ffmpegconf;

Const
AV_PERM_READ    =$01;   ///< can read from the buffer
AV_PERM_WRITE   =$02;   ///< can write to the buffer
AV_PERM_PRESERVE=$04;   ///< nobody else can overwrite the buffer
AV_PERM_REUSE   =$08;   ///< can output the buffer multiple times, with the same contents each time
AV_PERM_REUSE2  =$10;   ///< can output the buffer multiple times, modified each time
AV_PERM_NEG_LINESIZES=$20;  ///< the buffer requested can have negative linesizes
AV_PERM_ALIGN   =$40;   ///< the buffer must be aligned

AVFILTER_ALIGN =16; //not part of ABI
AVFILTER_CMD_FLAG_ONE  = 1; ///< Stop once a filter understood the command (for target=all for example), fast filters are favored automatically
AVFILTER_CMD_FLAG_FAST = 2; ///< Only execute command when its fast (like a video out that supports contrast adjustment in hw)

POOL_SIZE =32;


Type
PPAVFilterBuffer=^PAVFilterBuffer;
PAVFilterBuffer=^AVFilterBuffer;
PAVFilterBufferRefVideoProps =^AVFilterBufferRefVideoProps;
PAVFilterBufferRefAudioProps = ^AVFilterBufferRefAudioProps;
PAVFilterLink=^AVFilterLink;
PAVFilterBufferRef=^AVFilterBufferRef;
PAVFilterContext=^AVFilterContext;
PAVFilterPad=^AVFilterPad;
PAVFilter=^TAVFilter;
PPAVFilterLink=^PAVFilterLink;
PAVFilterCommand=^AVFilterCommand;
PAVFilterFormats=^AVFilterFormats;
PAVFilterChannelLayouts=^AVFilterChannelLayouts;
PAVFilterPool=^AVFilterPool;
PAVFilterGraph=^AVFilterGraph;

  PFreeProc = procedure(buf:PAVFilterBuffer);
//typedef struct AVFilterContext AVFilterContext;
//typedef struct AVFilterLink    AVFilterLink;
//typedef struct AVFilterPad     AVFilterPad;
//typedef struct AVFilterFormats AVFilterFormats;

(*
 * A reference-counted buffer data type used by the filter system. Filters
 * should not store pointers to this structure directly, but instead use the
 * AVFilterBufferRef structure below.
 *)
AVFilterBuffer =record
     data:array[0..7] of pcuint8;           ///< buffer data for each plane/channel

    (**
     * pointers to the data planes/channels.
     *
     * For video, this should simply point to data[].
     *
     * For planar audio, each channel has a separate data pointer, and
     * linesize[0] contains the size of each channel buffer.
     * For packed audio, there is just one data pointer, and linesize[0]
     * contains the total size of the buffer for all channels.
     *
     * Note: Both data and extended_data will always be set, but for planar
     * audio with more channels that can fit in data, extended_data must be used
     * in order to access all channels.
     *)
    extended_data:array of pcuint8;
    linesize:array[0..7] of cint;            ///< number of bytes per line

    (** private data to be used by a custom free function *)
    priv:pointer;
    (**
     * A pointer to the function to deallocate this buffer if the default
     * function is not sufficient. This could, for example, add the memory
     * back into a memory pool to be reused later without the overhead of
     * reallocating it from scratch.
     *)
    free:PFreeProc;


     format:cint;                 ///< media format
     w, h:cint;                   ///< width and height of the allocated buffer
    refcount:cuint;          ///< number of references to this buffer
end;



(**
 * Audio specific properties in a reference to an AVFilterBuffer. Since
 * AVFilterBufferRef is common to different media formats, audio specific
 * per reference properties must be separated out.
 *)
AVFilterBufferRefAudioProps = record
     channel_layout:cuint64;    ///< channel layout of audio buffer
     nb_samples:cint;             ///< number of audio samples per channel
     sample_rate:cint;            ///< audio buffer sample rate
     channels:cint;               ///< number of channels (do not access directly)
end;

(**
 * Video specific properties in a reference to an AVFilterBuffer. Since
 * AVFilterBufferRef is common to different media formats, video specific
 * per reference properties must be separated out.
 *)
AVFilterBufferRefVideoProps = record
     w:cint;                      ///< image width
     h:cint;                      ///< image height
     sample_aspect_ratio:AVRational; ///< sample aspect ratio
     interlaced:cint;             ///< is frame interlaced
     top_field_first:cint;        ///< field order
    pict_type:AVPictureType; ///< picture type of the frame
     key_frame:cint;              ///< 1 -> keyframe, 0-> not
     qp_table_linesize:cint;                ///< qp_table stride
     qp_table_size:cint;            ///< qp_table size
    qp_table:pcint8;             ///< array of Quantization Parameters
end;

(**
 * A reference to an AVFilterBuffer. Since filters can manipulate the origin of
 * a buffer to, for example, crop image without any memcpy, the buffer origin
 * and dimensions are per-reference properties. Linesize is also useful for
 * image flipping, frame to field filters, etc, and so is also per-reference.
 *
 * TODO: add anything necessary for frame reordering
 *)
AVFilterBufferRef = record
    buf:PAVFilterBuffer;        ///< the buffer that this is a reference to
    data:array[0..7] of pcuint8;           ///< picture/audio data for each plane
    (**
     * pointers to the data planes/channels.
     *
     * For video, this should simply point to data[].
     *
     * For planar audio, each channel has a separate data pointer, and
     * linesize[0] contains the size of each channel buffer.
     * For packed audio, there is just one data pointer, and linesize[0]
     * contains the total size of the buffer for all channels.
     *
     * Note: Both data and extended_data will always be set, but for planar
     * audio with more channels that can fit in data, extended_data must be used
     * in order to access all channels.
     *)
    extended_data:array of pcuint8;
    linesize:array[0..7] of cint;            ///< number of bytes per line

    video:PAVFilterBufferRefVideoProps; ///< video buffer specific properties
   audio:PAVFilterBufferRefAudioProps; ///< audio buffer specific properties

    (**
     * presentation timestamp. The time unit may change during
     * filtering, as it is specified in the link and the filter code
     * may need to rescale the PTS accordingly.
     *)
     pts:cint64;
     pos:cint64;                ///< byte position in stream, -1 if unknown

     format:cint;                 ///< media format

     perms:cint;                  ///< permissions, see the AV_PERM_* flags

   avtype:AVMediaType;      ///< media type of buffer data

    metadata:PAVDictionary;     ///< dictionary containing metadata key=value tags
end;

PStartFrameFunc= function(link:PAVFilterLink;  picref:PAVFilterBufferRef):cint;
    PGetVideoBufferFunc=  function(link:PAVFilterLink; perms:cint; w:cint; h:cint):PAVFilterBufferRef;
    PGetAudioBufferFunc=  function(link:PAVFilterLink;  perms:cint;
                                            nb_samples:cint):PAVFilterBufferRef;
  PEndFrameFunc=function(link:PAVFilterLink):cint;
    PDrawSliceFunc=function(link:PAVFilterLink; y: cint; height:cint; slice_dir:cint):cint;
     PFilterFrameFunc=function(link:PAVFilterLink; frame:PAVFilterBufferRef):cint;
    PPollFrameFunc=function(link:PAVFilterLink):cint;
    PRequestFrameFunc= function(link:PAVFilterLink):cint;
    PConfigPropsFunc= function(link:PAVFilterLink):cint;

{$IF FF_API_AVFILTERPAD_PUBLIC }
(**
 * A filter pad used for either input or output.
 *
 * See doc/filter_design.txt for details on how to implement the methods.
 *
 * @warning this struct might be removed from public API.
 * users should call avfilter_pad_get_name() and avfilter_pad_get_type()
 * to access the name and type fields; there should be no need to access
 * any other fields from outside of libavfilter.
 *)
AVFilterPad = record
    (**
     * Pad name. The name is unique among inputs and among outputs, but an
     * input may have the same name as an output. This may be NULL if this
     * pad has no need to ever be referenced by name.
     *)
    name:pcchar;

    (**
     * AVFilterPad type.
     *)
    avtype:AVMediaType;

    (**
     * Input pads:
     * Minimum required permissions on incoming buffers. Any buffer with
     * insufficient permissions will be automatically copied by the filter
     * system to a new buffer which provides the needed access permissions.
     *
     * Output pads:
     * Guaranteed permissions on outgoing buffers. Any buffer pushed on the
     * link must have at least these permissions; this fact is checked by
     * asserts. It can be used to optimize buffer allocation.
     *)
     min_perms:cint;

    (**
     * Input pads:
     * Permissions which are not accepted on incoming buffers. Any buffer
     * which has any of these permissions set will be automatically copied
     * by the filter system to a new buffer which does not have those
     * permissions. This can be used to easily disallow buffers with
     * AV_PERM_REUSE.
     *
     * Output pads:
     * Permissions which are automatically removed on outgoing buffers. It
     * can be used to optimize buffer allocation.
     *)
     rej_perms:cint;

    (**
     * @deprecated unused
     *)
    start_frame:PStartFrameFunc;

    (**
     * Callback function to get a video buffer. If NULL, the filter system will
     * use ff_default_get_video_buffer().
     *
     * Input video pads only.
     *)
    get_video_buffer:PGetVideoBufferFunc;

    (**
     * Callback function to get an audio buffer. If NULL, the filter system will
     * use ff_default_get_audio_buffer().
     *
     * Input audio pads only.
     *)
    get_audio_buffer:PGetAudioBufferFunc;

    (**
     * @deprecated unused
     *)
     end_frame:PEndFrameFunc;

    (**
     * @deprecated unused
     *)
    draw_slice:PDrawSliceFunc;

    (**
     * Filtering callback. This is where a filter receives a frame with
     * audio/video data and should do its processing.
     *
     * Input pads only.
     *
     * @return >= 0 on success, a negative AVERROR on error. This function
     * must ensure that frame is properly unreferenced on error if it
     * hasn't been passed on to another filter.
     *)
     filter_frame:PFilterFrameFunc;

    (**
     * Frame poll callback. This returns the number of immediately available
     * samples. It should return a positive value if the next request_frame()
     * is guaranteed to return one frame (with no delay).
     *
     * Defaults to just calling the source poll_frame() method.
     *
     * Output pads only.
     *)
     poll_frame:PPollFrameFunc;

    (**
     * Frame request callback. A call to this should result in at least one
     * frame being output over the given link. This should return zero on
     * success, and another value on error.
     * See ff_request_frame() for the error codes with a specific
     * meaning.
     *
     * Output pads only.
     *)
     request_frame:PRequestFrameFunc;

    (**
     * Link configuration callback.
     *
     * For output pads, this should set the following link properties:
     * video: width, height, sample_aspect_ratio, time_base
     * audio: sample_rate.
     *
     * This should NOT set properties such as format, channel_layout, etc which
     * are negotiated between filters by the filter system using the
     * query_formats() callback before this function is called.
     *
     * For input pads, this should check the properties of the link, and update
     * the filter's internal state as necessary.
     *
     * For both input and output pads, this should return zero on success,
     * and another value on error.
     *)
     config_props:PConfigPropsFunc;


    (**
     * The filter expects a fifo to be inserted on its input link,
     * typically because it has a delay.
     *
     * input pads only.
     *)
    needs_fifo:cint;
end;
{$ENDIF}

 PInitFunc = function (ctx:PAVFilterContext; args:pcchar):cint;
       PUnInitProc= procedure(ctx:PAVFilterContext);
    PQueryFormatsFunc = function(ctx:PAVFilterContext):cint;
     PProcessCommandFunc =function(ctx:PAVFilterContext; cmd:pcchar; arg:pcchar; res:pcchar; res_len:cint; flags:cint):cint;
      PInitOpaqueFunc =function(ctx:PAVFilterContext; args:pcchar;opaque:pointer):cint;

(**
 * Filter definition. This defines the pads a filter contains, and all the
 * callback functions used to interact with the filter.
 *)
TAVFilter = record
    name:pcchar;         ///< filter name

    (**
     * A description for the filter. You should use the
     * NULL_IF_CONFIG_SMALL() macro to define it.
     *)
    description:pcchar;

    inputs:PAVFilterPad;  ///< NULL terminated list of inputs. NULL if none
    outputs:PAVFilterPad; ///< NULL terminated list of outputs. NULL if none

    (*****************************************************************
     * All fields below this line are not part of the public API. They
     * may not be used outside of libavfilter and can be changed and
     * removed at will.
     * New public fields should be added right above.
     *****************************************************************
     *)

    (**
     * Filter initialization function. Args contains the user-supplied
     * parameters. FIXME: maybe an AVOption-based system would be better?
     *)
     init:PInitFunc;

    (**
     * Filter uninitialization function. Should deallocate any memory held
     * by the filter, release any buffer references, etc. This does not need
     * to deallocate the AVFilterContext->priv memory itself.
     *)
    uninit:PUnInitProc;

    (**
     * Queries formats/layouts supported by the filter and its pads, and sets
     * the in_formats/in_chlayouts for links connected to its output pads,
     * and out_formats/out_chlayouts for links connected to its input pads.
     *
     * @return zero on success, a negative value corresponding to an
     * AVERROR code otherwise
     *)
    query_formats:PQueryFormatsFunc;

    priv_size:cint;      ///< size of private data to allocate for the filter

    (**
     * Make the filter instance process a command.
     *
     * @param cmd    the command to process, for handling simplicity all commands must be alphanumeric only
     * @param arg    the argument for the command
     * @param res    a buffer with size res_size where the filter(s) can return a response. This must not change when the command is not supported.
     * @param flags  if AVFILTER_CMD_FLAG_FAST is set and the command would be
     *               time consuming then a filter should treat it like an unsupported command
     *
     * @returns >=0 on success otherwise an error code.
     *          AVERROR(ENOSYS) on unsupported commands
     *)
    process_command:PProcessCommandFunc;

    (**
     * Filter initialization function, alternative to the init()
     * callback. Args contains the user-supplied parameters, opaque is
     * used for providing binary data.
     *)
    init_opaque:PInitOpaqueFunc;


    priv_class:PAVClass;      ///< private class, containing filter specific options
end;

(** An instance of a filter *)
AVFilterContext =record
    av_class:PAVClass;        ///< needed for av_log()

    filter:PAVFilter;               ///< the AVFilter of which this is an instance

    name:pcchar;                    ///< name of this filter instance

    input_pads:PAVFilterPad;      ///< array of input pads
   inputs:PPAVFilterLink;          ///< array of pointers to input links
{$if FF_API_FOO_COUNT   }
   input_count:cuint;           ///< @deprecated use nb_inputs
{$endif }
     nb_inputs:cuint;          ///< number of input pads

    output_pads:PAVFilterPad;     ///< array of output pads
    outputs:PPAVFilterLink;         ///< array of pointers to output links
{$if FF_API_FOO_COUNT   }
    output_count:cuint;          ///< @deprecated use nb_outputs
{$endif }
    nb_outputs:cuint;         ///< number of output pads

   priv:pointer;                     ///< private data for use by the filter

    command_queue:PAVFilterCommand;
end;

(** stage of the initialization of the link properties (dimensions, etc) *)
    TInitState =(
        AVLINK_UNINIT = 0,      ///< not started
        AVLINK_STARTINIT,       ///< started, but incomplete
        AVLINK_INIT             ///< complete
    );

(**
 * A link between two filters. This contains pointers to the source and
 * destination filters between which this link exists, and the indexes of
 * the pads involved. In addition, this link also contains the parameters
 * which have been negotiated and agreed upon between the filter, such as
 * image dimensions, format, etc.
 *)
AVFilterLink =record
     src:PAVFilterContext;       ///< source filter
     srcpad:PAVFilterPad;        ///< output pad on the source filter

     dst:PAVFilterContext;       ///< dest filter
     dstpad:PAVFilterPad;        ///< input pad on the dest filter

    avtype:AVMediaType;      ///< filter media type

    (* These parameters apply only to video *)
     w:cint;                      ///< agreed upon image width
     h:cint;                      ///< agreed upon image height
     sample_aspect_ratio:AVRational; ///< agreed upon sample aspect ratio
    (* These parameters apply only to audio *)
     channel_layout:cuint64;    ///< channel layout of current buffer (see libavutil/channel_layout.h)
     sample_rate:cint;            ///< samples per second

     format:cint;                 ///< agreed upon media format

    (**
     * Define the time base used by the PTS of the frames/samples
     * which will pass through this link.
     * During the configuration stage, each filter is supposed to
     * change only the output timebase, while the timebase of the
     * input link is assumed to be an unchangeable property.
     *)
   time_base:AVRational;

    (*****************************************************************
     * All fields below this line are not part of the public API. They
     * may not be used outside of libavfilter and can be changed and
     * removed at will.
     * New public fields should be added right above.
     *****************************************************************
     *)
    (**
     * Lists of formats and channel layouts supported by the input and output
     * filters respectively. These lists are used for negotiating the format
     * to actually be used, which will be loaded into the format and
     * channel_layout members, above, when chosen.
     *
     *)
   in_formats:PAVFilterFormats;
    out_formats:PAVFilterFormats;

    (**
     * Lists of channel layouts and sample rates used for automatic
     * negotiation.
     *)
    in_samplerates:PAVFilterFormats;
    out_samplerates:PAVFilterFormats;
    in_channel_layouts:PAVFilterChannelLayouts;
    out_channel_layouts:PAVFilterChannelLayouts;

    (**
     * Audio only, the destination filter sets this to a non-zero value to
     * request that buffers with the given number of samples should be sent to
     * it. AVFilterPad.needs_fifo must also be set on the corresponding input
     * pad.
     * Last buffer before EOF will be padded with silence.
     *)
     request_samples:cint;

     init_state:TInitState;


    pool:PAVFilterPool;

    (**
     * Graph the filter belongs to.
     *)
    graph:PAVFilterGraph;

    (**
     * Current timestamp of the link, as defined by the most recent
     * frame(s), in AV_TIME_BASE units.
     *)
     current_pts:cint64;

    (**
     * Index in the age array.
     *)
     age_index:cint;

    (**
     * Frame rate of the stream on the link, or 1/0 if unknown;
     * if left to 0/0, will be automatically be copied from the first input
     * of the source filter if it exists.
     *
     * Sources should set it to the best estimation of the real frame rate.
     * Filters should update it if necessary depending on their function.
     * Sinks can use it to set a default output frame rate.
     * It is similar to the r_frame_rate field in AVStream.
     *)
    frame_rate:AVRational;

    (**
     * Buffer partially filled with samples to achieve a fixed/minimum size.
     *)
    partial_buf:PAVFilterBufferRef;

    (**
     * Size of the partial buffer to allocate.
     * Must be between min_samples and max_samples.
     *)
     partial_buf_size:cint;

    (**
     * Minimum number of samples to filter at once. If filter_frame() is
     * called with fewer samples, it will accumulate them in partial_buf.
     * This field and the related ones must not be changed after filtering
     * has started.
     * If 0, all related fields are ignored.
     *)
     min_samples:cint;

    (**
     * Maximum number of samples to filter at once. If filter_frame() is
     * called with more samples, it will split them.
     *)
     max_samples:cint;

    (**
     * The buffer reference currently being received across the link by the
     * destination filter. This is used internally by the filter system to
     * allow automatic copying of buffers which do not have sufficient
     * permissions for the destination. This should not be accessed directly
     * by the filters.
     *)
    cur_buf_copy:PAVFilterBufferRef;

    (**
     * True if the link is closed.
     * If set, all attemps of start_frame, filter_frame or request_frame
     * will fail with AVERROR_EOF, and if necessary the reference will be
     * destroyed.
     * If request_frame returns AVERROR_EOF, this flag is set on the
     * corresponding link.
     * It can be set also be set by either the source or the destination
     * filter.
     *)
     closed:cint;

    (**
     * Number of channels.
     *)
     channels:cint;
end;

//internal
 AVFilterPool = record
 pic:array[0..POOL_SIZE-1] of PAVFilterBufferRef;
     count:cint;
     refcount:cint;
     draining:cint;
end;

AVFilterCommand = record
     time:cdouble;                ///< time expressed in seconds
    command:pcchar;              ///< command
    arg:pcchar;                  ///< optional argument for the command
     flags:cint;
    next:PAVFilterCommand;
end;

//end internal

//formats
 (**
 * A list of supported formats for one end of a filter link. This is used
 * during the format negotiation process to try to pick the best format to
 * use to minimize the number of necessary conversions. Each filter gives a
 * list of the formats supported by each input and output pad. The list
 * given for each pad need not be distinct - they may be references to the
 * same list of formats, as is often the case when a filter supports multiple
 * formats, but will always output the same format as it is given in input.
 *
 * In this way, a list of possible input formats and a list of possible
 * output formats are associated with each link. When a set of formats is
 * negotiated over a link, the input and output lists are merged to form a
 * new list containing only the common elements of each list. In the case
 * that there were no common elements, a format conversion is necessary.
 * Otherwise, the lists are merged, and all other links which reference
 * either of the format lists involved in the merge are also affected.
 *
 * For example, consider the filter chain:
 * filter (a) --> (b) filter (b) --> (c) filter
 *
 * where the letters in parenthesis indicate a list of formats supported on
 * the input or output of the link. Suppose the lists are as follows:
 * (a) = {A, B}
 * (b) = {A, B, C}
 * (c) = {B, C}
 *
 * First, the first link's lists are merged, yielding:
 * filter (a) --> (a) filter (a) --> (c) filter
 *
 * Notice that format list (b) now refers to the same list as filter list (a).
 * Next, the lists for the second link are merged, yielding:
 * filter (a) --> (a) filter (a) --> (a) filter
 *
 * where (a) = {B}.
 *
 * Unfortunately, when the format lists at the two ends of a link are merged,
 * we must ensure that all links which reference either pre-merge format list
 * get updated as well. Therefore, we have the format list structure store a
 * pointer to each of the pointers to itself.
 *)
 PPAVFilterFormats=^PAVFilterFormats;
 AVFilterFormats = record
     format_count:cuint;      ///< number of formats
    formats:pcint;               ///< list of media formats

     refcount:cuint;          ///< number of references to this list
    refs:array of PPAVFilterFormats; ///< references to this list
end;

(**
 * A list of supported channel layouts.
 *
 * The list works the same as AVFilterFormats, except for the following
 * differences:
 * - A list with all_layouts = 1 means all channel layouts with a known
 *   disposition; nb_channel_layouts must then be 0.
 * - A list with all_counts = 1 means all channel counts, with a known or
 *   unknown disposition; nb_channel_layouts must then be 0 and all_layouts 1.
 * - The list must not contain a layout with a known disposition and a
 *   channel count with unknown disposition with the same number of channels
 *   (e.g. AV_CH_LAYOUT_STEREO and FF_COUNT2LAYOUT(2).
 *)
PPAVFilterChannelLayouts=^PAVFilterChannelLayouts;
 AVFilterChannelLayouts = record
    channel_layouts:pcuint64;  ///< list of channel layouts
        nb_channel_layouts:cint;  ///< number of channel layouts
     all_layouts:cchar;           ///< accept any known channel layout
     all_counts:cchar;            ///< accept any channel layout or count

     refcount:cuint;          ///< number of references to this list
    refs:array of PPAVFilterChannelLayouts; ///< references to this list
end;

//end formats



(*
 * Return the LIBAVFILTER_VERSION_INT constant.
 *)
function avfilter_version():cuint;

(*
 * Return the libavfilter build-time configuration.
 *)
function avfilter_configuration():pcchar;

(*
 * Return the libavfilter license.
 *)
function avfilter_license():pcchar;

(*
 * Get the class for the AVFilterContext struct.
 *)
function avfilter_get_class():PAVClass;
(**
 * Copy properties of src to dst, without copying the actual data
 *)
procedure avfilter_copy_buffer_ref_props(dst:PAVFilterBufferRef; src:PAVFilterBufferRef);

(**
 * Add a new reference to a buffer.
 *
 * @param ref   an existing reference to the buffer
 * @param pmask a bitmask containing the allowable permissions in the new
 *              reference
 * @return      a new reference to the buffer with the same properties as the
 *              old, excluding any permissions denied by pmask
 *)
 function avfilter_ref_buffer(ref:PAVFilterBufferRef;  pmask:cint):PAVFilterBufferRef;

(**
 * Remove a reference to a buffer. If this is the last reference to the
 * buffer, the buffer itself is also automatically freed.
 *
 * @param ref reference to the buffer, may be NULL
 *
 * @note it is recommended to use avfilter_unref_bufferp() instead of this
 * function
 *)
procedure avfilter_unref_buffer(ref:PAVFilterBufferRef);

(**
 * Remove a reference to a buffer and set the pointer to NULL.
 * If this is the last reference to the buffer, the buffer itself
 * is also automatically freed.
 *
 * @param ref pointer to the buffer reference
 *)
procedure avfilter_unref_bufferp(var ref:PAVFilterBufferRef);

(**
 * Get the number of channels of a buffer reference.
 *)
function avfilter_ref_get_channels(ref:PAVFilterBufferRef):cint;



(**
 * Get the name of an AVFilterPad.
 *
 * @param pads an array of AVFilterPads
 * @param pad_idx index of the pad in the array it; is the caller's
 *                responsibility to ensure the index is valid
 *
 * @return name of the pad_idx'th pad in pads
 *)
function avfilter_pad_get_name(pads:PAVFilterPad;  pad_idx:cint):pcchar;

(**
 * Get the type of an AVFilterPad.
 *
 * @param pads an array of AVFilterPads
 * @param pad_idx index of the pad in the array; it is the caller's
 *                responsibility to ensure the index is valid
 *
 * @return type of the pad_idx'th pad in pads
 *)
function avfilter_pad_get_type(pads:PAVFilterPad;  pad_idx:cint):AVMediaType;



(**
 * Link two filters together.
 *
 * @param src    the source filter
 * @param srcpad index of the output pad on the source filter
 * @param dst    the destination filter
 * @param dstpad index of the input pad on the destination filter
 * @return       zero on success
 *)
function avfilter_link(src:PAVFilterContext; srcpad:cuint;
                  dst:PAVFilterContext; dstpad:cuint):cint;

(**
 * Free the link in *link, and set its pointer to NULL.
 *)
procedure avfilter_link_free(link:PPAVFilterLink);

(**
 * Get the number of channels of a link.
 *)
function avfilter_link_get_channels(link:PAVFilterLink):cint;

(**
 * Set the closed field of a link.
 *)
procedure avfilter_link_set_closed(link:PAVFilterLink;  closed:cint);

(**
 * Negotiate the media format, dimensions, etc of all inputs to a filter.
 *
 * @param filter the filter to negotiate the properties for its inputs
 * @return       zero on successful negotiation
 *)
function avfilter_config_links(filter:PAVFilterContext):cint;

(**
 * Create a buffer reference wrapped around an already allocated image
 * buffer.
 *
 * @param data pointers to the planes of the image to reference
 * @param linesize linesizes for the planes of the image to reference
 * @param perms the required access permissions
 * @param w the width of the image specified by the data and linesize arrays
 * @param h the height of the image specified by the data and linesize arrays
 * @param format the pixel format of the image specified by the data and linesize arrays
 *)
function
avfilter_get_video_buffer_ref_from_arrays(const data:array[0..3] of pcuint8; const linesize:array[0..3] of cint; perms:cint;
                                           w:cint;  h:cint; format:AVPixelFormat):PAVFilterBufferRef;

(**
 * Create an audio buffer reference wrapped around an already
 * allocated samples buffer.
 *
 * See avfilter_get_audio_buffer_ref_from_arrays_channels() for a version
 * that can handle unknown channel layouts.
 *
 * @param data           pointers to the samples plane buffers
 * @param linesize       linesize for the samples plane buffers
 * @param perms          the required access permissions
 * @param nb_samples     number of samples per channel
 * @param sample_fmt     the format of each sample in the buffer to allocate
 * @param channel_layout the channel layout of the buffer
 *)
function avfilter_get_audio_buffer_ref_from_arrays(data:ppcuint8;
                                                             linesize:cint;
                                                             perms:cint;
                                                             nb_samples:cint;
                                                             sample_fmt:AVSampleFormat;
                                                             channel_layout:cuint64):PAVFilterBufferRef;
(**
 * Create an audio buffer reference wrapped around an already
 * allocated samples buffer.
 *
 * @param data           pointers to the samples plane buffers
 * @param linesize       linesize for the samples plane buffers
 * @param perms          the required access permissions
 * @param nb_samples     number of samples per channel
 * @param sample_fmt     the format of each sample in the buffer to allocate
 * @param channels       the number of channels of the buffer
 * @param channel_layout the channel layout of the buffer,
 *                       must be either 0 or consistent with channels
 *)
function avfilter_get_audio_buffer_ref_from_arrays_channels(data:ppcuint8;
                                                                      linesize:cint;
                                                                      perms:cint;
                                                                      nb_samples:cint;
                                                                      sample_fmt:AVSampleFormat;
                                                                      int channels:cint;
                                                                      channel_layout:cuint64):PAVFilterBufferRef;



(**
 * Make the filter instance process a command.
 * It is recommended to use avfilter_graph_send_command().
 *)
function avfilter_process_command(filt:PAVFilterContexter; cmd:pcchar; arg:pcchar; res:pcchar; res_len:cint;flags:cint):cint;

(** Initialize the filter system. Register all builtin filters. *)
procedure avfilter_register_all();

(** Uninitialize the filter system. Unregister all filters. *)
procedure avfilter_uninit();

(**
 * Register a filter. This is only needed if you plan to use
 * avfilter_get_by_name later to lookup the AVFilter structure by name. A
 * filter can still by instantiated with avfilter_open even if it is not
 * registered.
 *
 * @param filter the filter to register
 * @return 0 if the registration was successful, a negative value
 * otherwise
 *)
function avfilter_register(filter:PAVFilter):cint;

(**
 * Get a filter definition matching the given name.
 *
 * @param name the filter name to find
 * @return     the filter definition, if any matching one is registered.
 *             NULL if none found.
 *)
function avfilter_get_by_name(name:pcchar):PAVFilter;

(**
 * If filter is NULL, returns a pointer to the first registered filter pointer,
 * if filter is non-NULL, returns the next pointer after filter.
 * If the returned pointer points to NULL, the last registered filter
 * was already reached.
 *)
function av_filter_next(filter:PPAVFilter):PPAVFilter;

(**
 * Create a filter instance.
 *
 * @param filter_ctx put here a pointer to the created filter context
 * on success, NULL on failure
 * @param filter    the filter to create an instance of
 * @param inst_name Name to give to the new instance. Can be NULL for none.
 * @return >= 0 in case of success, a negative error code otherwise
 *)
function avfilter_open(filter_ctx:PPAVFilterContext; filter:PAVFilter;inst_name:pcchar):cint;

(**
 * Initialize a filter.
 *
 * @param filter the filter to initialize
 * @param args   A string of parameters to use when initializing the filter.
 *               The format and meaning of this string varies by filter.
 * @param opaque Any extra non-string data needed by the filter. The meaning
 *               of this parameter varies by filter.
 * @return       zero on success
 *)
function avfilter_init_filter(filt:PAVFilterContexter; args:pcchar; opaque:pointer):cint;

(**
 * Free a filter context.
 *
 * @param filter the filter to free
 *)
procedure avfilter_free(filt:PAVFilterContexter);

(**
 * Insert a filter in the middle of an existing link.
 *
 * @param link the link into which the filter should be inserted
 * @param filt the filter to be inserted
 * @param filt_srcpad_idx the input pad on the filter to connect
 * @param filt_dstpad_idx the output pad on the filter to connect
 * @return     zero on success
 *)
function avfilter_insert_filter(link:PAVFilterLink; filt:PAVFilterContext;
                           filt_srcpad_idx:cuint; filt_dstpad_idx:cuint):cint;

implementation

end.
