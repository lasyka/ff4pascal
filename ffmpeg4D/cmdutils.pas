unit cmdutils;

interface

uses
  ctypes;

const
  HAS_ARG = $0001;
  OPT_BOOL = $0002;
  OPT_EXPERT = $0004;
  OPT_STRING = $0008;
  OPT_VIDEO = $0010;
  OPT_AUDIO = $0020;
  OPT_INT = $0080;
  OPT_FLOAT = $0100;
  OPT_SUBTITLE = $0200;
  OPT_INT64 = $0400;
  OPT_EXIT = $0800;
  OPT_DATA = $1000;
  OPT_PERFILE = $2000;
  // * the option is per-file (currently ffmpeg-only).implied by OPT_OFFSET or OPT_SPEC *)
  OPT_OFFSET = $4000;
  // * option is specified as an offset in a passed optctx *)
  OPT_SPEC = $8000;
  // * option is to be stored in an array of SpecifierOpt.Implies OPT_OFFSET. Next element after the offset isan int containing element count in the array. *)
  OPT_TIME = $10000;
  OPT_DOUBLE = $20000;

type
  ParseArgFunction = procedure(optctx: Pointer; arg: pcchar);

  SpecifierOptUArg = record
    case Integer of
      0:
        (str: pcuint8);
      1:
        (i: cint);
      2:
        (i64: cint64);
      3:
        (f: cfloat);
      4:
        (dbl: cdouble);
  end;

  PSpecifierOpt = ^SpecifierOpt;

  SpecifierOpt = record
    specifier: pcchar; (* *< stream/chapter/program/... specifier *)
    (* union {
      uint8_t *str;
      int        i;
      int64_t  i64;
      float      f;
      double   dbl;
      } u;
    *)
    u: SpecifierOptUArg;
  end;

  FuncArg = function(p: Pointer; c1: pcchar; c2: pcchar): cint;

  OptionDefUArg = record
    case Integer of
      0:
        (dst_ptr: Pointer);
      1:
        (func_arg: FuncArg);
      2:
        (off: cuint);
  end;

  POptionDef = ^OptionDef;

  OptionDef = record
    name: pcchar;
    flags: cint;
    u: OptionDefUArg;
    help: pcchar;
    argname: pcchar;
  end;

  POption = ^Option;

  (* *
    * An option extracted from the commandline.
    * Cannot use AVDictionary because of options like -map which can be
    * used multiple times.
  *)
  Option = record
    opt: POptionDef;
    key: pcchar;
    val: pcchar;
  end;

  POptionGroupDef = ^OptionGroupDef;

  OptionGroupDef = record
    (* *< group name *)
    name: pcchar;
    (* *
      * Option to be used as group separator. Can be NULL for groups which
      * are terminated by a non-option argument (e.g. ffmpeg output files)
    *)
    sep: pcchar;
  end;

  POptionGroup = ^OptionGroup;

  OptionGroup = record
    group_def: POptionGroupDef;
    arg: pcchar;

    opts: POption;
    nb_opts: cint;

    codec_opts: PAVDictionary;
    format_opts: PAVDictionary;
    resample_opts: PAVDictionary;
    sws_opts: PSwsContext;
    swr_opts: PAVDictionary;
  end;

  POptionGroupList = ^OptionGroupList;

  (* *
    * A list of option groups that all have the same group type
    * (e.g. input files or output files)
  *)
  OptionGroupList = record
    group_def: POptionGroupDef;

    groups: POptionGroup;
    nb_groups: cint;
  end;

  POptionParseContext = ^OptionParseContext;

  OptionParseContext = record
    global_opts: OptionGroup;

    groups: POptionGroupList;
    nb_groups: cint;

    // * parsing state *)
    cur_group: OptionGroup;
  end;

  PFrameBuffer=^FrameBuffer;
  FrameBuffer = record
    base: array [0 .. 3] of pcuint8;
    data: array [0 .. 3] of pcuint8;
    linesize: array [0 .. 3] of cint;

    h, w: cint;
    pix_fmt: AVPixelFormat;

    refcount: cint;
    pool: PPFrameBuffer;
    /// < head of the buffer pool
    next: PFrameBuffer;
  end;

  PCmdUtil = ^TCmdUtil;

  TCmdUtil = class
  protected
  // program name, defined by the program for show_version().*)
    const
    program_name: array of cchar;

    // program birth year, defined by the program for show_banner()
  const
    program_birth_year: cint;

    // this year, defined by the program for show_banner()
  const
    this_year: cint;
    avcodec_opts: array [0 .. AVMEDIA_TYPE_NB - 1] of PAVCodecContext;
    avformat_opts: PAVFormatContext;
    sws_opts: PSwsContext;
    swr_opts: PAVDictionary;
    format_opts, codec_opts, resample_opts: PAVDictionary;
    (* *
      * Initialize the cmdutils option system, in particular
      * allocate the *_opts contexts.
    *)
    procedure init_opts;

    (* *
      * Uninitialize the cmdutils option system, in particular
      * free the *_opts contexts and their contents.
    *)
    procedure uninit_opts;

    (* *
      * Trivial log callback.
      * Only suitable for opt_help and similar since it lacks prefix handling.
    *)
    procedure log_callback_help(ptr: Pointer; level: cint;
      fmt: { const } pcchar; vl: va_list);

    (* *
      * Fallback for options that are not explicitly handled, these will be
      * parsed through AVOptions.
    *)
    function opt_default(optctx: Pointer; { const } opt: pcchar;
      { const } arg: pcchar): cint;

    (* *
      * Set the libav* libraries log level.
    *)
    function opt_loglevel(optctx: Pointer; { const } opt: pcchar;
      { const } arg: pcchar): cint;

    function opt_report( { const } opt: pcchar): cint;

    function opt_max_alloc(optctx: Pointer; { const } opt: pcchar;
      { const } arg: pcchar): cint;

    function opt_cpuflags(optctx: Pointer; { const } opt: pcchar;
      { const } arg: pcchar): cint;

    function opt_codec_debug(optctx: Pointer; { const } opt: pcchar;
      { const } arg: pcchar): cint;

    (* *
      * Limit the execution time.
    *)
    function opt_timelimit(optctx: Pointer; { const } opt: pcchar;
      { const } arg: pcchar): cint;

    (* *
      * Parse a string and return its corresponding value as a double.
      * Exit from the application if the string cannot be correctly
      * parsed or the corresponding value is invalid.
      *
      * @param context the context of the value to be set (e.g. the
      * corresponding command line option name)
      * @param numstr the string to be parsed
      * @param type the type (OPT_INT64 or OPT_FLOAT) as which the
      * string should be parsed
      * @param min the minimum valid accepted value
      * @param max the maximum valid accepted value
    *)
    function parse_number_or_die( { const } context, { const } numstr: pcchar;
      atype: cint; min: cdouble; max: cdouble): cdouble;

    (* *
      * Parse a string specifying a time and return its corresponding
      * value as a number of microseconds. Exit from the application if
      * the string cannot be correctly parsed.
      *
      * @param context the context of the value to be set (e.g. the
      * corresponding command line option name)
      * @param timestr the string to be parsed
      * @param is_duration a flag which tells how to interpret timestr, if
      * not zero timestr is interpreted as a duration, otherwise as a
      * date
      *
      * @see av_parse_time()
    *)
    function parse_time_or_die( { const } context: pcchar;
      { const } timestr: pcchar; is_duration: cint): cint64;

    (* *
      * Print help for all options matching specified flags.
      *
      * @param options a list of options
      * @param msg title of this group. Only printed if at least one option matches.
      * @param req_flags print only options which have all those flags set.
      * @param rej_flags don't print options which have any of those flags set.
      * @param alt_flags print only options that have at least one of those flags set
    *)
    procedure show_help_options(options: POptionDef; msg: pcchar;
      req_flags: cint; rej_flags: cint; alt_flags: cint);

    (* *
      * Show help for all options with given flags in class and all its
      * children.
    *)
    procedure show_help_children(avclass: PAVClass; flags: cint);

    (* *
      * Per-avtool specific help handler. Implemented in each
      * avtool, called by show_help().
    *)
    procedure show_help_default(opt: pcchar; arg: pcchar);

    (* *
      * Generic -h handler common to all avtools.
    *)
    procedure show_help(optctx: Pointer; opt: pcchar; arg: pcchar);

    (* *
      * Parse the command line arguments.
      *
      * @param optctx an opaque options context
      * @param argc   number of command line arguments
      * @param argv   values of command line arguments
      * @param options Array with the definitions required to interpret every
      * option of the form: -option_name [argument]
      * @param parse_arg_function Name of the function called to process every
      * argument without a leading option name flag. NULL if such arguments do
      * not have to be processed.
    *)
    procedure parse_options(optctx: Pointer; argc: cint; argv: array of pcchar;
      options: OptionDef; parse_arg_function: ParseArgFunction);

    (* *
      * Parse one given option.
      *
      * @return on success 1 if arg was consumed, 0 otherwise; negative number on error
    *)
    function parse_option(optctx: Pointer; opt: pcchar; arg: pcchar;
      options: POptionDef): cint;

    (* *
      * Parse an options group and write results into optctx.
      *
      * @param optctx an app-specific options context. NULL for global options group
    *)
    function parse_optgroup(optctx: Pointer; g: POptionGroup): cint;

    (* *
      * Split the commandline into an intermediate form convenient for further
      * processing.
      *
      * The commandline is assumed to be composed of options which either belong to a
      * group (those with OPT_SPEC, OPT_OFFSET or OPT_PERFILE) or are global
      * (everything else).
      *
      * A group (defined by an OptionGroupDef struct) is a sequence of options
      * terminated by either a group separator option (e.g. -i) or a parameter that
      * is not an option (doesn't start with -). A group without a separator option
      * must always be first in the supplied groups list.
      *
      * All options within the same group are stored in one OptionGroup struct in an
      * OptionGroupList, all groups with the same group definition are stored in one
      * OptionGroupList in OptionParseContext.groups. The order of group lists is the
      * same as the order of group definitions.
    *)
    function split_commandline(octx: POptionParseContext; argc: cint;
      argv: array of pcchar; options: POptionDef; groups: POptionGroupDef;
      nb_groups: cint): cint;

    (* *
      * Free all allocated memory in an OptionParseContext.
    *)
    procedure uninit_parse_context(octx: POptionParseContext);

    (* *
      * Find the '-loglevel' option in the command line args and apply it.
    *)
    procedure parse_loglevel(argc: cint; argv: array of pcchar;
      options: POptionDef);

    (* *
      * Return index of option opt in argv or 0 if not found.
    *)
    function locate_option(argc: cint; argv: array of pcchar;
      options: POptionDef; optname: pcchar): cint;

    (* *
      * Check if the given stream matches a stream specifier.
      *
      * @param s  Corresponding format context.
      * @param st Stream from s to be checked.
      * @param spec A stream specifier of the [v|a|s|d]:[\<stream index\>] form.
      *
      * @return 1 if the stream matches, 0 if it doesn't, <0 on error
    *)
    function check_stream_specifier(s: PAVFormatContext; st: PAVStream;
      spec: pcchar): cint;

    (* *
      * Filter out options for given codec.
      *
      * Create a new options dictionary containing only the options from
      * opts which apply to the codec with ID codec_id.
      *
      * @param opts     dictionary to place options in
      * @param codec_id ID of the codec that should be filtered for
      * @param s Corresponding format context.
      * @param st A stream from s for which the options should be filtered.
      * @param codec The particular codec for which the options should be filtered.
      *              If null, the default one is looked up according to the codec id.
      * @return a pointer to the created dictionary
    *)
    function filter_codec_opts(opts: AVDictionary; codec_id: AVCodecID;
      s: PAVFormatContext; st: PAVStream; codec: PAVCodec): PAVDictionary;

    (* *
      * Setup AVCodecContext options for avformat_find_stream_info().
      *
      * Create an array of dictionaries, one dictionary for each stream
      * contained in s.
      * Each dictionary will contain the options from codec_opts which can
      * be applied to the corresponding stream codec context.
      *
      * @return pointer to the created array of dictionaries, NULL if it
      * cannot be created
    *)
    function setup_find_stream_info_opts(s: PAVFormatContext;
      codec_opts: PAVDictionary): array of PAVDictionary;

    (* *
      * Print an error message to stderr, indicating filename and a human
      * readable description of the error code err.
      *
      * If strerror_r() is not available the use of this function in a
      * multithreaded application may be unsafe.
      *
      * @see av_strerror()
    *)
    procedure print_error(filename: pcchar; err: cint);

    (* *
      * Print the program banner to stderr. The banner contents depend on the
      * current version of the repository and of the libav* libraries used by
      * the program.
    *)
    procedure show_banner(argc: cint; argv: array of pcchar;
      options: POptionDef);

    (* *
      * Print the version of the program to stdout. The version message
      * depends on the current versions of the repository and of the libav*
      * libraries.
      * This option processing function does not utilize the arguments.
    *)
    function show_version(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print the license of the program to stdout. The license depends on
      * the license of the libraries compiled into the program.
      * This option processing function does not utilize the arguments.
    *)
    function show_license(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the formats supported by the
      * program.
      * This option processing function does not utilize the arguments.
    *)
    function show_formats(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the codecs supported by the
      * program.
      * This option processing function does not utilize the arguments.
    *)
    function show_codecs(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the decoders supported by the
      * program.
    *)
    function show_decoders(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the encoders supported by the
      * program.
    *)
    function show_encoders(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the filters supported by the
      * program.
      * This option processing function does not utilize the arguments.
    *)
    function show_filters(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the bit stream filters supported by the
      * program.
      * This option processing function does not utilize the arguments.
    *)
    function show_bsfs(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the protocols supported by the
      * program.
      * This option processing function does not utilize the arguments.
    *)
    function show_protocols(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the pixel formats supported by the
      * program.
      * This option processing function does not utilize the arguments.
    *)
    function show_pix_fmts(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the standard channel layouts supported by
      * the program.
      * This option processing function does not utilize the arguments.
    *)
    function show_layouts(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Print a listing containing all the sample formats supported by the
      * program.
    *)
    function show_sample_fmts(optctx: Pointer; opt: pcchar; arg: pcchar): cint;

    (* *
      * Return a positive value if a line read from standard input
      * starts with [yY], otherwise return 0.
    *)
    function read_yesno;

    (* *
      * Read the file with name filename, and put its content in a newly
      * allocated 0-terminated buffer.
      *
      * @param filename file to read from
      * @param bufptr location where pointer to buffer is returned
      * @param size   location where size of buffer is returned
      * @return 0 in case of success, a negative value corresponding to an
      * AVERROR error code in case of failure.
    *)
    function cmdutils_read_file(filename: pcchar; bufptr: array of pcchar;
      asize: pcuint);

    (* *
      * Get a file corresponding to a preset file.
      *
      * If is_path is non-zero, look for the file in the path preset_name.
      * Otherwise search for a file named arg.ffpreset in the directories
      * $FFMPEG_DATADIR (if set), $HOME/.ffmpeg, and in the datadir defined
      * at configuration time or in a "ffpresets" folder along the executable
      * on win32, in that order. If no such file is found and
      * codec_name is defined, then search for a file named
      * codec_name-preset_name.avpreset in the above-mentioned directories.
      *
      * @param filename buffer where the name of the found filename is written
      * @param filename_size size in bytes of the filename buffer
      * @param preset_name name of the preset to search
      * @param is_path tell if preset_name is a filename path
      * @param codec_name name of the codec for which to look for the
      * preset, may be NULL
    *)
    function get_preset_file(filename: pcchar; filename_size: cuint;
      preset_name: pcchar; is_path: cint; codec_name: pcchar): PFILE;

    (* *
      * Realloc array to hold new_size elements of elem_size.
      * Calls exit() on failure.
      *
      * @param array array to reallocate
      * @param elem_size size in bytes of each element
      * @param size new element count will be written here
      * @param new_size number of elements to place in reallocated array
      * @return reallocated array
    *)
    function grow_array(aarray: Pointer; elem_size: cint; size: pcint;
      new_size: cint): Pointer; overload;

    // # define grow_array(array , nb_elems)\
    // array = grow_array(array , sizeof (* array), &nb_elems, nb_elems + 1)
    function grow_array(aarray: Pointer; elem_size: cint);

  (* *
    * Get a frame from the pool. This is intended to be used as a callback for
    * AVCodecContext.get_buffer.
    *
    * @param s codec context. s->opaque must be a pointer to the head of the
    *          buffer pool.
    * @param frame frame->opaque will be set to point to the FrameBuffer
    *              containing the frame data.
  *)
    function codec_get_buffer(s: PAVCodecContext; frame: PAVFrame): cint;

    (* *
      * A callback to be used for AVCodecContext.release_buffer along with
      * codec_get_buffer().
    *)
    procedure codec_release_buffer(s: PAVCodecContext; frame: PAVFrame);

    (* *
      * A callback to be used for AVFilterBuffer.free.
      * @param fb buffer to free. fb->priv must be a pointer to the FrameBuffer
      *           containing the buffer data.
    *)
    procedure filter_release_buffer(fb: PAVFilterBuffer);

    (* *
      * Free all the buffers in the pool. This must be called after all the
      * buffers have been released.
    *)
    procedure free_buffer_pool(pool: PPFrameBuffer);

    {#define GET_PIX_FMT_NAME(pix_fmt)\
    const char *name = av_get_pix_fmt_name(pix_fmt);}
    function GET_PIX_FMT_NAME(pix_fmt:AVPixelFormat):pcchar;
    {#define GET_SAMPLE_FMT_NAME(sample_fmt)\
    const char *name = av_get_sample_fmt_name(sample_fmt)}
    function GET_SAMPLE_FMT_NAME( sample_fmt:AVSampleFormat):pcchar;
    {
    #define GET_SAMPLE_RATE_NAME(rate)\
    char name[16];\
    snprintf(name, sizeof(name), "%d", rate);}
    procedure GET_SAMPLE_RATE_NAME(rate:cint);

    {#define GET_CH_LAYOUT_NAME(ch_layout)\
    char name[16];\
    snprintf(name, sizeof(name), "0x%"PRIx64, ch_layout);}
    procedure GET_CH_LAYOUT_NAME(ch_layout:cint64);


    {#define GET_CH_LAYOUT_DESC(ch_layout)\
    char name[128];\
    av_get_channel_layout_string(name, sizeof(name), 0, ch_layout);}
    procedure GET_CH_LAYOUT_DESC(ch_layout:cint64);
  end;

implementation

end.
