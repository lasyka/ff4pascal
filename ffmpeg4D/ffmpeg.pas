unit ffmpeg;

interface

uses
  ctypes;

const
  VSYNC_AUTO = -1;
  VSYNC_PASSTHROUGH = 0;
  VSYNC_CFR = 1;
  VSYNC_VFR = 2;
  VSYNC_DROP = $FF;

  MAX_STREAMS = 1024; // * arbitrary sanity check value */
  // * select an input stream for an output stream */
type
  StreamMap = record
    disabled: cint; // * 1 is this mapping is disabled by a negative map */
    file_index: cint;
    stream_index: cint;
    sync_file_index: cint;
    sync_stream_index: cint;
    linklabel: pcchar; // * name of an output link, for mapping lavfi outputs */
  end;

  AudioChannelMap = record
    file_idx: cint;  stream_idx: cint;  channel_idx: cint; // input
    ofile_idx: cint; ostream_idx: cint;               // output
  end;

  OptionsContext = record
    g:POptionGroup;

    //* input/output options */
    int64_t start_time;
    const char *format;

    SpecifierOpt *codec_names;
    int        nb_codec_names;
    SpecifierOpt *audio_channels;
    int        nb_audio_channels;
    SpecifierOpt *audio_sample_rate;
    int        nb_audio_sample_rate;
    SpecifierOpt *frame_rates;
    int        nb_frame_rates;
    SpecifierOpt *frame_sizes;
    int        nb_frame_sizes;
    SpecifierOpt *frame_pix_fmts;
    int        nb_frame_pix_fmts;

    /* input options */
    int64_t input_ts_offset;
    int rate_emu;

    SpecifierOpt *ts_scale;
    int        nb_ts_scale;
    SpecifierOpt *dump_attachment;
    int        nb_dump_attachment;

    /* output options */
    StreamMap *stream_maps;
    int     nb_stream_maps;
    AudioChannelMap *audio_channel_maps; /* one info entry per -map_channel */
    int           nb_audio_channel_maps; /* number of (valid) -map_channel settings */
    int metadata_global_manual;
    int metadata_streams_manual;
    int metadata_chapters_manual;
    const char **attachments;
    int       nb_attachments;

    int chapters_input_file;

    int64_t recording_time;
    int64_t stop_time;
    uint64_t limit_filesize;
    float mux_preload;
    float mux_max_delay;
    int shortest;

    int video_disable;
    int audio_disable;
    int subtitle_disable;
    int data_disable;

    /* indexed by output file stream index */
    int   *streamid_map;
    int nb_streamid_map;

    SpecifierOpt *metadata;
    int        nb_metadata;
    SpecifierOpt *max_frames;
    int        nb_max_frames;
    SpecifierOpt *bitstream_filters;
    int        nb_bitstream_filters;
    SpecifierOpt *codec_tags;
    int        nb_codec_tags;
    SpecifierOpt *sample_fmts;
    int        nb_sample_fmts;
    SpecifierOpt *qscale;
    int        nb_qscale;
    SpecifierOpt *forced_key_frames;
    int        nb_forced_key_frames;
    SpecifierOpt *force_fps;
    int        nb_force_fps;
    SpecifierOpt *frame_aspect_ratios;
    int        nb_frame_aspect_ratios;
    SpecifierOpt *rc_overrides;
    int        nb_rc_overrides;
    SpecifierOpt *intra_matrices;
    int        nb_intra_matrices;
    SpecifierOpt *inter_matrices;
    int        nb_inter_matrices;
    SpecifierOpt *top_field_first;
    int        nb_top_field_first;
    SpecifierOpt *metadata_map;
    int        nb_metadata_map;
    SpecifierOpt *presets;
    int        nb_presets;
    SpecifierOpt *copy_initial_nonkeyframes;
    int        nb_copy_initial_nonkeyframes;
    SpecifierOpt *copy_prior_start;
    int        nb_copy_prior_start;
    SpecifierOpt *filters;
    int        nb_filters;
    SpecifierOpt *reinit_filters;
    int        nb_reinit_filters;
    SpecifierOpt *fix_sub_duration;
    int        nb_fix_sub_duration;
    SpecifierOpt *pass;
    int        nb_pass;
    SpecifierOpt *passlogfiles;
    int        nb_passlogfiles;
    SpecifierOpt *guess_layout_max;
    int        nb_guess_layout_max;
  end;

typedef struct InputFilter {
    AVFilterContext    *filter;
    struct InputStream *ist;
    struct FilterGraph *graph;
    uint8_t            *name;
} InputFilter;

typedef struct OutputFilter {
    AVFilterContext     *filter;
    struct OutputStream *ost;
    struct FilterGraph  *graph;
    uint8_t             *name;

    /* temporary storage until stream maps are processed */
    AVFilterInOut       *out_tmp;
} OutputFilter;

typedef struct FilterGraph {
    int            index;
    const char    *graph_desc;

    AVFilterGraph *graph;
    int reconfiguration;

    InputFilter   **inputs;
    int          nb_inputs;
    OutputFilter **outputs;
    int         nb_outputs;
} FilterGraph;

