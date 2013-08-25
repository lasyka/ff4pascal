unit dict;

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
(**
 * @addtogroup lavu_dict AVDictionary
 * @ingroup lavu_data
 *
 * @brief Simple key:value store
 *
 * @{
 * Dictionaries are used for storing key:value pairs. To create
 * an AVDictionary, simply pass an address of a NULL pointer to
 * av_dict_set(). NULL can be used as an empty dictionary wherever
 * a pointer to an AVDictionary is required.
 * Use av_dict_get() to retrieve an entry or iterate over all
 * entries and finally av_dict_free() to free the dictionary
 * and all its contents.
 *
 * @code
 * AVDictionary *d = NULL;                // "create" an empty dictionary
 * av_dict_set(&d, "foo", "bar", 0);      // add an entry
 *
 * char *k = av_strdup("key");            // if your strings are already allocated,
 * char *v = av_strdup("value");          // you can avoid copying them like this
 * av_dict_set(&d, k, v, AV_DICT_DONT_STRDUP_KEY | AV_DICT_DONT_STRDUP_VAL);
 *
 * AVDictionaryEntry *t = NULL;
 * while (t = av_dict_get(d, "", t, AV_DICT_IGNORE_SUFFIX)) {
 *     <....>                             // iterate over all entries in d
 * }
 *
 * av_dict_free(&d);
 * @endcode
 *
 *)
 const
 AV_DICT_MATCH_CASE  =    1;
 AV_DICT_IGNORE_SUFFIX =  2;
 AV_DICT_DONT_STRDUP_KEY= 4;   (**< Take ownership of a key that's been
                                         allocated with av_malloc() and children. *)
 AV_DICT_DONT_STRDUP_VAL= 8;   (**< Take ownership of a value that's been
                                         allocated with av_malloc() and chilren. *)
 AV_DICT_DONT_OVERWRITE =16;   ///< Don't overwrite existing entries.
 AV_DICT_APPEND         =32;   (**< If the entry already exists, append to it.  Note that no
                                      delimiter is added, the strings are simply concatenated. *)
type
PAVDictionaryEntry=^AVDictionaryEntry;
AVDictionaryEntry = record
    key:pcchar;
    value:pcchar;
end;

PPAVDictionary=^PAVDictionary;
PAVDictionary=^AVDictionary;
 AVDictionary= record
    count:cint;
    elems:PAVDictionaryEntry;
 end;

(**
 * Get a dictionary entry with matching key.
 *
 * @param prev Set to the previous matching element to find the next.
 *             If set to NULL the first matching element is returned.
 * @param flags Allows case as well as suffix-insensitive comparisons.
 * @return Found entry or NULL, changing key or value leads to undefined behavior.
 *)
function av_dict_get( m:PAVDictionary;  key:pcchar ;  prev:PAVDictionaryEntry;  flags:cint):PAVDictionaryEntry;cdecl;external av__util;

(**
 * Get number of entries in dictionary.
 *
 * @param m dictionary
 * @return  number of entries in dictionary
 *)
function av_dict_count(m:PAVDictionary ):cint;cdecl;external av__util;

(**
 * Set the given entry in *pm, overwriting an existing entry.
 *
 * @param pm pointer to a pointer to a dictionary struct. If *pm is NULL
 * a dictionary struct is allocated and put in *pm.
 * @param key entry key to add to *pm (will be av_strduped depending on flags)
 * @param value entry value to add to *pm (will be av_strduped depending on flags).
 *        Passing a NULL value will cause an existing entry to be deleted.
 * @return >= 0 on success otherwise an error code <0
 *)
function av_dict_set(pm:PPAVDictionary;  key:pcchar ;  value:pcchar ;  flags:cint):cint; cdecl;external av__util;

(**
 * Parse the key/value pairs list and add to a dictionary.
 *
 * @param key_val_sep  a 0-terminated list of characters used to separate
 *                     key from value
 * @param pairs_sep    a 0-terminated list of characters used to separate
 *                     two pairs from each other
 * @param flags        flags to use when adding to dictionary.
 *                     AV_DICT_DONT_STRDUP_KEY and AV_DICT_DONT_STRDUP_VAL
 *                     are ignored since the key/value tokens will always
 *                     be duplicated.
 * @return             0 on success, negative AVERROR code on failure
 *)
function av_dict_parse_string(pm:PPAVDictionary ; str:pcchar;
                          key_val_sep:pcchar; pairs_sep:pcchar;
                          flags:cint):cint;  cdecl;external av__util;

(**
 * Copy entries from one AVDictionary struct into another.
 * @param dst pointer to a pointer to a AVDictionary struct. If *dst is NULL,
 *            this function will allocate a struct for you and put it in *dst
 * @param src pointer to source AVDictionary struct
 * @param flags flags to use when setting entries in *dst
 * @note metadata is read using the AV_DICT_IGNORE_SUFFIX flag
 *)
procedure av_dict_copy( dst:PPAVDictionary;  src:PAVDictionary;  flags:cint); cdecl;external av__util;

(**
 * Free all the memory allocated for an AVDictionary struct
 * and all keys and values.
 *)
procedure av_dict_free(m:PPAVDictionary); cdecl;external av__util;

(**
 * @}
 *)

implementation

end.
