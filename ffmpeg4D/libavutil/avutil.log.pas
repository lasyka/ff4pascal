//unit avutil.log;

//interface
//uses
 // ctypes,avutil.opt;

//type
//AVOptionRanges = class;external;

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

PAVClass=^AVClass;

PItemFunc=function(ctx:pointer):pcchar;
PChildNextFunc=function(obj:pointer;perv:pointer):pointer;
PChildClassNextFunc = function(prev:PAVClass):PAVClass;
PGetCategoryFunc=function(ctx:pointer):AVClassCategory;
PQueryRangesFunc=function(ranges:PPAVOptionRanges;obj:pointer;key:pcchar;flags:cint):cint;
PAvLogSetCallbackProc=procedure(p:pointer;b:cint;c:pcchar;va_list:pcchar);



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

     item_name:PItemFunc;


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
     child_next:PChildNextFunc;


    (**
     * Return an AVClass corresponding to the next potential
     * AVOptions-enabled child.
     *
     * The difference between child_next and this is that
     * child_next iterates over _already existing_ objects, while
     * child_class_next iterates over _all possible_ children.
     *)
     child_class_next:PChildClassNextFunc;

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
     get_category:PGetCategoryFunc;

    (**
     * Callback to return the supported/allowed ranges.
     * available since version (52.12)
     *)
     query_ranges:PQueryRangesFunc;
end;




//implementation

//end.
