unit ffmpeg;

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
  ctypes,cmdutils;

const
  VSYNC_AUTO = -1;
  VSYNC_PASSTHROUGH = 0;
  VSYNC_CFR = 1;
  VSYNC_VFR = 2;
  VSYNC_DROP = $FF;

  MAX_STREAMS = 1024; // * arbitrary sanity check value *)

  // * select an input stream for an output stream *)
type
  StreamMap = record
    disabled: cint; // * 1 is this mapping is disabled by a negative map *)
    file_index: cint;
    stream_index: cint;
    sync_file_index: cint;
    sync_stream_index: cint;
    linklabel: pcchar; // * name of an output link, for mapping lavfi outputs *)
  end;

  AudioChannelMap = record
    file_idx: cint;
    stream_idx: cint;
    channel_idx: cint; // input
    ofile_idx: cint;
    ostream_idx: cint; // output
  end;

  OptionsContext = record
    g: POptionGroup;

    (* input/output options *)
    start_time: cint64;
    format: pcchar;

    codec_names: PSpecifierOpt;
    nb_codec_names: cint;
    audio_channels: PSpecifierOpt;
    nb_audio_channels: cint;
    audio_sample_rate: PSpecifierOpt;
    nb_audio_sample_rate: cint;
    frame_rates: PSpecifierOpt;
    nb_frame_rates: cint;
    frame_sizes: PSpecifierOpt;
    nb_frame_sizes: cint;
    frame_pix_fmts: PSpecifierOpt;
    nb_frame_pix_fmts: cint;

    (* input options *)
    input_ts_offset: cint64;
    rate_emu: cint;

    ts_scale: PSpecifierOpt;
    nb_ts_scale: cint;
    dump_attachment: PSpecifierOpt;
    nb_dump_attachment: cint;

    (* output options *)
    stream_maps: PStreamMap;
    nb_stream_maps: cint;
    audio_channel_maps: PAudioChannelMap; (* one info entry per -map_channel *)
    nb_audio_channel_maps: cint; (* number of (valid) -map_channel settings *)
    metadata_global_manual: cint;
    metadata_streams_manual: cint;
    metadata_chapters_manual: cint;
    attachments: array of pcchar;
    nb_attachments: cint;

    chapters_input_file: cint;

    recording_time: cint64;
    stop_time: cint64;
    limit_filesize: cuint64;
    mux_preload: cfloat;
    mux_max_delay: cfloat;
    shortest: cint;

    video_disable: cint;
    audio_disable: cint;
    subtitle_disable: cint;
    data_disable: cint;

    (* indexed by output file stream index *)
    streamid_map: pcint;
    nb_streamid_map: cint;

    metadata: PSpecifierOpt;
    nb_metadata: cint;
    max_frames: PSpecifierOpt;
    nb_max_frames: cint;
    bitstream_filters: PSpecifierOpt;
    nb_bitstream_filters: cint;
    codec_tags: PSpecifierOpt;
    nb_codec_tags: cint;
    sample_fmts: PSpecifierOpt;
    nb_sample_fmts: cint;
    qscale: PSpecifierOpt;
    nb_qscale: cint;
    forced_key_frames: PSpecifierOpt;
    nb_forced_key_frames: cint;
    force_fps: PSpecifierOpt;
    nb_force_fps: cint;
    frame_aspect_ratios: PSpecifierOpt;
    nb_frame_aspect_ratios: cint;
    rc_overrides: PSpecifierOpt;
    nb_rc_overrides: cint;
    intra_matrices: PSpecifierOpt;
    nb_intra_matrices: cint;
    inter_matrices: PSpecifierOpt;
    nb_inter_matrices: cint;
    top_field_first: PSpecifierOpt;
    nb_top_field_first: cint;
    metadata_map: PSpecifierOpt;
    nb_metadata_map: cint;
    presets: PSpecifierOpt;
    nb_presets: cint;
    copy_initial_nonkeyframes: PSpecifierOpt;
    nb_copy_initial_nonkeyframes: cint;
    copy_prior_start: PSpecifierOpt;
    nb_copy_prior_start: cint;
    filters: PSpecifierOpt;
    nb_filters: cint;
    reinit_filters: PSpecifierOpt;
    nb_reinit_filters: cint;
    fix_sub_duration: PSpecifierOpt;
    nb_fix_sub_duration: cint;
    pass: PSpecifierOpt;
    nb_pass: cint;
    passlogfiles: PSpecifierOpt;
    nb_passlogfiles: cint;
    guess_layout_max: PSpecifierOpt;
    nb_guess_layout_max: cint;
  end;

  InputFilter = record
    filter: PAVFilterContext;
    ist: PInputStream;
    graph: PFilterGraph;
    name: cuint8;
  end;

  OutputFilter = record
    filter: PAVFilterContext;
    ost: POutputStream;
    graph: PFilterGraph;
    name: pcuint8;

    (* temporary storage until stream maps are processed *)
    out_tmp: PAVFilterInOut;
  end;

  PrevSub = record
    (* previous decoded subtitle and related variables *)
    got_output: cint;
    ret: cint;
    subtitle: AVSubtitle;
  end;

  TSub2Video = record
    last_pts: cint64;
    end_pts: cint64;
    ref: PAVFilterBufferRef;
    w, h: cint;
  end;

  FilterGraph = record
    index: cint;

    graph_desc: pcchar;

    graph: PAVFilterGraph;
    reconfiguration: cint;

    inputs: array of PInputFilter;
    nb_inputs: cint;
    outputs: array of POutputFilter;
    nb_outputs: cint;
  end;

  InputStream = record
    file_index: cint;
    st: PAVStream;
    discard: cint; (* true if stream data should be discarded *)
    decoding_needed: cint;
    (* true if the packets must be decoded in 'raw_fifo' *)
    dec: PAVCodec;
    decoded_frame: PAVFrame;

    start: cint64; (* time when read started *)
    (* predicted dts of the next packet read for this stream or (when there are
      * several frames in a packet) of the next frame in current packet (in AV_TIME_BASE units) *)
    next_dts: cint64;
    dts: cint64;
    /// < dts of the last packet read for this stream (in AV_TIME_BASE units)

    next_pts: cint64;
    /// < synthetic pts for the next decode frame (in AV_TIME_BASE units)
    pts: cint64;
    /// < current pts of the decoded frame  (in AV_TIME_BASE units)
    wrap_correction_done: cint;

    filter_in_rescale_delta_last: cint64;

    ts_scale: cdouble;
    is_start: cint; (* is 1 at the start and after a discontinuity *)
    saw_first_ts: cint;
    showed_multi_packet_warning: cint;
    opts: PAVDictionary;
    framerate: AVRational; (* framerate forced with -r *)
    top_field_first: cint;
    guess_layout_max: cint;

    resample_height: cint;
    resample_width: cint;
    resample_pix_fmt: cint;

    resample_sample_fmt: cint;
    resample_sample_rate: cint;
    resample_channels: cint;
    resample_channel_layout: cuint64;

    fix_sub_duration: cint;
    prev_sub: PrevSub;
    sub2video: TSub2Video;

    (* a pool of free buffers for decoded data *)
    buffer_pool: PFrameBuffer;
    dr1: cint;

    (* decoded data from this stream goes into all those filters
      * currently video and audio only *)
    filters: PPInputFilter;
    nb_filters: cint;

    reinit_filters: cint;
  end;

  InputFile = record
    ctx: PAVFormatContext;
    eof_reached: cint; (* true if eof reached *)
    eagain: cint; (* true if last read attempt returned EAGAIN *)
    ist_index: cint; (* index of first stream in input_streams *)
    ts_offset: cint64;
    nb_streams: cint;
    (* number of stream that ffmpeg is aware of; may be different
      from ctx.nb_streams if new streams appear during av_read_frame() *)
    nb_streams_warn: cint; (* number of streams that the user was warned of *)
    rate_emu: cint;

