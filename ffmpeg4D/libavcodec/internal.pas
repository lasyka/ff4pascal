unit internal;
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

implementation

end.
