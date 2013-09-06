unit avutil.opt;

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
  ctypes, rational,dict,pixfmt,avutil.samplefmt,ffmpegconf;

(*
  * @defgroup avoptions AVOptions
  * @ingroup lavu_data
  * @{
  * AVOptions provide a generic system to declare options on arbitrary structs
  * ("objects"). An option can have a help text, a type and a range of possible
  * values. Options may then be enumerated, read and written to.
  *
  * @section avoptions_implement Implementing AVOptions
  * This section describes how to add AVOptions capabilities to a struct.
  *
  * All AVOptions-related information is stored in an AVClass. Therefore
  * the first member of the struct should be a pointer to an AVClass describing it.
  * The option field of the AVClass must be set to a NULL-terminated static array
  * of AVOptions. Each AVOption must have a non-empty name, a type, a default
  * value and for number-type AVOptions also a range of allowed values. It must
  * also declare an offset in bytes from the start of the struct, where the field
  * associated with this AVOption is located. Other fields in the AVOption struct
  * should also be set when applicable, but are not required.
  *
  * The following example illustrates an AVOptions-enabled struct:
  * @code
  * typedef struct test_struct {
  *     AVClass *class;
  *     int      int_opt;
  *     char    *str_opt;
  *     uint8_t *bin_opt;
  *     int      bin_len;
  * } test_struct;
  *
  * static const AVOption options[] = {
  *   { "test_int", "This is a test option of int type.", offsetof(test_struct, int_opt),
  *     AV_OPT_TYPE_INT, { .i64 = -1 }, INT_MIN, INT_MAX },
  *   { "test_str", "This is a test option of string type.", offsetof(test_struct, str_opt),
  *     AV_OPT_TYPE_STRING },
  *   { "test_bin", "This is a test option of binary type.", offsetof(test_struct, bin_opt),
  *     AV_OPT_TYPE_BINARY },
  *   { NULL },
  * };
  *
  * static const AVClass test_class = {
  *     .class_name = "test class",
  *     .item_name  = av_default_item_name,
  *     .option     = options,
  *     .version    = LIBAVUTIL_VERSION_INT,
  * };
  * @endcode
  *
  * Next, when allocating your struct, you must ensure that the AVClass pointer
  * is set to the correct value. Then, av_opt_set_defaults() can be called to
  * initialize defaults. After that the struct is ready to be used with the
  * AVOptions API.
  *
  * When cleaning up, you may use the av_opt_free() function to automatically
  * free all the allocated string and binary options.
  *
  * Continuing with the above example:
  *
  * @code
  * test_struct *alloc_test_struct(void)
  * {
  *     test_struct *ret = av_malloc(sizeof(*ret));
  *     ret->class = &test_class;
  *     av_opt_set_defaults(ret);
  *     return ret;
  * }
  * void free_test_struct(test_struct **foo)
  * {
  *     av_opt_free(*foo);
  *     av_freep(foo);
  * }
  * @endcode
  *
  * @subsection avoptions_implement_nesting Nesting
  *      It may happen that an AVOptions-enabled struct contains another
  *      AVOptions-enabled struct as a member (e.g. AVCodecContext in
  *      libavcodec exports generic options, while its priv_data field exports
  *      codec-specific options). In such a case, it is possible to set up the
  *      parent struct to export a child's options. To do that, simply
  *      implement AVClass.child_next() and AVClass.child_class_next() in the
  *      parent struct's AVClass.
  *      Assuming that the test_struct from above now also contains a
  *      child_struct field:
  *
  *      @code
  *      typedef struct child_struct {
  *          AVClass *class;
  *          flags:cint_opt;
  *      } child_struct;
  *      static const AVOption child_opts[] = {
  *          { "test_flags", "This is a test option of flags type.",
  *            offsetof(child_struct, flags_opt), AV_OPT_TYPE_FLAGS, { .i64 = 0 }, INT_MIN, INT_MAX },
  *          { NULL },
  *      };
  *      static const AVClass child_class = {
  *          .class_name = "child class",
  *          .item_name  = av_default_item_name,
  *          .option     = child_opts,
  *          .version    = LIBAVUTIL_VERSION_INT,
  *      };
  *
  *      void *child_next(void *obj, void *prev)
  *      {
  *          test_struct *t = obj;
  *          if (!prev && t->child_struct)
  *              return t->child_struct;
  *          return NULL
  *      }
  *      const AVClass child_class_next(const AVClass *prev)
  *      {
  *          return prev ? NULL : &child_class;
  *      }
  *      @endcode
  *      Putting child_next() and child_class_next() as defined above into
  *      test_class will now make child_struct's options accessible through
  *      test_struct (again, proper setup as described above needs to be done on
  *      child_struct right after it is created).
  *
  *      From the above example it might not be clear why both child_next()
  *      and child_class_next() are needed. The distinction is that child_next()
  *      iterates over actually existing objects, while child_class_next()
  *      iterates over all possible child classes. E.g. if an AVCodecContext
  *      was initialized to use a codec which has private options, then its
  *      child_next() will return AVCodecContext.priv_data and finish
  *      iterating. OTOH child_class_next() on AVCodecContext.av_class will
  *      iterate over all available codecs with private options.
  *
  * @subsection avoptions_implement_named_constants Named constants
  *      It is possible to create named constants for options. Simply set the unit
  *      field of the option the constants should apply to to a string and
  *      create the constants themselves as options of type AV_OPT_TYPE_CONST
  *      with their unit field set to the same string.
  *      Their default_val field should contain the value of the named
  *      constant.
  *      For example, to add some named constants for the test_flags option
  *      above, put the following into the child_opts array:
  *      @code
  *      { "test_flags", "This is a test option of flags type.",
  *        offsetof(child_struct, flags_opt), AV_OPT_TYPE_FLAGS, { .i64 = 0 }, INT_MIN, INT_MAX, "test_unit" },
  *      { "flag1", "This is a flag with value 16", 0, AV_OPT_TYPE_CONST, { .i64 = 16 }, 0, 0, "test_unit" },
  *      @endcode
  *
  * @section avoptions_use Using AVOptions
  * This section deals with accessing options in an AVOptions-enabled struct.
  * Such structs in FFmpeg are e.g. AVCodecContext in libavcodec or
  * AVFormatContext in libavformat.
  *
  * @subsection avoptions_use_examine Examining AVOptions
  * The basic functions for examining options are av_opt_next(), which iterates
  * over all options defined for one object, and av_opt_find(), which searches
  * for an option with the given name.
  *
  * The situation is more complicated with nesting. An AVOptions-enabled struct
  * may have AVOptions-enabled children. Passing the AV_OPT_SEARCH_CHILDREN flag
  * to av_opt_find() will make the function search children recursively.
  *
  * For enumerating there are basically two cases. The first is when you want to
  * get all options that may potentially exist on the struct and its children
  * (e.g.  when constructing documentation). In that case you should call
  * av_opt_child_class_next() recursively on the parent struct's AVClass.  The
  * second case is when you have an already initialized struct with all its
  * children and you want to get all options that can be actually written or read
  * from it. In that case you should call av_opt_child_next() recursively (and
  * av_opt_next() on each result).
  *
  * @subsection avoptions_use_get_set Reading and writing AVOptions
  * When setting options, you often have a string read directly from the
  * user. In such a case, simply passing it to av_opt_set() is enough. For
  * non-string type options, av_opt_set() will parse the string according to the
  * option type.
  *
  * Similarly av_opt_get() will read any option type and convert it to a string
  * which will be returned. Do not forget that the string is allocated, so you
  * have to free it with av_free().
  *
  * In some cases it may be more convenient to put all options into an
  * AVDictionary and call av_opt_set_dict() on it. A specific case of this
  * are the format/codec open functions in lavf/lavc which take a dictionary
  * filled with option as a parameter. This allows to set some options
  * that cannot be set otherwise, since e.g. the input file format is not known
  * before the file is actually opened.
*)

Const
  AV_OPT_FLAG_ENCODING_PARAM = 1;
  /// < a generic parameter which can be set by the user for muxing or encoding
  AV_OPT_FLAG_DECODING_PARAM = 2;
  /// < a generic parameter which can be set by the user for demuxing or decoding
  AV_OPT_FLAG_METADATA = 4;
  /// < some data extracted or inserted into the file like title, comment, ...
  AV_OPT_FLAG_AUDIO_PARAM = 8;
  AV_OPT_FLAG_VIDEO_PARAM = 16;
  AV_OPT_FLAG_SUBTITLE_PARAM = 32;
  AV_OPT_FLAG_FILTERING_PARAM = (1 shl 16);
  /// < a generic parameter which can be set by the user for filtering
  // FIXME think about enc-audio, ... style flags

  AV_OPT_SEARCH_CHILDREN = $0001; (* *< Search in possible children of the
    given object first. *)
  (* *
    *  The obj passed to av_opt_find() is fake -- only a double pointer to AVClass
    *  instead of a required pointer to a struct containing AVClass. This is
    *  useful for searching for options without needing to allocate the corresponding
    *  object.
  *)
  AV_OPT_SEARCH_FAKE_OBJ = $0002;

  (* *
    * Accept to parse a value without a key; the key will then be returned
    * as NULL.
  *)
  AV_OPT_FLAG_IMPLICIT_KEY = 1;


  //begin log.h
  (* av_log API *)

 AV_LOG_QUIET  =  -8;

(**
 * Something went really wrong and we will crash now.
 *)
 AV_LOG_PANIC   =  0;

(**
 * Something went wrong and recovery is not possible.
 * For example, no header was found for a format which depends
 * on headers or an illegal combination of parameters is used.
 *)
 AV_LOG_FATAL   =  8 ;

(**
 * Something went wrong and cannot losslessly be recovered.
 * However, not all future data is affected.
 *)
 AV_LOG_ERROR  =  16  ;

(**
 * Something somehow does not look correct. This may or may not
 * lead to problems. An example would be the use of '-vstrict -2'.
 *)
 AV_LOG_WARNING = 24  ;

 AV_LOG_INFO   =  32   ;
 AV_LOG_VERBOSE = 40    ;

(**
 * Stuff which is only useful for libav* developers.
 *)
 AV_LOG_DEBUG  =  48     ;

 AV_LOG_MAX_OFFSET =(AV_LOG_DEBUG - AV_LOG_QUIET) ;

  //end log.h

Type

  PPAVOptionRanges=^PAVOptionRanges;
  PAVOptionRanges=^AVOptionRanges;
    PAVOption = ^AVOption;

 {$I avutil.log.pas}

  AVOptionType = (AV_OPT_TYPE_FLAGS, AV_OPT_TYPE_INT, AV_OPT_TYPE_INT64,
    AV_OPT_TYPE_DOUBLE, AV_OPT_TYPE_FLOAT, AV_OPT_TYPE_STRING,
    AV_OPT_TYPE_RATIONAL, AV_OPT_TYPE_BINARY,
    /// < offset must point to a pointer immediately followed by an int for the length
    AV_OPT_TYPE_CONST = 128
    //AV_OPT_TYPE_IMAGE_SIZE = MKBETAG('S', 'I', 'Z', 'E'),
    /// < offset must point to two consecutive integers
   // AV_OPT_TYPE_PIXEL_FMT = MKBETAG('P', 'F', 'M', 'T'),
    //AV_OPT_TYPE_SAMPLE_FMT = MKBETAG('S', 'F', 'M', 'T')
{$IF FF_API_OLD_AVOPTIONS}
    , FF_OPT_TYPE_FLAGS = 0, FF_OPT_TYPE_INT, FF_OPT_TYPE_INT64,
    FF_OPT_TYPE_DOUBLE, FF_OPT_TYPE_FLOAT, FF_OPT_TYPE_STRING,
    FF_OPT_TYPE_RATIONAL, FF_OPT_TYPE_BINARY,
    /// < offset must point to a pointer immediately followed by an int for the length
    FF_OPT_TYPE_CONST = 128
{$IFEND}
    );


  DefaultVal = record
    case Integer of
      0:
        (i64: cint64;);
      1:
        (dbl: cdouble;);
      2:
        (str: pcchar;);
      (* TODO those are unused now *)
      3:
        (q: AVRational;);
  end;



  (* *
    * AVOption
  *)
  AVOption = record
    name: pcchar;

    (* *
      * short English help text
      * @todo What about other languages?
    *)
    help: pcchar;

    (* *
      * The offset relative to the context structure where the option
      * value is stored. It should be 0 for named constants.
    *)
    offset: cint;
    avtype: AVOptionType;

    (* *
      * the default value for scalar options
    *)
    default_val: DefaultVal;
    min: cdouble;
    /// < minimum valid value for the option
    max: cdouble;
    /// < maximum valid value for the option

    flags: cint;

    (* *
      * The logical unit to which the option belongs. Non-constant
      * options and corresponding named constants share the same
      * unit. May be NULL.
    *)
    cunit: pcchar; { unit }
  end;

  PPAVOptionRange = ^PAVOptionRange;
  PAVOptionRange = ^AVOptionRange;

  (* *
    * A single allowed range of values, or a single allowed value.
  *)
  AVOptionRange = record
    str: pcchar;
    value_min, value_max: cdouble;
    /// < For string ranges this represents the min/max length, for dimensions this represents the min/max pixel count
    component_min, component_max: cdouble;
    /// < For string this represents the unicode range for chars, 0-127 limits to ASCII
    is_range: cint;
    /// < if set to 1 the struct encodes a range, if set to 0 a single value
  end;

  (* *
    * List of AVOptionRange structs
  *)
  AVOptionRanges = record
    range: PPAVOptionRange;
    nb_ranges: cint;
  end;

{$IF FF_API_FIND_OPT }

  (* *
    * Look for an option in obj. Look only for the options which
    * have the flags set as specified in mask and flags (that is,
    * for which it is the case that opt->flags & mask == flags).
    *
    * @param[in] obj a pointer to a struct whose first element is a
    * pointer to an AVClass
    * @param[in] name the name of the option to look for
    * @param[in] unit the unit of the option to look for, or any if NULL
    * @return a pointer to the option found, or NULL if no option
    * has been found
    *
    * @deprecated use av_opt_find.
  *)
function av_find_opt(obj: pointer; name: pcchar; cunit: pcchar; mask: cint;
  flags: cint): PAVOption; deprecated;
{$IFEND}
{$IF FF_API_OLD_AVOPTIONS  }
(* *
  * Set the field of obj with the given name to value.
  *
  * @param[in] obj A struct whose first element is a pointer to an
  * AVClass.
  * @param[in] name the name of the field to set
  * @param[in] val The value to set. If the field is not of a string
  * type, then the given string is parsed.
  * SI postfixes and some named scalars are supported.
  * If the field is of a numeric type, it has to be a numeric or named
  * scalar. Behavior with more than one scalar and +- infix operators
  * is undefined.
  * If the field is of a flags type, it has to be a sequence of numeric
  * scalars or named flags separated by '+' or '-'. Prefixing a flag
  * with '+' causes it to be set without affecting the other flags;
  * similarly, '-' unsets a flag.
  * @param[out] o_out if non-NULL put here a pointer to the AVOption
  * found
  * @param alloc this parameter is currently ignored
  * @return 0 if the value has been set, or an AVERROR code in case of
  * error:
  * AVERROR_OPTION_NOT_FOUND if no matching option exists
  * AVERROR(ERANGE) if the value is out of range
  * AVERROR(EINVAL) if the value is not valid
  * @deprecated use av_opt_set()
*)
function av_set_string3(obj: pointer; name: pcchar; val: pcchar; alloc: cint;
  o_out: PPAVOption): cint; deprecated;

function av_set_double(obj: pointer; name: pcchar; n: cdouble): PAVOption;
  deprecated;
function av_set_q(obj: pointer; name: pcchar; n: AVRational): PAVOption;
  deprecated;
function av_set_int(obj: pointer; name: pcchar; n: cint64): PAVOption;
  deprecated;

function av_get_double(obj: pointer; name: pcchar; o_out: PPAVOption): cdouble;
function av_get_q(obj: pointer; name: pcchar; o_out: PPAVOption): AVRational;
function av_get_int(obj: pointer; name: pcchar; o_out: PPAVOption): cint64;
function av_get_string(obj: pointer; name: pcchar; o_out: PPAVOption;
  buf: pcchar; buf_len: cint): pcchar; deprecated;
function av_next_option(obj: pointer; last: PAVOption): PAVOption; deprecated;
{$IFEND}
(* *
  * Show the obj options.
  *
  * @param req_flags requested flags for the options to show. Show only the
  * options for which it is opt->flags & req_flags.
  * @param rej_flags rejected flags for the options to show. Show only the
  * options for which it is !(opt->flags & req_flags).
  * @param av_log_obj log context to use for showing the options
*)
function av_opt_show2(obj: pointer; av_log_obj: pointer; req_flags: cint;
  rej_flags: cint): cint;  cdecl;external av__util;

(* *
  * Set the values of all AVOption fields to their default values.
  *
  * @param s an AVOption-enabled struct (its first member must be a pointer to AVClass)
*)
procedure av_opt_set_defaults(s: pointer); cdecl;external av__util;

{$IF FF_API_OLD_AVOPTIONS }
procedure av_opt_set_defaults2(s: pointer; mask: cint; flags: cint); deprecated;  cdecl;external av__util;
{$IFEND}
(* *
  * Parse the key/value pairs list in opts. For each key/value pair
  * found, stores the value in the field in ctx that is named like the
  * key. ctx must be an AVClass context, storing is done using
  * AVOptions.
  *
  * @param opts options string to parse, may be NULL
  * @param key_val_sep a 0-terminated list of characters used to
  * separate key from value
  * @param pairs_sep a 0-terminated list of characters used to separate
  * two pairs from each other
  * @return the number of successfully set key/value pairs, or a negative
  * value corresponding to an AVERROR code in case of error:
  * AVERROR(EINVAL) if opts cannot be parsed,
  * the error code issued by av_set_string3() if a key/value pair
  * cannot be set
*)
function av_set_options_string(ctx: pointer; opts: pcchar; key_val_sep: pcchar;
  pairs_sep: pcchar): cint;  cdecl;external av__util;

(* *
  * Parse the key-value pairs list in opts. For each key=value pair found,
  * set the value of the corresponding option in ctx.
  *
  * @param ctx          the AVClass object to set options on
  * @param opts         the options string, key-value pairs separated by a
  *                     delimiter
  * @param shorthand    a NULL-terminated array of options names for shorthand
  *                     notation: if the first field in opts has no key part,
  *                     the key is taken from the first element of shorthand;
  *                     then again for the second, etc., until either opts is
  *                     finished, shorthand is finished or a named option is
  *                     found; after that, all options must be named
  * @param key_val_sep  a 0-terminated list of characters used to separate
  *                     key from value, for example '='
  * @param pairs_sep    a 0-terminated list of characters used to separate
  *                     two pairs from each other, for example ':' or ','
  * @return  the number of successfully set key=value pairs, or a negative
  *          value corresponding to an AVERROR code in case of error:
  *          AVERROR(EINVAL) if opts cannot be parsed,
  *          the error code issued by av_set_string3() if a key/value pair
  *          cannot be set
  *
  * Options names must use only the following characters: a-z A-Z 0-9 - . / _
  * Separators must use characters distinct from option names and from each
  * other.
*)
function av_opt_set_from_string(ctx: pointer; opts: pcchar;
  const shorthand: pcchar; key_val_sep: pcchar; pairs_sep: pcchar): cint;  cdecl;external av__util;
(* *
  * Free all string and binary options in obj.
*)
procedure av_opt_free(obj: pointer);  cdecl;external av__util;

(* *
  * Check whether a particular flag is set in a flags field.
  *
  * @param field_name the name of the flag field option
  * @param flag_name the name of the flag to check
  * @return non-zero if the flag is set, zero if the flag isn't set,
  *         isn't of the right type, or the flags field doesn't exist.
*)
function av_opt_flag_is_set(obj: pointer; field_name: pcchar;
  flag_name: pcchar): cint;   cdecl;external av__util;

(* *
  * Set all the options from a given dictionary on an object.
  *
  * @param obj a struct whose first element is a pointer to AVClass
  * @param options options to process. This dictionary will be freed and replaced
  *                by a new one containing all options not found in obj.
  *                Of course this new dictionary needs to be freed by caller
  *                with av_dict_free().
  *
  * @return 0 on success, a negative AVERROR if some option was found in obj,
  *         but could not be set.
  *
  * @see av_dict_copy()
*)
function av_opt_set_dict(obj: pointer; options: PPAVDictionary): cint;  cdecl;external av__util;

(* *
  * Extract a key-value pair from the beginning of a string.
  *
  * @param ropts        pointer to the options string, will be updated to
  *                     point to the rest of the string (one of the pairs_sep
  *                     or the final NUL)
  * @param key_val_sep  a 0-terminated list of characters used to separate
  *                     key from value, for example '='
  * @param pairs_sep    a 0-terminated list of characters used to separate
  *                     two pairs from each other, for example ':' or ','
  * @param flags        flags; see the AV_OPT_FLAG_* values below
  * @param rkey         parsed key; must be freed using av_free()
  * @param rval         parsed value; must be freed using av_free()
  *
  * @return  >=0 for success, or a negative value corresponding to an
  *          AVERROR code in case of error; in particular:
  *          AVERROR(EINVAL) if no key is present
  *
*)
function av_opt_get_key_value(ropts: ppcchar; key_val_sep: pcchar;
  pairs_sep: pcchar; flags: cuint; rkey: array of pcchar;
  rval: array of pcchar): cint;  cdecl;external av__util;

(* *
  * @defgroup opt_eval_funcs Evaluating option strings
  * @{
  * This group of functions can be used to evaluate option strings
  * and get numbers out of them. They do the same thing as av_opt_set(),
  * except the result is written into the caller-supplied pointer.
  *
  * @param obj a struct whose first element is a pointer to AVClass.
  * @param o an option for which the string is to be evaluated.
  * @param val string to be evaluated.
  * @param *_out value of the string will be written here.
  *
  * @return 0 on success, a negative number on failure.
*)
function av_opt_eval_flags(obj: pointer; o: PAVOption; val: pcchar;
  flags_out: pcint): cint;  cdecl;external av__util;
function av_opt_eval_int(obj: pointer; o: PAVOption; val: pcchar;
  int_out: pcint): cint;    cdecl;external av__util;
function av_opt_eval_int64(obj: pointer; o: PAVOption; val: pcchar;
  int64_out: pcint64): cint;  cdecl;external av__util;
function av_opt_eval_float(obj: pointer; o: PAVOption; val: pcchar;
  float_out: pcfloat): cint;  cdecl;external av__util;
function av_opt_eval_double(obj: pointer; o: PAVOption; val: pcchar;
  double_out: pcdouble): cint;  cdecl;external av__util;
function av_opt_eval_q(obj: pointer; o: PAVOption; val: pcchar;
  q_out: PAVRational): cint;  cdecl;external av__util;
(* *
  * @}
*)

(* *
  * Look for an option in an object. Consider only options which
  * have all the specified flags set.
  *
  * @param[in] obj A pointer to a struct whose first element is a
  *                pointer to an AVClass.
  *                Alternatively a double pointer to an AVClass, if
  *                AV_OPT_SEARCH_FAKE_OBJ search flag is set.
  * @param[in] name The name of the option to look for.
  * @param[in] unit When searching for named constants, name of the unit
  *                 it belongs to.
  * @param opt_flags Find only options with all the specified flags set (AV_OPT_FLAG).
  * @param search_flags A combination of AV_OPT_SEARCH_*.
  *
  * @return A pointer to the option found, or NULL if no option
  *         was found.
  *
  * @note Options found with AV_OPT_SEARCH_CHILDREN flag may not be settable
  * directly with av_set_string3(). Use special calls which take an options
  * AVDictionary (e.g. avformat_open_input()) to set options found with this
  * flag.
*)
function av_opt_find(obj: pointer; name: pcchar; cunit: pcchar; opt_flags: cint;
  search_flags: cint): PAVOption;  cdecl;external av__util;

(* *
  * Look for an option in an object. Consider only options which
  * have all the specified flags set.
  *
  * @param[in] obj A pointer to a struct whose first element is a
  *                pointer to an AVClass.
  *                Alternatively a double pointer to an AVClass, if
  *                AV_OPT_SEARCH_FAKE_OBJ search flag is set.
  * @param[in] name The name of the option to look for.
  * @param[in] unit When searching for named constants, name of the unit
  *                 it belongs to.
  * @param opt_flags Find only options with all the specified flags set (AV_OPT_FLAG).
  * @param search_flags A combination of AV_OPT_SEARCH_*.
  * @param[out] target_obj if non-NULL, an object to which the option belongs will be
  * written here. It may be different from obj if AV_OPT_SEARCH_CHILDREN is present
  * in search_flags. This parameter is ignored if search_flags contain
  * AV_OPT_SEARCH_FAKE_OBJ.
  *
  * @return A pointer to the option found, or NULL if no option
  *         was found.
*)
function av_opt_find2(obj: pointer; name: pcchar; cunit: pcchar;
  opt_flags: cint; search_flags: cint; target_obj: array of pointer): PAVOption; cdecl;external av__util;

(* *
  * Iterate over all AVOptions belonging to obj.
  *
  * @param obj an AVOptions-enabled struct or a double pointer to an
  *            AVClass describing it.
  * @param prev result of the previous call to av_opt_next() on this object
  *             or NULL
  * @return next AVOption or NULL
*)
function av_opt_next(obj: pointer; prev: PAVOption): PAVOption; cdecl;external av__util;

(* *
  * Iterate over AVOptions-enabled children of obj.
  *
  * @param prev result of a previous call to this function or NULL
  * @return next AVOptions-enabled child or NULL
*)
function av_opt_child_next(obj: pointer; prev: pointer): pointer; cdecl;external av__util;

(* *
  * Iterate over potential AVOptions-enabled children of parent.
  *
  * @param prev result of a previous call to this function or NULL
  * @return AVClass corresponding to next potential child or NULL
*)
function av_opt_child_class_next(parent: PAVClass; prev: PAVClass): PAVClass; cdecl;external av__util;

(* *
  * @defgroup opt_set_funcs Option setting functions
  * @{
  * Those functions set the field of obj with the given name to value.
  *
  * @param[in] obj A struct whose first element is a pointer to an AVClass.
  * @param[in] name the name of the field to set
  * @param[in] val The value to set. In case of av_opt_set() if the field is not
  * of a string type, then the given string is parsed.
  * SI postfixes and some named scalars are supported.
  * If the field is of a numeric type, it has to be a numeric or named
  * scalar. Behavior with more than one scalar and +- infix operators
  * is undefined.
  * If the field is of a flags type, it has to be a sequence of numeric
  * scalars or named flags separated by '+' or '-'. Prefixing a flag
  * with '+' causes it to be set without affecting the other flags;
  * similarly, '-' unsets a flag.
  * @param search_flags flags passed to av_opt_find2. I.e. if AV_OPT_SEARCH_CHILDREN
  * is passed here, then the option may be set on a child of obj.
  *
  * @return 0 if the value has been set, or an AVERROR code in case of
  * error:
  * AVERROR_OPTION_NOT_FOUND if no matching option exists
  * AVERROR(ERANGE) if the value is out of range
  * AVERROR(EINVAL) if the value is not valid
*)
function av_opt_set(obj: pointer; name: pcchar; val: pcchar;
  search_flags: cint): cint; cdecl;external av__util;
function av_opt_set_int(obj: pointer; name: pcchar; val: cint64;
  search_flags: cint): cint; cdecl;external av__util;
function av_opt_set_double(obj: pointer; name: pcchar; val: cdouble;
  search_flags: cint): cint; cdecl;external av__util;
function av_opt_set_q(obj: pointer; name: pcchar; val: AVRational;
  search_flags: cint): cint;  cdecl;external av__util;
function av_opt_set_bin(obj: pointer; name: pcchar; val: pcuint8; size: cint;
  search_flags: cint): cint;  cdecl;external av__util;
function av_opt_set_image_size(obj: pointer; name: pcchar; w: cint; h: cint;
  search_flags: cint): cint;  cdecl;external av__util;
function av_opt_set_pixel_fmt(obj: pointer; name: pcchar; fmt: AVPixelFormat;
  search_flags: cint): cint;  cdecl;external av__util;
function av_opt_set_sample_fmt(obj: pointer; name: pcchar; fmt: AVSampleFormat;
  search_flags: cint): cint; cdecl;external av__util;
(* *
  * @}
*)

(* *
  * @defgroup opt_get_funcs Option getting functions
  * @{
  * Those functions get a value of the option with the given name from an object.
  *
  * @param[in] obj a struct whose first element is a pointer to an AVClass.
  * @param[in] name name of the option to get.
  * @param[in] search_flags flags passed to av_opt_find2. I.e. if AV_OPT_SEARCH_CHILDREN
  * is passed here, then the option may be found in a child of obj.
  * @param[out] out_val value of the option will be written here
  * @return 0 on success, a negative error code otherwise
*)
(* *
  * @note the returned string will av_malloc()ed and must be av_free()ed by the caller
*)
function av_opt_get(obj: pointer; name: pcchar; search_flags: cint;
  out_val: array of pcuint8): cint;  cdecl;external av__util;
function av_opt_get_int(obj: pointer; name: pcchar; search_flags: cint;
  out_val: pcint64): cint;  cdecl;external av__util;
function av_opt_get_double(obj: pointer; name: pcchar; search_flags: cint;
  out_val: pcdouble): cint;  cdecl;external av__util;
function av_opt_get_q(obj: pointer; name: pcchar; search_flags: cint;
  out_val: PAVRational): cint;  cdecl;external av__util;
function av_opt_get_image_size(obj: pointer; name: pcchar; search_flags: cint;
  w_out: pcint; h_out: pcint): cint;  cdecl;external av__util;
function av_opt_get_pixel_fmt(obj: pointer; name: pcchar; search_flags: cint;
  out_fmt: PAVPixelFormat): cint;   cdecl;external av__util;
function av_opt_get_sample_fmt(obj: pointer; name: pcchar; search_flags: cint;
  out_fmt: PAVSampleFormat): cint;  cdecl;external av__util;
(* *
  * @}
*)
(* *
  * Gets a pointer to the requested field in a struct.
  * This function allows accessing a struct even when its fields are moved or
  * renamed since the application making the access has been compiled,
  *
  * @returns a pointer to the field, it can be cast to the correct type and read
  *          or written to.
*)
function av_opt_ptr(avclass: PAVClass; obj: pointer; name: pcchar): pointer; cdecl;external av__util;

(* *
  * Free an AVOptionRanges struct and set it to NULL.
*)
procedure av_opt_freep_ranges(ranges: array of PAVOptionRanges); cdecl;external av__util;

(* *
  * Get a list of allowed ranges for the given option.
  *
  * The returned list may depend on other fields in obj like for example profile.
  *
  * @param flags is a bitmask of flags, undefined flags should not be set and should be ignored
  *              AV_OPT_SEARCH_FAKE_OBJ indicates that the obj is a double pointer to a AVClass instead of a full instance
  *
  * The result must be freed with av_opt_freep_ranges.
  *
  * @return >= 0 on success, a negative errro code otherwise
*)
function av_opt_query_ranges(ranges: array of PAVOptionRanges; obj: pointer;
  key: pcchar; flags: cint): cint;  cdecl;external av__util;

(* *
  * Get a default list of allowed ranges for the given option.
  *
  * This list is constructed without using the AVClass.query_ranges() callback
  * and can be used as fallback from within the callback.
  *
  * @param flags is a bitmask of flags, undefined flags should not be set and should be ignored
  *              AV_OPT_SEARCH_FAKE_OBJ indicates that the obj is a double pointer to a AVClass instead of a full instance
  *
  * The result must be freed with av_opt_free_ranges.
  *
  * @return >= 0 on success, a negative errro code otherwise
*)
function av_opt_query_ranges_default(ranges: array of PAVOptionRanges; obj: pointer;
  key: pcchar; flags: cint): cint;  cdecl;external av__util;

(* *
  * @}
*)


