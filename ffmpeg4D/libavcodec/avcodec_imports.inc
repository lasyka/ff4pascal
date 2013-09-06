(* *
    * If c is NULL, returns the first registered codec,
    * if c is non-NULL, returns the next registered codec after c,
    * or NULL if c is the last one.
  *)
  function av_codec_next(c: PAVCodec): PAVCodec; cdecl; external av__codec;

  (* *
    * Return the LIBAVCODEC_VERSION_INT constant.
  *)
  function avcodec_version(): cuint; cdecl; external av__codec;

  (* *
    * Return the libavcodec build-time configuration.
  *)
  function avcodec_configuration(): pcchar;cdecl; external av__codec;

  (* *
    * Return the libavcodec license.
  *)
  function avcodec_license(): pcchar;cdecl; external av__codec;

  (* *
    * Register the codec codec and initialize libavcodec.
    *
    * @warning either this function or avcodec_register_all() must be called
    * before any other libavcodec functions.
    *
    * @see avcodec_register_all()
  *)
  procedure avcodec_register(codec: PAVCodec); cdecl; external av__codec;

  (* *
    * Register all the codecs, parsers and bitstream filters which were enabled at
    * configuration time. If you do not call this function you can select exactly
    * which formats you want to support, by using the individual registration
    * functions.
    *
    * @see avcodec_register
    * @see av_register_codec_parser
    * @see av_register_bitstream_filter
  *)
  procedure avcodec_register_all(); cdecl; external av__codec;

