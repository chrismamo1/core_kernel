(** a signature for opaque identifier types. *)

module type S = sig
  type t with bin_io, sexp
  include Stringable.S         with type t := t
  include Comparable.S_binable with type t := t
  include Hashable.S_binable   with type t := t
  include Pretty_printer.S     with type t := t
end

module Make (M : sig
  type t with bin_io, compare, sexp
  include Stringable.S with type t := t
  val hash : t -> int
  val module_name : string  (* for registering the pretty printer *)
end) : S with type t := M.t



(** There used to be a functor [Identifiable.Of_sexpable], but we removed it because it
    encouraged a terrible implementation of [Identifiable.S].  In particular, [hash],
    [compare], and [bin_io] were all built by converting the type to a sexp, and then to a
    string.

    One should use [Identifiable.Make] instead.  Here is what a use might look like:

    {[
      module Id = struct
        module T = struct
          type t = A | B with bin_io, compare, sexp
          let hash (t : t) = Hashtbl.hash t
          include Sexpable.To_stringable (struct type nonrec t = t with sexp end)
        end
        include T
        include Identifiable.Make (T)
      end
    ]}

    We also removed [Identifiable.Of_stringable], which wasn't as obviously bad as
    [Of_sexpable].  But it still used the string as an intermediate, which is often the
    wrong choice -- especially for [compare] and [bin_io], that can be generated by
    preprocessors.
*)
