(* Ocsigen
 * http://www.ocsigen.org
 * Copyright (C) 2010-2011
 * Raphaël Proust
 * Pierre Chambart
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, with linking exception;
 * either version 2.1 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *)

(** Broadcasting facilities between clients and server *)

(** The type of bus's carrying values of type ['a]. Bus's are values
    that can be easily shared among clients. Each of these clients
    along with the server can send a value on the bus. Values can be
    received by each of the participants as a stream. Note that no
    effort is put to order message receptions on the different
    participants. *)
type 'a t

(** [create ?scope ?name ?size] makes a fresh bus. The [name] optional
    parameter can be used to make persistent (as in server restart
    persistent) bus's. The [scope] parameter is used to chose the kind
    of channel on which the bus rely (See [Eliom_comet.create] for
    more information). The [?name] argument allow one to make bus's
    persistent over server restart. The [size] argument behaves like
    the one on {!Eliom_comet.Channels.create} *)
val create :
  ?scope:[< Eliom_comet.Channels.comet_scope ] -> ?name:string -> ?size:int
  -> 'a Deriving_Json.t
  -> 'a t

(** [stream b] returns the stream of datas sent to bus [b]. Notice you
    sould not use that function multiple times on the same bus, it will
    return the same stream. If you want to receive multiple times the
    same datas, you sould copy the stream with [Lwt_stream.clone] *)
val stream : 'a t -> 'a Lwt_stream.t

(** [write b x] sends the value [x] on the bus [b]. Every participant,
    including the server, will receive [x]. *)
val write : 'a t -> 'a -> unit
