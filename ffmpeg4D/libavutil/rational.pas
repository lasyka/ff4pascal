unit rational;

interface

uses
  ctypes,ffmpegconf;

(*
 * @addtogroup lavu_math
 * @{
 *)

 Type

 PAVRational=^AVRational;
(**
 * rational number numerator/denominator
 *)
AVRational=record
     num:cint; ///< numerator
     den:cint; ///< denominator
end;

(**
 * Compare two rationals.
 * @param a first rational
 * @param b second rational
 * @return 0 if a==b, 1 if a>b, -1 if a<b, and INT_MIN if one of the
 * values is of the form 0/0
 *)

//function av_cmp_q(a:AVRational;b:AVRational):cint;inline;
//begin
//    const int64_t tmp= a.num * (int64_t)b.den - b.num * (int64_t)a.den;
//
//    if(tmp) return ((tmp ^ a.den ^ b.den)>>63)|1;
//    else if(b.den && a.den) return 0;
//    else if(a.num && b.num) return (a.num>>31) - (b.num>>31);
//    else                    return INT_MIN;
//end;

(**
 * Convert rational to double.
 * @param a rational to convert
 * @return (double) a
 *)
//static inline double av_q2d(AVRational a){
//    return a.num / (double) a.den;
//}

(**
 * Reduce a fraction.
 * This is useful for framerate calculations.
 * @param dst_num destination numerator
 * @param dst_den destination denominator
 * @param num source numerator
 * @param den source denominator
 * @param max the maximum allowed for dst_num & dst_den
 * @return 1 if exact, 0 otherwise
 *)
function av_reduce(dst_num:pcint; dst_den:pcint; num:cint64; den:cint64; max:cint64):cint; cdecl;external av__util;

(**
 * Multiply two rationals.
 * @param b first rational
 * @param c second rational
 * @return b*c
 *)
function av_mul_q( b:AVRational;  c:AVRational):AVRational; cdecl;external av__util;

(**
 * Divide one rational by another.
 * @param b first rational
 * @param c second rational
 * @return b/c
 *)
function av_div_q( b:AVRational;  c:AVRational) :AVRational; cdecl;external av__util;

(**
 * Add two rationals.
 * @param b first rational
 * @param c second rational
 * @return b+c
 *)
function av_add_q(b:AVRational ; c:AVRational ) :AVRational;   cdecl;external av__util;

(**
 * Subtract one rational from another.
 * @param b first rational
 * @param c second rational
 * @return b-c
 *)
function av_sub_q(b:AVRational ; c:AVRational ) :AVRational;  cdecl;external av__util;

(**
 * Invert a rational.
 * @param q value
 * @return 1 / q
 *)
//static av_always_inline AVRational av_inv_q(AVRational q)
//{
//    AVRational r = { q.den, q.num };
//    return r;
//}

(**
 * Convert a double precision floating point number to a rational.
 * inf is expressed as {1,0} or {-1,0} depending on the sign.
 *
 * @param d double to convert
 * @param max the maximum allowed numerator and denominator
 * @return (AVRational) d
 *)
 function av_d2q( d:cdouble;  max:cint) :AVRational;  cdecl;external av__util;

(**
 * @return 1 if q1 is nearer to q than q2, -1 if q2 is nearer
 * than q1, 0 if they have the same distance.
 *)
function av_nearer_q( q:AVRational;  q1:AVRational;  q2:AVRational):cint;  cdecl;external av__util;

(**
 * Find the nearest value in q_list to q.
 * @param q_list an array of rationals terminated by {0, 0}
 * @return the index of the nearest value found in the array
 *)
function av_find_nearest_q_idx( q:AVRational; q_list:PAVRational):cint;  cdecl;external av__util;

(**
 * @}
 *)

implementation

end.
