unit avutil.log;

interface
uses
  ctypes;
const
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

type
AVOptionRanges = class;

AVClassCategory=(
    AV_CLASS_CATEGORY_NA = 0,
    AV_CLASS_CATEGORY_INPUT,
    AV_CLASS_CATEGORY_OUTPUT,
    AV_CLASS_CATEGORY_MUXER,
    AV_CLASS_CATEGORY_DEMUXER,
    AV_CLASS_CATEGORY_ENCODER,
    AV_CLASS_CATEGORY_DECODER,
    AV_CLASS_CATEGORY_FILTER,
    AV_CLASS_CATEGORY_BITSTREAM_FILTER,
    AV_CLASS_CATEGORY_SWSCALER,
    AV_CLASS_CATEGORY_SWRESAMPLER,
    AV_CLASS_CATEGORY_NB ///< not part of ABI/API
);



(**
 * Describe the class of an AVClass context structure. That is an
 * arbitrary struct of which the first field is a pointer to an
 * AVClass struct (e.g. AVCodecContext, AVFormatContext etc.).
 *)
 AVClass =record
    (**
     * The name of the class; usually it is the same name as the
     * context structure type to which the AVClass is associated.
     *)
     class_name:pcchar;

    (**
     * A pointer to a function which returns the name of a context
     * instance ctx associated with the class.
     *)
    const char* (*item_name)(void* ctx);

    (**
     * a pointer to the first option specified in the class if any or NULL
     *
     * @see av_set_default_options()
     *)
    option:PAVOption;

    (**
     * LIBAVUTIL_VERSION with which this structure was created.
     * This is used to allow fields to be added without requiring major
     * version bumps everywhere.
     *)

    version:cint;

    (**
     * Offset in the structure where log_level_offset is stored.
     * 0 means there is no such variable
     *)
     log_level_offset_offset:cint;

    (**
     * Offset in the structure where a pointer to the parent context for
     * logging is stored. For example a decoder could pass its AVCodecContext
     * to eval as such a parent context, which an av_log() implementation
     * could then leverage to display the parent context.
     * The offset can be NULL.
     *)
     parent_log_context_offset:cint;

    (**
     * Return next AVOptions-enabled child or NULL
     *)
    void* (*child_next)(void *obj, void *prev);

    (**
     * Return an AVClass corresponding to the next potential
     * AVOptions-enabled child.
     *
     * The difference between child_next and this is that
     * child_next iterates over _already existing_ objects, while
     * child_class_next iterates over _all possible_ children.
     *)
    const struct AVClass* (*child_class_next)(const struct AVClass *prev);

    (**
     * Category used for visualization (like color)
     * This is only set if the category is equal for all objects using this class.
     * available since version (51 << 16 | 56 << 8 | 100)
     *)
     category:AVClassCategory;

    (**
     * Callback to return the category.
     * available since version (51 << 16 | 59 << 8 | 100)
     *)
    AVClassCategory (*get_category)(void* ctx);

    (**
     * Callback to return the supported/allowed ranges.
     * available since version (52.12)
     *)
    int (*query_ranges)(struct AVOptionRanges **, void *obj, const char *key, int flags);
end;



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
void av_log(void *avcl, int level, const char *fmt, ...) av_printf_format(3, 4);

void av_vlog(void *avcl, int level, const char *fmt, va_list);
int av_log_get_level(void);
void av_log_set_level(int);
void av_log_set_callback(void (*)(void*, int, const char*, va_list));
void av_log_default_callback(void* ptr, int level, const char* fmt, va_list vl);
const char* av_default_item_name(void* ctx);
AVClassCategory av_default_get_category(void *ptr);

(**
 * Format a line of log the same way as the default callback.
 * @param line          buffer to receive the formated line
 * @param line_size     size of the buffer
 * @param print_prefix  used to store whether the prefix must be printed;
 *                      must point to a persistent integer initially set to 1
 *)
void av_log_format_line(void *ptr, int level, const char *fmt, va_list vl,
                        char *line, int line_size, int *print_prefix);

(**
 * av_dlog macros
 * Useful to print debug messages that shouldn't get compiled in normally.
 *)

{$IFDEF DEBUG }
//#    define av_dlog(pctx, ...) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__)
{$ELSE}
//#    define av_dlog(pctx, ...) do { if (0) av_log(pctx, AV_LOG_DEBUG, __VA_ARGS__); } while (0)
{$IFEND}


void av_log_set_flags(int arg);

implementation

end.