//begin log.h
(**
 * Send the specified message to the log if the level is less than or equal
 * to the current av_log_level. By default, all logging messages are sent to
 * stderr. This behavior can be altered by setting a different av_vlog callback
 * function.
 *
 * @param avcl A pointer to an arbitrary struct of which the first field is a
 * pointer to an AVClass struct.
 * @param level The importance level of the message, lower values signifying
 * higher importance.
 * @param fmt The format string (printf-compatible) that specifies how
 * subsequent arguments are converted to output.
 * @see av_vlog
 *)
procedure av_log(avcl:pointer; level:cint; fmt:array of pcchar); cdecl;external av__util;   // av_printf_format(3, 4);

procedure av_vlog(avcl:pointer; level:cint; fmt:pcchar; va_list:pcchar);  cdecl;external av__util;
function av_log_get_level():cint;  cdecl;external av__util;
procedure av_log_set_level(a:cint);  cdecl;external av__util;

procedure av_log_set_callback(arg:PAvLogSetCallbackProc);  cdecl;external av__util;
procedure av_log_default_callback(ptr:pointer; level:cint; fmt:pcchar;  va_list:pcchar);   cdecl;external av__util;
function av_default_item_name(ctx:pointer):pcchar;  cdecl;external av__util;
function av_default_get_category(ptr:pointer):AVClassCategory;   cdecl;external av__util;

(**
 * Format a line of log the same way as the default callback.
 * @param line          buffer to receive the formated line
 * @param line_size     size of the buffer
 * @param print_prefix  used to store whether the prefix must be printed;
 *                      must point to a persistent integer initially set to 1
 *)
procedure av_log_format_line(ptr:pointer; level:cint; fmt:pcchar; va_list:pcchar;
                        line:pcchar; line_size:cint; print_prefix:pcint);  cdecl;external av__util;

(**
 * av_dlog macros
 * Useful to print debug messages that shouldn't get compiled in normally.
 *)

{$IFDEF DEBUG }
//#    define av_dlog(pctx, ...) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__)
{$ELSE}
//#    define av_dlog(pctx, ...) do { if (0) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__); } while (0)
{$IFEND}


procedure av_log_set_flags( arg:cint); cdecl;external av__util;

//end log.h
implementation

end.