typedef struct InputStream {
    int file_index;
    AVStream *st;
    int discard;             /* true if stream data should be discarded */
    int decoding_needed;     /* true if the packets must be decoded in 'raw_fifo' */
    AVCodec *dec;
    AVFrame *decoded_frame;

    int64_t       start;     /* time when read started */
    /* predicted dts of the next packet read for this stream or (when there are
     * several frames in a packet) of the next frame in current packet (in AV_TIME_BASE units) */
    int64_t       next_dts;
    int64_t       dts;       ///< dts of the last packet read for this stream (in AV_TIME_BASE units)

    int64_t       next_pts;  ///< synthetic pts for the next decode frame (in AV_TIME_BASE units)
    int64_t       pts;       ///< current pts of the decoded frame  (in AV_TIME_BASE units)
    int           wrap_correction_done;

    int64_t filter_in_rescale_delta_last;

    double ts_scale;
    int is_start;            /* is 1 at the start and after a discontinuity */
    int saw_first_ts;
    int showed_multi_packet_warning;
    AVDictionary *opts;
    AVRational framerate;               /* framerate forced with -r */
    int top_field_first;
    int guess_layout_max;

    int resample_height;
    int resample_width;
    int resample_pix_fmt;

    int      resample_sample_fmt;
    int      resample_sample_rate;
    int      resample_channels;
    uint64_t resample_channel_layout;

    int fix_sub_duration;
    struct { /* previous decoded subtitle and related variables */
        int got_output;
        int ret;
        AVSubtitle subtitle;
    } prev_sub;

    struct sub2video {
        int64_t last_pts;
        int64_t end_pts;
        AVFilterBufferRef *ref;
        int w, h;
    } sub2video;

    /* a pool of free buffers for decoded data */
    FrameBuffer *buffer_pool;
    int dr1;

    /* decoded data from this stream goes into all those filters
     * currently video and audio only */
    InputFilter **filters;
    int        nb_filters;

    int reinit_filters;
} InputStream;

typedef struct InputFile {
    AVFormatContext *ctx;
    int eof_reached;      /* true if eof reached */
    int eagain;           /* true if last read attempt returned EAGAIN */
    int ist_index;        /* index of first stream in input_streams */
    int64_t ts_offset;
    int nb_streams;       /* number of stream that ffmpeg is aware of; may be different
                             from ctx.nb_streams if new streams appear during av_read_frame() */
    int nb_streams_warn;  /* number of streams that the user was warned of */
    int rate_emu;

#if HAVE_PTHREADS
    pthread_t thread;           /* thread reading from this file */
    int finished;               /* the thread has exited */
    int joined;                 /* the thread has been joined */
    pthread_mutex_t fifo_lock;  /* lock for access to fifo */
    pthread_cond_t  fifo_cond;  /* the main thread will signal on this cond after reading from fifo */
    AVFifoBuffer *fifo;         /* demuxed packets are stored here; freed by the main thread */
#endif
} InputFile;

enum forced_keyframes_const {
    FKF_N,
    FKF_N_FORCED,
    FKF_PREV_FORCED_N,
    FKF_PREV_FORCED_T,
    FKF_T,
    FKF_NB
};

extern const char *const forced_keyframes_const_names[];

typedef struct OutputStream {
    int file_index;          /* file index */
    int index;               /* stream index in the output file */
    int source_index;        /* InputStream index */
    AVStream *st;            /* stream in the output file */
    int encoding_needed;     /* true if encoding needed for this stream */
    int frame_number;
    /* input pts and corresponding output pts
       for A/V sync */
    struct InputStream *sync_ist; /* input stream to sync against */
    int64_t sync_opts;       /* output frame counter, could be changed to some true timestamp */ // FIXME look at frame_number
    /* pts of the first frame encoded for this stream, used for limiting
     * recording time */
    int64_t first_pts;
    AVBitStreamFilterContext *bitstream_filters;
    AVCodec *enc;
    int64_t max_frames;
    AVFrame *filtered_frame;

    /* video only */
    AVRational frame_rate;
    int force_fps;
    int top_field_first;

    float frame_aspect_ratio;

    /* forced key frames */
    int64_t *forced_kf_pts;
    int forced_kf_count;
    int forced_kf_index;
    char *forced_keyframes;
    AVExpr *forced_keyframes_pexpr;
    double forced_keyframes_expr_const_values[FKF_NB];

    /* audio only */
    int audio_channels_map[SWR_CH_MAX];  /* list of the channels id to pick from the source stream */
    int audio_channels_mapped;           /* number of channels in audio_channels_map */

    char *logfile_prefix;
    FILE *logfile;

    OutputFilter *filter;
    char *avfilter;

    int64_t sws_flags;
    AVDictionary *opts;
    AVDictionary *swr_opts;
    AVDictionary *resample_opts;
    int finished;        /* no more packets should be written for this stream */
    int unavailable;                     /* true if the steram is unavailable (possibly temporarily) */
    int stream_copy;
    const char *attachment_filename;
    int copy_initial_nonkeyframes;
    int copy_prior_start;

    int keep_pix_fmt;
} OutputStream;

typedef struct OutputFile {
    AVFormatContext *ctx;
    AVDictionary *opts;
    int ost_index;       /* index of the first stream in output_streams */
    int64_t recording_time;  ///< desired length of the resulting file in microseconds == AV_TIME_BASE units
    int64_t start_time;      ///< start time in microseconds == AV_TIME_BASE units
    uint64_t limit_filesize; /* filesize limit expressed in bytes */

    int shortest;
} OutputFile;

implementation

end.