{$IF HAVE_PTHREADS}
    thread: pthread_t; (* thread reading from this file *)
    finished: cint; (* the thread has exited *)
    joined: cint; (* the thread has been joined *)
    fifo_lock: pthread_mutex_t; (* lock for access to fifo *)
    fifo_cond: pthread_cond_t;
    (* the main thread will signal on this cond after reading from fifo *)
    fifo: PAVFifoBuffer;
    (* demuxed packets are stored here; freed by the main thread *)
{$IFEND}
  end;

  forced_keyframes_const = (FKF_N, FKF_N_FORCED, FKF_PREV_FORCED_N,
    FKF_PREV_FORCED_T, FKF_T, FKF_NB);

  // extern const char *const forced_keyframes_const_names[];

  OutputStream = record
    file_index: cint; (* file index *)
    index: cint; (* stream index in the output file *)
    source_index: cint; (* InputStream index *)
    st: PAVStream; (* stream in the output file *)
    encoding_needed: cint; (* true if encoding needed for this stream *)
    frame_number: cint;
    (* input pts and corresponding output pts
      for A/V sync *)
    sync_ist: PInputStream; (* input stream to sync against *)
    sync_opts: cint64;
    (* output frame counter, could be changed to some true timestamp *)
    // FIXME look at frame_number
    (* pts of the first frame encoded for this stream, used for limiting
      * recording time *)
    first_pts: cint64;
    bitstream_filters: PAVBitStreamFilterContext;
    enc: PAVCodec;
    max_frames: cint64;
    filtered_frame: PAVFrame;

    (* video only *)
    frame_rate: AVRational;
    int force_fps: cint;
    int top_field_first: cint;

    float frame_aspect_ratio: cfloat;

    (* forced key frames *)
    int64_t * forced_kf_pts: pcint64;
    int forced_kf_count: cint;
    int forced_kf_index: cint;
    char * forced_keyframes: pcchar;
    forced_keyframes_pexpr: PAVExpr;
    forced_keyframes_expr_const_values: array [0 .. FKF_NB - 1] of cdouble;

    (* audio only *)
    audio_channels_map: array [0 .. SWR_CH_MAX - 1] of cint;
    (* list of the channels id to pick from the source stream *)
    audio_channels_mapped: cint; (* number of channels in audio_channels_map *)

    logfile_prefix: pcchar;
    logfile: PFile;

    filter: POutputFilter;
    avfilter: pcchar;

    int64_t sws_flags: cint64;
    opts: PAVDictionary;
    swr_opts: PAVDictionary;
    resample_opts: PAVDictionary;
    finished: cint; (* no more packets should be written for this stream *)
    unavailable: cint;
    (* true if the steram is unavailable (possibly temporarily) *)
    stream_copy: cint;

    attachment_filename: pcchar;
    copy_initial_nonkeyframes: cint;
    copy_prior_start: cint;

    keep_pix_fmt: cint;
  end;

  OutputFile = record
    ctx: PAVFormatContext;
    opts: PAVDictionary;
    ost_index: cint; (* index of the first stream in output_streams *)
    recording_time: cint64;
    /// < desired length of the resulting file in microseconds == AV_TIME_BASE units
    start_time: cint64;
    /// < start time in microseconds == AV_TIME_BASE units
    limit_filesize: cint64; (* filesize limit expressed in bytes *)

    shortest: cint;
  end;

implementation

end.