{$IF FF_API_ALLOC_CONTEXT}
  (* *
    * Allocate an AVCodecContext and set its fields to default values.  The
    * resulting struct can be deallocated by simply calling av_free().
    *
    * @return An AVCodecContext filled with default values or NULL on failure.
    * @see avcodec_get_context_defaults
    *
    * @deprecated use avcodec_alloc_context3()
  *)
  function avcodec_alloc_context(): PAVCodecContext; deprecated;cdecl; external av__codec;

  (* * THIS FUNCTION IS NOT YET PART OF THE PUBLIC API!
    *  we WILL change its arguments and name a few times! *)
  function avcodec_alloc_context2(enum AVMediaType): PAVCodecContext;
  deprecated;

  (* *
    * Set the fields of the given AVCodecContext to default values.
    *
    * @param s The AVCodecContext of which the fields should be set to default values.
    * @deprecated use avcodec_get_context_defaults3
  *)
  procedure avcodec_get_context_defaults(s: PAVCodecContext); deprecated;cdecl; external av__codec;

  (* * THIS FUNCTION IS NOT YET PART OF THE PUBLIC API!
    *  we WILL change its arguments and name a few times! *)
  procedure avcodec_get_context_defaults2(s: PAVCodecContext;
  avtype: AVMediaType); deprecated; cdecl; external av__codec;
{$IFEND}
  (* *
    * Allocate an AVCodecContext and set its fields to default values.  The
    * resulting struct can be deallocated by calling avcodec_close() on it followed
    * by av_free().
    *
    * @param codec if non-NULL, allocate private data and initialize defaults
    *              for the given codec. It is illegal to then call avcodec_open2()
    *              with a different codec.
    *              If NULL, then the codec-specific defaults won't be initialized,
    *              which may result in suboptimal default settings (this is
    *              important mainly for encoders, e.g. libx264).
    *
    * @return An AVCodecContext filled with default values or NULL on failure.
    * @see avcodec_get_context_defaults
  *)
  function avcodec_alloc_context3(codec: PAVCodec): PAVCodecContext;cdecl; external av__codec;

  (* *
    * Set the fields of the given AVCodecContext to default values corresponding
    * to the given codec (defaults may be codec-dependent).
    *
    * Do not call this function if a non-NULL codec has been passed
    * to avcodec_alloc_context3() that allocated this AVCodecContext.
    * If codec is non-NULL, it is illegal to call avcodec_open2() with a
    * different codec on this AVCodecContext.
  *)
  function avcodec_get_context_defaults3(s: PAVCodecContext;
  codec: PAVCodec): cint; cdecl; external av__codec;

  (* *
    * Get the AVClass for AVCodecContext. It can be used in combination with
    * AV_OPT_SEARCH_FAKE_OBJ for examining options.
    *
    * @see av_opt_find().
  *)
  function avcodec_get_class(): { const } PAVClass;cdecl; external av__codec;

  (* *
    * Get the AVClass for AVFrame. It can be used in combination with
    * AV_OPT_SEARCH_FAKE_OBJ for examining options.
    *
    * @see av_opt_find().
  *)
  function avcodec_get_frame_class(): PAVClass;cdecl; external av__codec;

  (* *
    * Get the AVClass for AVSubtitleRect. It can be used in combination with
    * AV_OPT_SEARCH_FAKE_OBJ for examining options.
    *
    * @see av_opt_find().
  *)
  function avcodec_get_subtitle_rect_class(): PAVClass;cdecl; external av__codec;

  (* *
    * Copy the settings of the source AVCodecContext into the destination
    * AVCodecContext. The resulting destination codec context will be
    * unopened, i.e. you are required to call avcodec_open2() before you
    * can use this AVCodecContext to decode/encode video/audio data.
    *
    * @param dest target codec context, should be initialized with
    *             avcodec_alloc_context3(), but otherwise uninitialized
    * @param src source codec context
    * @return AVERROR() on error (e.g. memory allocation error), 0 on success
  *)
  function avcodec_copy_context(dest: PAVCodecContext;
  src: PAVCodecContext): cint; cdecl; external av__codec;

  (* *
    * Allocate an AVFrame and set its fields to default values.  The resulting
    * struct must be freed using avcodec_free_frame().
    *
    * @return An AVFrame filled with default values or NULL on failure.
    * @see avcodec_get_frame_defaults
  *)
  function avcodec_alloc_frame: PAVFrame;cdecl; external av__codec;

  (* *
    * Set the fields of the given AVFrame to default values.
    *
    * @param frame The AVFrame of which the fields should be set to default values.
  *)
  procedure avcodec_get_frame_defaults(frame: PAVFrame);cdecl; external av__codec;

  (* *
    * Free the frame and any dynamically allocated objects in it,
    * e.g. extended_data.
    *
    * @param frame frame to be freed. The pointer will be set to NULL.
    *
    * @warning this function does NOT free the data buffers themselves
    * (it does not know how, since they might have been allocated with
    *  a custom get_buffer()).
  *)
  procedure avcodec_free_frame(frame: array of PAVFrame);cdecl; external av__codec;

  {$IF FF_API_AVCODEC_OPEN}
  (* *
    * Initialize the AVCodecContext to use the given AVCodec. Prior to using this
    * function the context has to be allocated.
    *
    * The functions avcodec_find_decoder_by_name(), avcodec_find_encoder_by_name(),
    * avcodec_find_decoder() and avcodec_find_encoder() provide an easy way for
    * retrieving a codec.
    *
    * @warning This function is not thread safe!
    *
    * @code
    * avcodec_register_all();
    * codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    * if (!codec)
    *     exit(1);
    *
    * context = avcodec_alloc_context3(codec);
    *
    * if (avcodec_open(context, codec) < 0)
    *     exit(1);
    * @endcode
    *
    * @param avctx The context which will be set up to use the given codec.
    * @param codec The codec to use within the context.
    * @return zero on success, a negative value on error
    * @see avcodec_alloc_context3, avcodec_find_decoder, avcodec_find_encoder, avcodec_close
    *
    * @deprecated use avcodec_open2
  *)
  function avcodec_open(AVCodecContext * avctx, avcodec * codec): cint;
  deprecated; cdecl; external av__codec;
{$IFEND}
  (* *
    * Initialize the AVCodecContext to use the given AVCodec. Prior to using this
    * function the context has to be allocated with avcodec_alloc_context3().
    *
    * The functions avcodec_find_decoder_by_name(), avcodec_find_encoder_by_name(),
    * avcodec_find_decoder() and avcodec_find_encoder() provide an easy way for
    * retrieving a codec.
    *
    * @warning This function is not thread safe!
    *
    * @code
    * avcodec_register_all();
    * av_dict_set(&opts, "b", "2.5M", 0);
    * codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    * if (!codec)
    *     exit(1);
    *
    * context = avcodec_alloc_context3(codec);
    *
    * if (avcodec_open2(context, codec, opts) < 0)
    *     exit(1);
    * @endcode
    *
    * @param avctx The context to initialize.
    * @param codec The codec to open this context for. If a non-NULL codec has been
    *              previously passed to avcodec_alloc_context3() or
    *              avcodec_get_context_defaults3() for this context, then this
    *              parameter MUST be either NULL or equal to the previously passed
    *              codec.
    * @param options A dictionary filled with AVCodecContext and codec-private options.
    *                On return this object will be filled with options that were not found.
    *
    * @return zero on success, a negative value on error
    * @see avcodec_alloc_context3(), avcodec_find_decoder(), avcodec_find_encoder(),
    *      av_dict_set(), av_opt_find().
  *)
  function avcodec_open2(avctx: PAVCodecContext; codec: PAVCodec;
  options: PPAVDictionary): cint; cdecl; external av__codec;

  (* *
    * Close a given AVCodecContext and free all the data associated with it
    * (but not the AVCodecContext itself).
    *
    * Calling this function on an AVCodecContext that hasn't been opened will free
    * the codec-specific data allocated in avcodec_alloc_context3() /
    * avcodec_get_context_defaults3() with a non-NULL codec. Subsequent calls will
    * do nothing.
  *)
  function avcodec_close(avctx: PAVCodecContext): cint; cdecl; external av__codec;

  (* *
    * Free all allocated data in the given subtitle struct.
    *
    * @param sub AVSubtitle to free.
  *)
  procedure avsubtitle_free(sub: PAVSubtitle); cdecl; external av__codec;

  (* *
    * @}
  *)

  (* *
    * @addtogroup lavc_packet
    * @{
  *)

  (* *
    * Default packet destructor.
  *)
  procedure av_destruct_packet(pkt: PAVPacket); cdecl; external av__codec;

  (* *
    * Initialize optional fields of a packet with default values.
    *
    * Note, this does not touch the data and size members, which have to be
    * initialized separately.
    *
    * @param pkt packet
  *)
  procedure av_init_packet(pkt: PAVPacket); cdecl; external av__codec;

  (* *
    * Allocate the payload of a packet and initialize its fields with
    * default values.
    *
    * @param pkt packet
    * @param size wanted payload size
    * @return 0 if OK, AVERROR_xxx otherwise
  *)
  function av_new_packet(pkt: PAVPacket; size: cint): cint; cdecl; external av__codec;

  (* *
    * Reduce packet size, correctly zeroing padding
    *
    * @param pkt packet
    * @param size new size
  *)
  procedure av_shrink_packet(pkt: PAVPacket; size: cint); cdecl; external av__codec;

  (* *
    * Increase packet size, correctly zeroing padding
    *
    * @param pkt packet
    * @param grow_by number of bytes by which to increase the size of the packet
  *)
  function av_grow_packet(pkt: PAVPacket; grow_by: cint): cint; cdecl; external av__codec;

  (* *
    * @warning This is a hack - the packet memory allocation stuff is broken. The
    * packet is allocated if it was not really allocated.
  *)
  function av_dup_packet(pkt: PAVPacket): cint; cdecl; external av__codec;

  (* *
    * Copy packet, including contents
    *
    * @return 0 on success, negative AVERROR on fail
  *)
  function av_copy_packet(pkt: PAVPacket; src: PAVPacket): cint;cdecl; external av__codec;

  (* *
    * Free a packet.
    *
    * @param pkt packet to free
  *)
  procedure av_free_packet(pkt: PAVPacket); cdecl; external av__codec;

  (* *
    * Allocate new information of a packet.
    *
    * @param pkt packet
    * @param type side information type
    * @param size side information size
    * @return pointer to fresh allocated data or NULL otherwise
  *)
  function av_packet_new_side_data(pkt: PAVPacket; atype: AVPacketSideDataType;
  size: cint): pcuint8; cdecl; external av__codec;

  (* *
    * Shrink the already allocated side data buffer
    *
    * @param pkt packet
    * @param type side information type
    * @param size new side information size
    * @return 0 on success, < 0 on failure
  *)
  function av_packet_shrink_side_data(pkt: PAVPacket;
  atype: AVPacketSideDataType; size: cint): cint; cdecl; external av__codec;

  (* *
    * Get side information from packet.
    *
    * @param pkt packet
    * @param type desired side information type
    * @param size pointer for side information size to store (optional)
    * @return pointer to data if present or NULL otherwise
  *)
  function av_packet_get_side_data(pkt: PAVPacket; atype: AVPacketSideDataType;
  size: pcint): pcuint8; cdecl; external av__codec;

  function av_packet_merge_side_data(pkt: PAVPacket): cint; cdecl; external av__codec;

  function av_packet_split_side_data(pkt: PAVPacket): cint; cdecl; external av__codec;

  (* *
    * @}
  *)

  (* *
    * @addtogroup lavc_decoding
    * @{
  *)

  (* *
    * Find a registered decoder with a matching codec ID.
    *
    * @param id AVCodecID of the requested decoder
    * @return A decoder if one was found, NULL otherwise.
  *)
  function avcodec_find_decoder(id: AVCodecID): PAVCodec;cdecl; external av__codec;

  (* *
    * Find a registered decoder with the specified name.
    *
    * @param name name of the requested decoder
    * @return A decoder if one was found, NULL otherwise.
  *)
  function avcodec_find_decoder_by_name(name: pcchar): PAVCodec; cdecl; external av__codec;

  function avcodec_default_get_buffer(s: PAVCodecContext; pic: PAVFrame): cint;cdecl; external av__codec;
  procedure avcodec_default_release_buffer(s: PAVCodecContext; pic: PAVFrame);cdecl; external av__codec;
  function avcodec_default_reget_buffer(s: PAVCodecContext;
  pic: PAVFrame): cint; cdecl; external av__codec;

  (* *
    * Return the amount of padding in pixels which the get_buffer callback must
    * provide around the edge of the image for codecs which do not have the
    * CODEC_FLAG_EMU_EDGE flag.
    *
    * @return Required padding in pixels.
  *)
  function avcodec_get_edge_width(): cuint;cdecl; external av__codec;

  (* *
    * Modify width and height values so that they will result in a memory
    * buffer that is acceptable for the codec if you do not use any horizontal
    * padding.
    *
    * May only be used if a codec with CODEC_CAP_DR1 has been opened.
    * If CODEC_FLAG_EMU_EDGE is not set, the dimensions must have been increased
    * according to avcodec_get_edge_width() before.
  *)
  procedure avcodec_align_dimensions(s: PAVCodecContext; width: pcint;
  height: pcint); cdecl; external av__codec;

  (* *
    * Modify width and height values so that they will result in a memory
    * buffer that is acceptable for the codec if you also ensure that all
    * line sizes are a multiple of the respective linesize_align[i].
    *
    * May only be used if a codec with CODEC_CAP_DR1 has been opened.
    * If CODEC_FLAG_EMU_EDGE is not set, the dimensions must have been increased
    * according to avcodec_get_edge_width() before.
  *)
  procedure avcodec_align_dimensions2(s: PAVCodecContext; width: pcint;
  height: pcint; linesize_align: array {[0 .. AV_NUM_DATA_POINTERS - 1]} of cint); cdecl; external av__codec;

{$IF FF_API_OLD_DECODE_AUDIO}
  (* *
    * Wrapper function which calls avcodec_decode_audio4.
    *
    * @deprecated Use avcodec_decode_audio4 instead.
    *
    * Decode the audio frame of size avpkt->size from avpkt->data into samples.
    * Some decoders may support multiple frames in a single AVPacket, such
    * decoders would then just decode the first frame. In this case,
    * avcodec_decode_audio3 has to be called again with an AVPacket that contains
    * the remaining data in order to decode the second frame etc.
    * If no frame
    * could be outputted, frame_size_ptr is zero. Otherwise, it is the
    * decompressed frame size in bytes.
    *
    * @warning You must set frame_size_ptr to the allocated size of the
    * output buffer before calling avcodec_decode_audio3().
    *
    * @warning The input buffer must be FF_INPUT_BUFFER_PADDING_SIZE larger than
    * the actual read bytes because some optimized bitstream readers read 32 or 64
    * bits at once and could read over the end.
    *
    * @warning The end of the input buffer avpkt->data should be set to 0 to ensure that
    * no overreading happens for damaged MPEG streams.
    *
    * @warning You must not provide a custom get_buffer() when using
    * avcodec_decode_audio3().  Doing so will override it with
    * avcodec_default_get_buffer.  Use avcodec_decode_audio4() instead,
    * which does allow the application to provide a custom get_buffer().
    *
    * @note You might have to align the input buffer avpkt->data and output buffer
    * samples. The alignment requirements depend on the CPU: On some CPUs it isn't
    * necessary at all, on others it won't work at all if not aligned and on others
    * it will work but it will have an impact on performance.
    *
    * In practice, avpkt->data should have 4 byte alignment at minimum and
    * samples should be 16 byte aligned unless the CPU doesn't need it
    * (AltiVec and SSE do).
    *
    * @note Codecs which have the CODEC_CAP_DELAY capability set have a delay
    * between input and output, these need to be fed with avpkt->data=NULL,
    * avpkt->size=0 at the end to return the remaining frames.
    *
    * @param avctx the codec context
    * @param[out] samples the output buffer, sample type in avctx->sample_fmt
    *                     If the sample format is planar, each channel plane will
    *                     be the same size, with no padding between channels.
    * @param[in,out] frame_size_ptr the output buffer size in bytes
    * @param[in] avpkt The input AVPacket containing the input buffer.
    *            You can create such packet with av_init_packet() and by then setting
    *            data and size, some decoders might in addition need other fields.
    *            All decoders are designed to use the least fields possible though.
    * @return On error a negative value is returned, otherwise the number of bytes
    * used or zero if no frame data was decompressed (used) from the input AVPacket.
  *)
  function avcodec_decode_audio3(avctx: PAVCodecContext; samples: pcint16;
  rame_size_ptr: pcint; avpkt: PAVPacket): cint; deprecated;
{$IFEND}
  (* *
    * Decode the audio frame of size avpkt->size from avpkt->data into frame.
    *
    * Some decoders may support multiple frames in a single AVPacket. Such
    * decoders would then just decode the first frame. In this case,
    * avcodec_decode_audio4 has to be called again with an AVPacket containing
    * the remaining data in order to decode the second frame, etc...
    * Even if no frames are returned, the packet needs to be fed to the decoder
    * with remaining data until it is completely consumed or an error occurs.
    *
    * @warning The input buffer, avpkt->data must be FF_INPUT_BUFFER_PADDING_SIZE
    *          larger than the actual read bytes because some optimized bitstream
    *          readers read 32 or 64 bits at once and could read over the end.
    *
    * @note You might have to align the input buffer. The alignment requirements
    *       depend on the CPU and the decoder.
    *
    * @param      avctx the codec context
    * @param[out] frame The AVFrame in which to store decoded audio samples.
    *                   Decoders request a buffer of a particular size by setting
    *                   AVFrame.nb_samples prior to calling get_buffer(). The
    *                   decoder may, however, only utilize part of the buffer by
    *                   setting AVFrame.nb_samples to a smaller value in the
    *                   output frame.
    * @param[out] got_frame_ptr Zero if no frame could be decoded, otherwise it is
    *                           non-zero.
    * @param[in]  avpkt The input AVPacket containing the input buffer.
    *                   At least avpkt->data and avpkt->size should be set. Some
    *                   decoders might also require additional fields to be set.
    * @return A negative error code is returned if an error occurred during
    *         decoding, otherwise the number of bytes consumed from the input
    *         AVPacket is returned.
  *)
  function avcodec_decode_audio4(avctx: PAVCodecContext; frame: PAVFrame;
  got_frame_ptr: pcint; avpkt: PAVPacket): cint;cdecl; external av__codec;

  (* *
    * Decode the video frame of size avpkt->size from avpkt->data into picture.
    * Some decoders may support multiple frames in a single AVPacket, such
    * decoders would then just decode the first frame.
    *
    * @warning The input buffer must be FF_INPUT_BUFFER_PADDING_SIZE larger than
    * the actual read bytes because some optimized bitstream readers read 32 or 64
    * bits at once and could read over the end.
    *
    * @warning The end of the input buffer buf should be set to 0 to ensure that
    * no overreading happens for damaged MPEG streams.
    *
    * @note You might have to align the input buffer avpkt->data.
    * The alignment requirements depend on the CPU: on some CPUs it isn't
    * necessary at all, on others it won't work at all if not aligned and on others
    * it will work but it will have an impact on performance.
    *
    * In practice, avpkt->data should have 4 byte alignment at minimum.
    *
    * @note Codecs which have the CODEC_CAP_DELAY capability set have a delay
    * between input and output, these need to be fed with avpkt->data=NULL,
    * avpkt->size=0 at the end to return the remaining frames.
    *
    * @param avctx the codec context
    * @param[out] picture The AVFrame in which the decoded video frame will be stored.
    *             Use avcodec_alloc_frame to get an AVFrame, the codec will
    *             allocate memory for the actual bitmap.
    *             with default get/release_buffer(), the decoder frees/reuses the bitmap as it sees fit.
    *             with overridden get/release_buffer() (needs CODEC_CAP_DR1) the user decides into what buffer the decoder
    *                   decodes and the decoder tells the user once it does not need the data anymore,
    *                   the user app can at this point free/reuse/keep the memory as it sees fit.
    *
    * @param[in] avpkt The input AVpacket containing the input buffer.
    *            You can create such packet with av_init_packet() and by then setting
    *            data and size, some decoders might in addition need other fields like
    *            flags&AV_PKT_FLAG_KEY. All decoders are designed to use the least
    *            fields possible.
    * @param[in,out] got_picture_ptr Zero if no frame could be decompressed, otherwise, it is nonzero.
    * @return On error a negative value is returned, otherwise the number of bytes
    * used or zero if no frame could be decompressed.
  *)
  function avcodec_decode_video2(avctx: PAVCodecContext;
   picture:PAVFrame;got_picture_ptr:pcint;avpkt: PAVPacket):cint;cdecl; external av__codec;

  (* *
    * Decode a subtitle message.
    * Return a negative value on error, otherwise return the number of bytes used.
    * If no subtitle could be decompressed, got_sub_ptr is zero.
    * Otherwise, the subtitle is stored in *sub.
    * Note that CODEC_CAP_DR1 is not available for subtitle codecs. This is for
    * simplicity, because the performance difference is expect to be negligible
    * and reusing a get_buffer written for video codecs would probably perform badly
    * due to a potentially very different allocation pattern.
    *
    * @param avctx the codec context
    * @param[out] sub The AVSubtitle in which the decoded subtitle will be stored, must be
    freed with avsubtitle_free if *got_sub_ptr is set.
    * @param[in,out] got_sub_ptr Zero if no subtitle could be decompressed, otherwise, it is nonzero.
    * @param[in] avpkt The input AVPacket containing the input buffer.
  *)
  function avcodec_decode_subtitle2(avctx: PAVCodecContext;
                sub:PAVSubtitle; got_sub_ptr:pcint;  avpkt:PAVPacket):cint;cdecl; external av__codec;

  function av_parser_next(c:PAVCodecParser):PAVCodecParser;cdecl; external av__codec;
  procedure av_register_codec_parser(parser:PAVCodecParser); cdecl; external av__codec;
  function av_parser_init( codec_id:cint):PAVCodecParserContext;cdecl; external av__codec;



  (* *
    * Parse a packet.
    *
    * @param s             parser context.
    * @param avctx         codec context.
    * @param poutbuf       set to pointer to parsed buffer or NULL if not yet finished.
    * @param poutbuf_size  set to size of parsed buffer or zero if not yet finished.
    * @param buf           input buffer.
    * @param buf_size      input length, to signal EOF, this should be 0 (so that the last frame can be output).
    * @param pts           input presentation timestamp.
    * @param dts           input decoding timestamp.
    * @param pos           input byte position in stream.
    * @return the number of bytes of the input bitstream used.
    *
    * Example:
    * @code
    *   while(in_len){
    *       len = av_parser_parse2(myparser, AVCodecContext, &data, &size,
    *                                        in_data, in_len,
    *                                        pts, dts, pos);
    *       in_data += len;
    *       in_len  -= len;
    *
    *       if(size)
    *          decode_frame(data, size);
    *   }
    * @endcode
  *)
  function av_parser_parse2( s:PAVCodecParserContext ; avctx: PAVCodecContext;poutbuf:array of pcuint8; poutbuf_size:pcint; buf:pcuint8;buf_size:cint; pts:cint64; dts:cint64; pos:cint64):cint; cdecl; external av__codec;

  (* *
    * @return 0 if the output buffer is a subset of the input, 1 if it is allocated and must be freed
    * @deprecated use AVBitstreamFilter
  *)
  function av_parser_change( s:PAVCodecParserContext; avctx: PAVCodecContext; poutbuf:array of pcuint8; poutbuf_size:pcint; buf:pcuint8;  buf_size:cint;  keyframe:cint):cint; cdecl; external av__codec;
  procedure av_parser_close( s:PAVCodecParserContext); cdecl; external av__codec;

  (* *
    * @}
    * @}
  *)

  (* *
    * @addtogroup lavc_encoding
    * @{
  *)

  (* *
    * Find a registered encoder with a matching codec ID.
    *
    * @param id AVCodecID of the requested encoder
    * @return An encoder if one was found, NULL otherwise.
  *)
   function avcodec_find_encoder(id: AVCodecID):pavcodec;cdecl; external av__codec;

  (* *
    * Find a registered encoder with the specified name.
    *
    * @param name name of the requested encoder
    * @return An encoder if one was found, NULL otherwise.
  *)
  function avcodec_find_encoder_by_name(name: pcchar):pavcodec;cdecl; external av__codec;

  {$IF FF_API_OLD_ENCODE_AUDIO }
  (* *
    * Encode an audio frame from samples into buf.
    *
    * @deprecated Use avcodec_encode_audio2 instead.
    *
    * @note The output buffer should be at least FF_MIN_BUFFER_SIZE bytes large.
    * However, for codecs with avctx->frame_size equal to 0 (e.g. PCM) the user
    * will know how much space is needed because it depends on the value passed
    * in buf_size as described below. In that case a lower value can be used.
    *
    * @param avctx the codec context
    * @param[out] buf the output buffer
    * @param[in] buf_size the output buffer size
    * @param[in] samples the input buffer containing the samples
    * The number of samples read from this buffer is frame_size*channels,
    * both of which are defined in avctx.
    * For codecs which have avctx->frame_size equal to 0 (e.g. PCM) the number of
    * samples read from samples is equal to:
    * buf_size * 8 / (avctx->channels * av_get_bits_per_sample(avctx->codec_id))
    * This also implies that av_get_bits_per_sample() must not return 0 for these
    * codecs.
    * @return On error a negative value is returned, on success zero or the number
    * of bytes used to encode the data read from the input buffer.
  *)
  function attribute_deprecated avcodec_encode_audio(avctx: PAVCodecContext;
  buf:pcuint8; buf_size:cint; samples:pcshort):cint; cdecl; external av__codec;
{$IFEND}

  (* *
    * Encode a frame of audio.
    *
    * Takes input samples from frame and writes the next output packet, if
    * available, to avpkt. The output packet does not necessarily contain data for
    * the most recent frame, as encoders can delay, split, and combine input frames
    * internally as needed.
    *
    * @param avctx     codec context
    * @param avpkt     output AVPacket.
    *                  The user can supply an output buffer by setting
    *                  avpkt->data and avpkt->size prior to calling the
    *                  function, but if the size of the user-provided data is not
    *                  large enough, encoding will fail. If avpkt->data and
    *                  avpkt->size are set, avpkt->destruct must also be set. All
    *                  other AVPacket fields will be reset by the encoder using
    *                  av_init_packet(). If avpkt->data is NULL, the encoder will
    *                  allocate it. The encoder will set avpkt->size to the size
    *                  of the output packet.
    *
    *                  If this function fails or produces no output, avpkt will be
    *                  freed using av_free_packet() (i.e. avpkt->destruct will be
    *                  called to free the user supplied buffer).
    * @param[in] frame AVFrame containing the raw audio data to be encoded.
    *                  May be NULL when flushing an encoder that has the
    *                  CODEC_CAP_DELAY capability set.
    *                  If CODEC_CAP_VARIABLE_FRAME_SIZE is set, then each frame
    *                  can have any number of samples.
    *                  If it is not set, frame->nb_samples must be equal to
    *                  avctx->frame_size for all frames except the last.
    *                  The final frame may be smaller than avctx->frame_size.
    * @param[out] got_packet_ptr This field is set to 1 by libavcodec if the
    *                            output packet is non-empty, and to 0 if it is
    *                            empty. If the function returns an error, the
    *                            packet can be assumed to be invalid, and the
    *                            value of got_packet_ptr is undefined and should
    *                            not be used.
    * @return          0 on success, negative error code on failure
  *)
  function avcodec_encode_audio2(avctx: PAVCodecContext; avpkt:PAVPacket; frame: PAVFrame; got_packet_ptr:pcint):cint;cdecl; external av__codec;

  {$IF FF_API_OLD_ENCODE_VIDEO}
  (* *
    * @deprecated use avcodec_encode_video2() instead.
    *
    * Encode a video frame from pict into buf.
    * The input picture should be
    * stored using a specific format, namely avctx.pix_fmt.
    *
    * @param avctx the codec context
    * @param[out] buf the output buffer for the bitstream of encoded frame
    * @param[in] buf_size the size of the output buffer in bytes
    * @param[in] pict the input picture to encode
    * @return On error a negative value is returned, on success zero or the number
    * of bytes used from the output buffer.
  *)
  function avcodec_encode_video(avctx: PAVCodecContext; buf:pcuint8; buf_size:cint; pict:PAVFrame):cint;deprecated; cdecl; external av__codec;
  {$IFEND}

  (* *
    * Encode a frame of video.
    *
    * Takes input raw video data from frame and writes the next output packet, if
    * available, to avpkt. The output packet does not necessarily contain data for
    * the most recent frame, as encoders can delay and reorder input frames
    * internally as needed.
    *
    * @param avctx     codec context
    * @param avpkt     output AVPacket.
    *                  The user can supply an output buffer by setting
    *                  avpkt->data and avpkt->size prior to calling the
    *                  function, but if the size of the user-provided data is not
    *                  large enough, encoding will fail. All other AVPacket fields
    *                  will be reset by the encoder using av_init_packet(). If
    *                  avpkt->data is NULL, the encoder will allocate it.
    *                  The encoder will set avpkt->size to the size of the
    *                  output packet. The returned data (if any) belongs to the
    *                  caller, he is responsible for freeing it.
    *
    *                  If this function fails or produces no output, avpkt will be
    *                  freed using av_free_packet() (i.e. avpkt->destruct will be
    *                  called to free the user supplied buffer).
    * @param[in] frame AVFrame containing the raw video data to be encoded.
    *                  May be NULL when flushing an encoder that has the
    *                  CODEC_CAP_DELAY capability set.
    * @param[out] got_packet_ptr This field is set to 1 by libavcodec if the
    *                            output packet is non-empty, and to 0 if it is
    *                            empty. If the function returns an error, the
    *                            packet can be assumed to be invalid, and the
    *                            value of got_packet_ptr is undefined and should
    *                            not be used.
    * @return          0 on success, negative error code on failure
  *)
  function avcodec_encode_video2(avctx: PAVCodecContext; avpkt:PAVPacket; frame: PAVFrame;got_packet_ptr:pcint):cint;cdecl; external av__codec;
  function avcodec_encode_subtitle(avctx: PAVCodecContext;buf:pcuint8; buf_size:cint;sub:PAVSubtitle):cint; cdecl; external av__codec;

  (* *
    * Accessors for some AVFrame fields.
    * The position of these field in the structure is not part of the ABI,
    * they should not be accessed directly outside libavcodec.
  *)
  function av_frame_get_best_effort_timestamp(frame: PAVFrame): cint64;cdecl; external av__codec;
  procedure av_frame_set_best_effort_timestamp(frame: PAVFrame; val: cint64);cdecl; external av__codec;
  function av_frame_get_pkt_duration(frame: PAVFrame): cint64; cdecl; external av__codec;
  procedure av_frame_set_pkt_duration(frame: PAVFrame; val: cint64); cdecl; external av__codec;
  function av_frame_get_pkt_pos(frame: PAVFrame): cint64; cdecl; external av__codec;
  procedure av_frame_set_pkt_pos(frame: PAVFrame; val: cint64); cdecl; external av__codec;
  function av_frame_get_channel_layout(frame: PAVFrame): cint64;  cdecl; external av__codec;
  procedure av_frame_set_channel_layout(frame: PAVFrame; val: cint64); cdecl; external av__codec;
  function av_frame_get_channels(frame: PAVFrame): cint; cdecl; external av__codec;
  procedure av_frame_set_channels(frame: PAVFrame; val: cint); cdecl; external av__codec;
  function av_frame_get_sample_rate(frame: PAVFrame): cint; cdecl; external av__codec;
  procedure av_frame_set_sample_rate(frame: PAVFrame; val: cint);cdecl; external av__codec;
  function av_frame_get_metadata(frame: PAVFrame): PAVDictionary;cdecl; external av__codec;
  procedure av_frame_set_metadata(frame: PAVFrame; val: PAVDictionary);cdecl; external av__codec;
  function av_frame_get_decode_error_flags(frame: PAVFrame): cint; cdecl; external av__codec;
  procedure av_frame_set_decode_error_flags(frame: PAVFrame; val: cint); cdecl; external av__codec;
  function av_frame_get_pkt_size(frame: PAVFrame): cint; cdecl; external av__codec;
  procedure av_frame_set_pkt_size(frame: PAVFrame; val: cint); cdecl; external av__codec;

  function av_codec_get_pkt_timebase(avctx: PAVCodecContext): AVRational; cdecl; external av__codec;
  procedure av_codec_set_pkt_timebase(avctx: PAVCodecContext; val: AVRational); cdecl; external av__codec;

  function av_codec_get_codec_descriptor(avctx: PAVCodecContext)
  : PAVCodecDescriptor; cdecl; external av__codec;
  procedure av_codec_set_codec_descriptor(avctx: PAVCodecContext;
  desc: PAVCodecDescriptor);  cdecl; external av__codec;


    {$IF FF_API_AVCODEC_RESAMPLE}
    (* *
    *  Initialize audio resampling context.
    *
    * @param output_channels  number of output channels
    * @param input_channels   number of input channels
    * @param output_rate      output sample rate
    * @param input_rate       input sample rate
    * @param sample_fmt_out   requested output sample format
    * @param sample_fmt_in    input sample format
    * @param filter_length    length of each FIR filter in the filterbank relative to the cutoff frequency
    * @param log2_phase_count log2 of the number of entries in the polyphase filterbank
    * @param linear           if 1 then the used FIR filter will be linearly interpolated
    between the 2 closest, if 0 the closest will be used
    * @param cutoff           cutoff frequency, 1.0 corresponds to half the output sampling rate
    * @return allocated ReSampleContext, NULL if error occurred
  *)
  function av_audio_resample_init
  (output_channels:cint; input_channels:cint;output_rate:cint; input_rate:cint;
   sample_fmt_out:AVSampleFormat;  sample_fmt_in:AVSampleFormat;
  filter_length:cint; log2_phase_count:cint; linear:cint; cutoff:cdouble):PResampleContext;deprecated; cdecl; external av__codec;

  function audio_resample( s:PReSampleContext;  output:pcshort;
  input:pcshort;  nb_samples:cint):cint;deprecated;  cdecl; external av__codec;

  (* *
    * Free resample context.
    *
    * @param s a non-NULL pointer to a resample context previously
    *          created with av_audio_resample_init()
  *)
 procedure audio_resample_close(s:PReSampleContext);deprecated; cdecl; external av__codec;

  (* *
    * Initialize an audio resampler.
    * Note, if either rate is not an integer then simply scale both rates up so they are.
    * @param filter_length length of each FIR filter in the filterbank relative to the cutoff freq
    * @param log2_phase_count log2 of the number of entries in the polyphase filterbank
    * @param linear If 1 then the used FIR filter will be linearly interpolated
    between the 2 closest, if 0 the closest will be used
    * @param cutoff cutoff frequency, 1.0 corresponds to half the output sampling rate
  *)
  function av_resample_init(out_rate:cint;
  in_rate;cint; filter_length:cint; log2_phase_count:cint; linear:cint;cutoff:cdouble):PAVResampleContext; deprecated; cdecl; external av__codec;

  (* *
    * Resample an array of samples using a previously configured context.
    * @param src an array of unconsumed samples
    * @param consumed the number of samples of src which have been consumed are returned here
    * @param src_size the number of unconsumed samples available
    * @param dst_size the amount of space in samples available in dst
    * @param update_ctx If this is 0 then the context will not be modified, that way several channels can be resampled with the same context.
    * @return the number of samples written in dst or -1 if an error occurred
  *)
  function av_resample( c:PAVResampleContext;
   dst:pcshort;   src:pcshort; consumed:pcint;   src_size:cint;   dst_size:cint;
  update_ctx:cint):cint;deprecated; cdecl; external av__codec;

  (* *
    * Compensate samplerate/timestamp drift. The compensation is done by changing
    * the resampler parameters, so no audible clicks or similar distortions occur
    * @param compensation_distance distance in output samples over which the compensation should be performed
    * @param sample_delta number of output samples which should be output less
    *
    * example: av_resample_compensate(c, 10, 500)
    * here instead of 510 samples only 500 samples would be output
    *
    * note, due to rounding the actual compensation might be slightly different,
    * especially if the compensation_distance is large and the in_rate used during init is small
  *)
  procedure av_resample_compensate( c:PAVResampleContext;sample_delta:cint; compensation_distance:cint);deprecated;
  procedure av_resample_close(c:PAVResampleContext);deprecated; cdecl; external av__codec;

 {$IFEND}

 (* *
    * Allocate memory for a picture.  Call avpicture_free() to free it.
    *
    * @see avpicture_fill()
    *
    * @param picture the picture to be filled in
    * @param pix_fmt the format of the picture
    * @param width the width of the picture
    * @param height the height of the picture
    * @return zero if successful, a negative value if not
  *)
  function avpicture_alloc( picture:PAVPicture ;  pix_fmt:AVPixelFormat;
   width:cint;  height:cint ):cint; cdecl; external av__codec;

  (* *
    * Free a picture previously allocated by avpicture_alloc().
    * The data buffer used by the AVPicture is freed, but the AVPicture structure
    * itself is not.
    *
    * @param picture the AVPicture to be freed
  *)
  procedure avpicture_free( picture:PAVPicture ); cdecl; external av__codec;

  (* *
    * Fill in the AVPicture fields, always assume a linesize alignment of
    * 1.
    *
    * @see av_image_fill_arrays()
  *)
  function avpicture_fill( picture:PAVPicture;
       ptr:pcuint8;  pix_fmt:AVPixelFormat;  width:cint;  height:cint ):cint; cdecl; external av__codec;

  (* *
    * Copy pixel data from an AVPicture into a buffer, always assume a
    * linesize alignment of 1.
    *
    * @see av_image_copy_to_buffer()
  *)
  function avpicture_layout(src:PAVPicture;  pix_fmt:AVPixelFormat;  width:cint;  height:cint;
         dest:pcchar; dest_size:cint):cint; cdecl; external av__codec;

  (* *
    * Calculate the size in bytes that a picture of the given width and height
    * would occupy if stored in the given picture format.
    * Always assume a linesize alignment of 1.
    *
    * @see av_image_get_buffer_size().
  *)
  function avpicture_get_size( pix_fmt:AVPixelFormat;  width:cint;  height:cint ):cint; cdecl; external av__codec;

  {$IF FF_API_DEINTERLACE}
  (* *
    *  deinterlace - if not supported return -1
    *
    * @deprecated - use yadif (in libavfilter) instead
  *)
   function avpicture_deinterlace(AVPicture * dst;src:PAVPicture;  pix_fmt:AVPixelFormat; width:cint; height:cint):cint;deprecated; cdecl; external av__codec;
 {$IFEND}
  (* *
    * Copy image src to dst. Wraps av_image_copy().
  *)
  procedure av_picture_copy( dst:PAVPicture;src:PAVPicture;  pix_fmt:AVPixelFormat;  width:cint;  height:cint );cdecl; external av__codec;

  (* *
    * Crop image top and left side.
  *)
  function av_picture_crop(dst:PAVPicture;src:PAVPicture;  pix_fmt:AVPixelFormat;  top_band:cint;left_band:cint):cint; cdecl; external av__codec;

  (* *
    * Pad image.
  *)
  function av_picture_pad( dst:PAVPicture;  src:PAVPicture;  height:cint; width:cint;  pix_fmt:AVPixelFormat;
   padtop:cint; padbottom:cint; padleft:cint; padright:cint; color:pcint):cint; cdecl; external av__codec;


   (* *
    * Utility function to access log2_chroma_w log2_chroma_h from
    * the pixel format AVPixFmtDescriptor.
    *
    * This function asserts that pix_fmt is valid. See av_pix_fmt_get_chroma_sub_sample
    * for one that returns a failure code and continues in case of invalid
    * pix_fmts.
    *
    * @param[in]  pix_fmt the pixel format
    * @param[out] h_shift store log2_chroma_h
    * @param[out] v_shift store log2_chroma_w
    *
    * @see av_pix_fmt_get_chroma_sub_sample
  *)

  procedure avcodec_get_chroma_sub_sample( pix_fmt:AVPixelFormat; h_shift:pcint;
   v_shift:pcint); cdecl; external av__codec;

  (* *
    * Return a value representing the fourCC code associated to the
    * pixel format pix_fmt, or 0 if no associated fourCC code can be
    * found.
  *)
  function avcodec_pix_fmt_to_codec_tag( pix_fmt:AVPixelFormat):cint;cdecl; external av__codec;



  (* *
    * Compute what kind of losses will occur when converting from one specific
    * pixel format to another.
    * When converting from one pixel format to another, information loss may occur.
    * For example, when converting from RGB24 to GRAY, the color information will
    * be lost. Similarly, other losses occur when converting from some formats to
    * other formats. These losses can involve loss of chroma, but also loss of
    * resolution, loss of color depth, loss due to the color space conversion, loss
    * of the alpha bits or loss due to color quantization.
    * avcodec_get_fix_fmt_loss() informs you about the various types of losses
    * which will occur when converting from one pixel format to another.
    *
    * @param[in] dst_pix_fmt destination pixel format
    * @param[in] src_pix_fmt source pixel format
    * @param[in] has_alpha Whether the source pixel format alpha channel is used.
    * @return Combination of flags informing you what kind of losses will occur
    * (maximum loss for an invalid dst_pix_fmt).
  *)
  function avcodec_get_pix_fmt_loss(dst_pix_fmt:AVPixelFormat;
   src_pix_fmt:AVPixelFormat; has_alpha:cint):cint; cdecl; external av__codec;


   {$IF FF_API_FIND_BEST_PIX_FMT}
  (* *
    * @deprecated use avcodec_find_best_pix_fmt_of_2() instead.
    *
    * Find the best pixel format to convert to given a certain source pixel
    * format.  When converting from one pixel format to another, information loss
    * may occur.  For example, when converting from RGB24 to GRAY, the color
    * information will be lost. Similarly, other losses occur when converting from
    * some formats to other formats. avcodec_find_best_pix_fmt() searches which of
    * the given pixel formats should be used to suffer the least amount of loss.
    * The pixel formats from which it chooses one, are determined by the
    * pix_fmt_mask parameter.
    *
    * Note, only the first 64 pixel formats will fit in pix_fmt_mask.
    *
    * @code
    * src_pix_fmt = AV_PIX_FMT_YUV420P;
    * pix_fmt_mask = (1 << AV_PIX_FMT_YUV422P) | (1 << AV_PIX_FMT_RGB24);
    * dst_pix_fmt = avcodec_find_best_pix_fmt(pix_fmt_mask, src_pix_fmt, alpha, &loss);
    * @endcode
    *
    * @param[in] pix_fmt_mask bitmask determining which pixel format to choose from
    * @param[in] src_pix_fmt source pixel format
    * @param[in] has_alpha Whether the source pixel format alpha channel is used.
    * @param[out] loss_ptr Combination of flags informing you what kind of losses will occur.
    * @return The best pixel format to convert to or -1 if none was found.
  *)
  function avcodec_find_best_pix_fmt(pix_fmt_mask:cint64;  src_pix_fmt:AVPixelFormat; has_alpha:cint;
         loss_ptr:pcint):AVPixelFormat;deprecated;cdecl; external av__codec;
   {$IFEND}

   (* FF_API_FIND_BEST_PIX_FMT *)

  (* *
    * Find the best pixel format to convert to given a certain source pixel
    * format.  When converting from one pixel format to another, information loss
    * may occur.  For example, when converting from RGB24 to GRAY, the color
    * information will be lost. Similarly, other losses occur when converting from
    * some formats to other formats. avcodec_find_best_pix_fmt_of_2() searches which of
    * the given pixel formats should be used to suffer the least amount of loss.
    * The pixel formats from which it chooses one, are determined by the
    * pix_fmt_list parameter.
    *
    *
    * @param[in] pix_fmt_list AV_PIX_FMT_NONE terminated array of pixel formats to choose from
    * @param[in] src_pix_fmt source pixel format
    * @param[in] has_alpha Whether the source pixel format alpha channel is used.
    * @param[out] loss_ptr Combination of flags informing you what kind of losses will occur.
    * @return The best pixel format to convert to or -1 if none was found.
  *)
  function avcodec_find_best_pix_fmt_of_list(
  pix_fmt_list:PAVPixelFormat;  src_pix_fmt:AVPixelFormat; has_alpha:cint; loss_ptr:pcint):AVPixelFormat; cdecl; external av__codec;

  (* *
    * Find the best pixel format to convert to given a certain source pixel
    * format and a selection of two destination pixel formats. When converting from
    * one pixel format to another, information loss may occur.  For example, when converting
    * from RGB24 to GRAY, the color information will be lost. Similarly, other losses occur when
    * converting from some formats to other formats. avcodec_find_best_pix_fmt_of_2() selects which of
    * the given pixel formats should be used to suffer the least amount of loss.
    *
    * If one of the destination formats is AV_PIX_FMT_NONE the other pixel format (if valid) will be
    * returned.
    *
    * @code
    * src_pix_fmt = AV_PIX_FMT_YUV420P;
    * dst_pix_fmt1= AV_PIX_FMT_RGB24;
    * dst_pix_fmt2= AV_PIX_FMT_GRAY8;
    * dst_pix_fmt3= AV_PIX_FMT_RGB8;
    * loss= FF_LOSS_CHROMA; // don't care about chroma loss, so chroma loss will be ignored.
    * dst_pix_fmt = avcodec_find_best_pix_fmt_of_2(dst_pix_fmt1, dst_pix_fmt2, src_pix_fmt, alpha, &loss);
    * dst_pix_fmt = avcodec_find_best_pix_fmt_of_2(dst_pix_fmt, dst_pix_fmt3, src_pix_fmt, alpha, &loss);
    * @endcode
    *
    * @param[in] dst_pix_fmt1 One of the two destination pixel formats to choose from
    * @param[in] dst_pix_fmt2 The other of the two destination pixel formats to choose from
    * @param[in] src_pix_fmt Source pixel format
    * @param[in] has_alpha Whether the source pixel format alpha channel is used.
    * @param[in, out] loss_ptr Combination of loss flags. In: selects which of the losses to ignore, i.e.
    *                               NULL or value of zero means we care about all losses. Out: the loss
    *                               that occurs when converting from src to selected dst pixel format.
    * @return The best pixel format to convert to or -1 if none was found.
  *)
  function avcodec_find_best_pix_fmt_of_2( dst_pix_fmt1:AVPixelFormat;  dst_pix_fmt2:AVPixelFormat;
   src_pix_fmt:AVPixelFormat; has_alpha:cint; loss_ptr:pcint):AVPixelFormat; cdecl; external av__codec;


  {$IF AV_HAVE_INCOMPATIBLE_FORK_ABI}
   function avcodec_find_best_pix_fmt2(pix_fmt_list:PAVPixelFormat;
            src_pix_fmt:AVPixelFormat; has_alpha:cint; loss_ptr:pcint):AVPixelFormat;deprecated;cdecl; external av__codec;
  {$ELSE}
   function avcodec_find_best_pix_fmt2( dst_pix_fmt1:AVPixelFormat;  dst_pix_fmt2:AVPixelFormat;
             src_pix_fmt:AVPixelFormat;  has_alpha:cint; loss_ptr:pcint):AVPixelFormat;deprecated;cdecl; external av__codec;
  {$IFEND}

  function avcodec_default_get_format( s: PAVCodecContext;
   fmt:PAVPixelFormat):AVPixelFormat; cdecl; external av__codec;

  (* *
    * @}
  *)

  procedure avcodec_set_dimensions(s: PAVCodecContext;  width:cint;  height:cint );cdecl; external av__codec;

  (* *
    * Put a string representing the codec tag codec_tag in buf.
    *
    * @param buf_size size in bytes of buf
    * @return the length of the string that would have been generated if
    * enough space had been available, excluding the trailing null
  *)
  function av_get_codec_tag_string(buf:pcchar; buf_size:cuint;
      codec_tag:cuint):cuint; cdecl; external av__codec;

  procedure avcodec_string(  buf:pcchar  ;   buf_size:cint;  enc:PAVCodecContext;
    encode:cint);  cdecl; external av__codec;

  (* *
    * Return a name for the specified profile, if available.
    *
    * @param codec the codec that is searched for the given profile
    * @param profile the profile value for which a name is requested
    * @return A name for the profile if found, NULL otherwise.
  *)
  function av_get_profile_name(codec: PAVCodec;  profile:cint):pcchar; cdecl; external av__codec;

  function avcodec_default_execute( c:PAVCodecContext; func:PAvcodecDefaultArgFunc;
              arg:pointer; ret:pcint; count:cint; size:cint):cint;  cdecl; external av__codec;
  function avcodec_default_execute2(c:PAVCodecContext;func: PAvcodecDefault2ArgFunc;
                // int (*func)(AVCodecContext *c2, void *arg2, int, int),
                 arg:pointer; ret:pcint;  count:cint):cint; cdecl; external av__codec;
    //FIXME func typedef

    (**
    * Fill AVFrame audio data and linesize pointers.
    *
    * The buffer buf must be a preallocated buffer with a size big enough
    * to contain the specified samples amount. The filled AVFrame data
    * pointers will point to this buffer.
    *
    * AVFrame extended_data channel pointers are allocated if necessary for
    * planar audio.
    *
    * @param frame       the AVFrame
    *                    frame->nb_samples must be set prior to calling the
    *                    function. This function fills in frame->data,
    *                    frame->extended_data, frame->linesize[0].
    * @param nb_channels channel count
    * @param sample_fmt  sample format
    * @param buf         buffer to use for frame data
    * @param buf_size    size of buffer
    * @param align       plane size sample alignment (0 = default)
    * @return            >=0 on success, negative error code on failure
    * @todo return the size in bytes required to store the samples in
    * case of success, at the next libavutil bump
  *)
  function avcodec_fill_audio_frame(frame: PAVFrame; nb_channels:cint;  sample_fmt:AVSampleFormat;
   buf:pcuint8;   buf_size:cint; align:cint):cint; cdecl; external av__codec;

  (* *
    * Flush buffers, should be called when seeking or when switching to a different stream.
  *)
  procedure avcodec_flush_buffers(avctx:PAVCodecContext);  cdecl; external av__codec;

  procedure avcodec_default_free_buffers(s: PAVCodecContext); cdecl; external av__codec;

  (* *
    * Return codec bits per sample.
    *
    * @param[in] codec_id the codec
    * @return Number of bits per sample or zero if unknown for the given codec.
  *)
  function av_get_bits_per_sample(codec_id: AVCodecID):cint;cdecl; external av__codec;

  (* *
    * Return the PCM codec associated with a sample format.
    * @param be  endianness, 0 for little, 1 for big,
    *            -1 (or anything else) for native
    * @return  AV_CODEC_ID_PCM_* or AV_CODEC_ID_NONE
  *)
  function av_get_pcm_codec( fmt:AVSampleFormat;  be:cint):AVCodecID;cdecl; external av__codec;

  (* *
    * Return codec bits per sample.
    * Only return non-zero if the bits per sample is exactly correct, not an
    * approximation.
    *
    * @param[in] codec_id the codec
    * @return Number of bits per sample or zero if unknown for the given codec.
  *)
  function av_get_exact_bits_per_sample(codec_id: AVCodecID):cint; cdecl; external av__codec;

  (* *
    * Return audio frame duration.
    *
    * @param avctx        codec context
    * @param frame_bytes  size of the frame, or 0 if unknown
    * @return             frame duration, in samples, if known. 0 if not able to
    *                     determine.
  *)
  function av_get_audio_frame_duration(avctx: PAVCodecContext;frame_bytes: cint): cint; cdecl; external av__codec;


   procedure av_register_bitstream_filter(bsf: PAVBitStreamFilter); cdecl; external av__codec;
  function av_bitstream_filter_init(name: pcchar): PAVBitStreamFilterContext; cdecl; external av__codec;
  function av_bitstream_filter_filter(bsfc: PAVBitStreamFilterContext;
  avctx: PAVCodecContext; args: pcchar; poutbuf: array of pcuint8; poutbuf_size: pcint;
  buf: pcuint8; buf_size: cint; keyframe: cint): cint; cdecl; external av__codec;
  procedure av_bitstream_filter_close(bsf: PAVBitStreamFilterContext); cdecl; external av__codec;

  function av_bitstream_filter_next(f: PAVBitStreamFilter): PAVBitStreamFilter; cdecl; external av__codec;

  (* memory *)

  (* *
    * Reallocate the given block if it is not large enough, otherwise do nothing.
    *
    * @see av_realloc
  *)
  function av_fast_realloc(ptr: Pointer; size: pcuint; min_size: cint): Pointer; cdecl; external av__codec;

  (* *
    * Allocate a buffer, reusing the given one if large enough.
    *
    * Contrary to av_fast_realloc the current buffer contents might not be
    * preserved and on error the old buffer is freed, thus no special
    * handling to avoid memleaks is necessary.
    *
    * @param ptr pointer to pointer to already allocated buffer, overwritten with pointer to new buffer
    * @param size size of the buffer *ptr points to
    * @param min_size minimum size of *ptr buffer after returning, *ptr will be NULL and
    *                 *size 0 if an error occurred.
  *)
  procedure av_fast_malloc(ptr: Pointer; size: pcuint; min_size: cint); cdecl; external av__codec;

  (* *
    * Same behaviour av_fast_malloc but the buffer has additional
    * FF_INPUT_BUFFER_PADDING_SIZE at the end which will will always be 0.
    *
    * In addition the whole buffer will initially and after resizes
    * be 0-initialized so that no uninitialized data will ever appear.
  *)
  procedure av_fast_padded_malloc(ptr: Pointer; size: pcuint; min_size: cint); cdecl; external av__codec;

  (* *
    * Same behaviour av_fast_padded_malloc except that buffer will always
    * be 0-initialized after call.
  *)
  procedure av_fast_padded_mallocz(ptr: Pointer; size: pcuint; min_size: cint); cdecl; external av__codec;

  (* *
    * Encode extradata length to a buffer. Used by xiph codecs.
    *
    * @param s buffer to write to; must be at least (v/255+1) bytes long
    * @param v size of extradata in bytes
    * @return number of bytes written to the buffer.
  *)
  function av_xiphlacing(s: pcuchar; v: cuint): cuint; cdecl; external av__codec;

  (* *
    * Log a generic warning message about a missing feature. This function is
    * intended to be used internally by FFmpeg (libavcodec, libavformat, etc.)
    * only, and would normally not be used by applications.
    * @param[in] avc a pointer to an arbitrary struct of which the first field is
    * a pointer to an AVClass struct
    * @param[in] feature string containing the name of the missing feature
    * @param[in] want_sample indicates if samples are wanted which exhibit this feature.
    * If want_sample is non-zero, additional verbage will be added to the log
    * message which tells the user how to report samples to the development
    * mailing list.
  *)
  procedure av_log_missing_feature(avc: Pointer; feature: pcchar;
  want_sample: cint);  cdecl; external av__codec;

  (* *
    * Log a generic warning message asking for a sample. This function is
    * intended to be used internally by FFmpeg (libavcodec, libavformat, etc.)
    * only, and would normally not be used by applications.
    * @param[in] avc a pointer to an arbitrary struct of which the first field is
    * a pointer to an AVClass struct
    * @param[in] msg string containing an optional message, or NULL if no message
  *)
  // void av_log_ask_for_sample( avc:pointer; const char * msg, ...)av_printf_format(2, 3);
  procedure av_log_ask_for_sample(avc: Pointer; msg: array of pcchar); cdecl; external av__codec;
  // array of TVarRec);

  (* *
    * Register the hardware accelerator hwaccel.
  *)
  procedure av_register_hwaccel(hwaccel: PAVHWAccel);  cdecl; external av__codec;

  (* *
    * If hwaccel is NULL, returns the first registered hardware accelerator,
    * if hwaccel is non-NULL, returns the next registered hardware accelerator
    * after hwaccel, or NULL if hwaccel is the last one.
  *)
  function av_hwaccel_next(hwaccel: PAVHWAccel): PAVHWAccel; cdecl; external av__codec;


  (* *
    * Register a user provided lock manager supporting the operations
    * specified by AVLockOp. mutex points to a void* where the *
    lockmgr should store / get a Pointer to a user allocated mutex.It 's * NULL
    upon AV_LOCK_CREATE and ! = NULL for all other ops. * *
    @param cb user defined callback.Note: FFmpeg may invoke calls to this *
    callback during the call to av_lockmgr_register(). * Thus,
    the application must be prepared to handle that. *
    If cb is set to NULL the lockmgr will be unregistered. *
    Also Note that during unregistration the previously registered *
    lockmgr callback may Also be invoked. *)
  function av_lockmgr_register(cb: PAvLockmgrRegCbFunc): cint;  cdecl; external av__codec;

  (* *
    * Get the type of the given codec.
  *)
  function avcodec_get_type(codec_id: AVCodecID): AVMediaType; cdecl; external av__codec;

  (* *
    * Get the name of a codec.
    * @return  a static string identifying the codec; never NULL
  *)
  function avcodec_get_name(id: AVCodecID): pcchar;  cdecl; external av__codec;

  (* *
    * @return a positive value if s is open (i.e. avcodec_open2() was called on it
    * with no corresponding avcodec_close()), 0 otherwise.
  *)
  function avcodec_is_open(s: PAVCodecContext): cint;  cdecl; external av__codec;

  (* *
    * @return a non-zero number if codec is an encoder, zero otherwise
  *)
  function av_codec_is_encoder(codec: PAVCodec): cint; cdecl; external av__codec;

  (* *
    * @return a non-zero number if codec is a decoder, zero otherwise
  *)
  function av_codec_is_decoder(codec: PAVCodec): cint; cdecl; external av__codec;

  (* *
    * @return descriptor for given codec ID or NULL if no descriptor exists.
  *)
  function avcodec_descriptor_get(id: AVCodecID): PAVCodecDescriptor;  cdecl; external av__codec;

  (* *
    * Iterate over all codec descriptors known to libavcodec.
    *
    * @param prev previous descriptor. NULL to get the first descriptor.
    *
    * @return next descriptor or NULL after the last descriptor
  *)
  function avcodec_descriptor_next(prev: PAVCodecDescriptor)
  : PAVCodecDescriptor;  cdecl; external av__codec;

  (* *
    * @return codec descriptor with the given name or NULL if no such descriptor
    *         exists.
  *)
  function avcodec_descriptor_get_by_name(name: pcchar): PAVCodecDescriptor; cdecl; external av__codec;
