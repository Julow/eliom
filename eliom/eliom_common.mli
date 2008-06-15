(* Ocsigen
 * http://www.ocsigen.org
 * Module eliom_common.mli
 * Copyright (C) 2005 Vincent Balat
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

(** Low level functions for Eliom, exceptions and types. *)

open Ocsigen_extensions


exception Eliom_404 (** Page not found *)
exception Eliom_Wrong_parameter (** Service called with wrong parameter names *)
exception Eliom_Link_too_old (** The coservice does not exist any more *)
exception Eliom_Session_expired
exception Eliom_Service_session_expired of (string list)
    (** The service session cookies does not exist any more.
        The string lists are the list of names of expired sessions
     *)
exception Eliom_Typing_Error of (string * exn) list
    (** The service (GET or POST) parameters do not match expected type *)


exception Eliom_function_forbidden_outside_site_loading of string
    (** That function cannot be used like that outside the
       initialisation phase.
       For some functions, you must add the [~sp] parameter during a session.
     *)

(**/**)





type na_key =
  | Na_no
  | Na_get_ of string (* service *)
  | Na_post_ of string (* service *)
  | Na_get' of string (* coservice *)
  | Na_post' of string (* coservice *)


exception Eliom_duplicate_registration of string
exception Eliom_there_are_unregistered_services of
            (string list * string list list * na_key list)
exception Eliom_page_erasing of string
exception Eliom_error_while_loading_site of string

val defaultpagename : string
val eliom_suffix_name : string
val eliom_suffix_internal_name : string
val naservice_num : string
val naservice_name : string
val get_state_param_name : string
val post_state_param_name : string
val co_param_prefix : string
val na_co_param_prefix : string

val datacookiename : string
val servicecookiename : string
val persistentcookiename : string
val sdatacookiename : string
val sservicecookiename : string
val spersistentcookiename : string

val persistent_cookie_table_version : string
val eliom_persistent_cookie_table : string
type internal_state = string
type cookie =
  | Set of Ocsigen_extensions.url_path option * float option * string * string * bool
  | Unset of Ocsigen_extensions.url_path option * string
type sess_info = {
  si_other_get_params : (string * string) list;
  si_all_get_params : (string * string) list;
  si_all_post_params : (string * string) list;
  si_service_session_cookies : string Ocsigen_http_frame.Cookievalues.t;
  si_data_session_cookies : string Ocsigen_http_frame.Cookievalues.t;
  si_persistent_session_cookies : string Ocsigen_http_frame.Cookievalues.t;
  si_secure_cookie_info:
    (string Ocsigen_http_frame.Cookievalues.t *
       string Ocsigen_http_frame.Cookievalues.t *
       string Ocsigen_http_frame.Cookievalues.t) option;
  si_nonatt_info : na_key;
  si_state_info : internal_state option * internal_state option;
  si_config_file_charset : string;
  si_previous_extension_error : int;
}
module SessionCookies :
  sig
    type key = string
    type 'a t
    val create : int -> 'a t
    val clear : 'a t -> unit
    val copy : 'a t -> 'a t
    val add : 'a t -> key -> 'a -> unit
    val remove : 'a t -> key -> unit
    val find : 'a t -> key -> 'a
    val find_all : 'a t -> key -> 'a list
    val replace : 'a t -> key -> 'a -> unit
    val mem : 'a t -> key -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val length : 'a t -> int
  end
type 'a session_cookie = SCNo_data | SCData_session_expired | SC of 'a
type cookie_exp = CENothing | CEBrowser | CESome of float
type timeout = TGlobal | TNone | TSome of float
type 'a one_service_cookie_info = {
  sc_value : string;
  sc_table : 'a ref;
  sc_timeout : timeout ref;
  sc_exp : float option ref;
  sc_cookie_exp : cookie_exp ref;
  sc_session_group : Eliommod_sessiongroups.sessgrp option ref;
}
type one_data_cookie_info = {
  dc_value : string;
  dc_timeout : timeout ref;
  dc_exp : float option ref;
  dc_cookie_exp : cookie_exp ref;
  dc_session_group : Eliommod_sessiongroups.sessgrp option ref;
}
type one_persistent_cookie_info = {
  pc_value : string;
  pc_timeout : timeout ref;
  pc_cookie_exp : cookie_exp ref;
  pc_session_group : Eliommod_sessiongroups.perssessgrp option ref;
}

type 'a cookie_info1 =
    (string option * 'a one_service_cookie_info session_cookie ref)
    Ocsigen_http_frame.Cookievalues.t ref *
    (string option * one_data_cookie_info session_cookie ref) Lazy.t
    Ocsigen_http_frame.Cookievalues.t ref *
    ((string * timeout * float option *
      Eliommod_sessiongroups.perssessgrp option)
     option * one_persistent_cookie_info session_cookie ref)
    Lwt.t Lazy.t Ocsigen_http_frame.Cookievalues.t ref

type 'a cookie_info =
    'a cookie_info1 (* unsecure *) * 
      'a cookie_info1 option (* secure, if https *)

type 'a servicecookiestablecontent =
    string * 'a * float option ref * timeout ref *
    Eliommod_sessiongroups.sessgrp option ref
type 'a servicecookiestable = 'a servicecookiestablecontent SessionCookies.t
type datacookiestablecontent =
    string * float option ref * timeout ref *
    Eliommod_sessiongroups.sessgrp option ref
type datacookiestable = datacookiestablecontent SessionCookies.t
type result_to_send =
    EliomResult of Ocsigen_http_frame.result
  | EliomExn of (exn list * cookie list)
type page_table_key = {
  key_state : internal_state option * internal_state option;
  key_kind : Ocsigen_http_frame.Http_header.http_method;
}
module String_Table :
  sig
    type key = string
    type +'a t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val find : key -> 'a t -> 'a
    val remove : key -> 'a t -> 'a t
    val mem : key -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
  end
module NAserv_Table :
  sig
    type key = na_key
    type +'a t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val find : key -> 'a t -> 'a
    val remove : key -> 'a t -> 'a t
    val mem : key -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
  end
type anon_params_type = int
type server_params = {
  sp_ri : Ocsigen_extensions.request_info;
  sp_si : sess_info;
  sp_sitedata : sitedata;
  sp_cookie_info : tables cookie_info;
  sp_suffix : Ocsigen_extensions.url_path;
  sp_fullsessname : string option;
}
and page_table =
    (page_table_key *
     ((anon_params_type * anon_params_type) *
      (int *
       (int ref option * (float * float ref) option *
        (server_params -> result_to_send Lwt.t))))
     list)
    list
and naservice_table =
    AVide
  | ATable of
      (int * int ref option * (float * float ref) option *
       (server_params -> result_to_send Lwt.t))
      NAserv_Table.t
and dircontent = Vide | Table of direlt ref String_Table.t
and direlt = Dir of dircontent ref | File of page_table ref
and tables = dircontent ref * naservice_table ref * bool ref * bool ref
and sitedata = {
  site_dir : Ocsigen_extensions.url_path;
  site_dir_string : string;
  mutable servtimeout : (string * float option) list;
  mutable datatimeout : (string * float option) list;
  mutable perstimeout : (string * float option) list;
  global_services : tables;
  session_services : tables servicecookiestable;
  session_data : datacookiestable;
  mutable remove_session_data : string -> unit;
  mutable not_bound_in_data_tables : string -> bool;
  mutable exn_handler : server_params -> exn -> result_to_send Lwt.t;
  mutable unregistered_services : Ocsigen_extensions.url_path list;
  mutable unregistered_na_services : na_key list;
  mutable max_volatile_data_sessions_per_group : int option;
  mutable max_service_sessions_per_group : int option;
  mutable max_persistent_data_sessions_per_group : int option;
  defaulthostname: string;
  defaulthttpport: int;
  defaulthttpsport: int;
}
val make_server_params :
  sitedata ->
  tables cookie_info ->
  Ocsigen_extensions.request_info ->
  Ocsigen_extensions.url_path -> sess_info -> string option -> server_params
val empty_page_table : unit -> 'a list
val empty_dircontent : unit -> dircontent
val empty_naservice_table : unit -> naservice_table
val service_tables_are_empty :
  dircontent ref * naservice_table ref * 'a * 'b -> bool
val empty_tables :
  unit -> dircontent ref * naservice_table ref * bool ref * bool ref
val new_service_session_tables :
  unit -> dircontent ref * naservice_table ref * bool ref * bool ref
val split_prefix_param :
  string -> (string * 'a) list -> (string * 'a) list * (string * 'a) list
val getcookies :
  string -> 'a Ocsigen_http_frame.Cookievalues.t -> 'a Ocsigen_http_frame.Cookievalues.t
val change_request_info :
  Ocsigen_extensions.request_info ->
  string -> int -> (Ocsigen_extensions.request_info * sess_info) Lwt.t
type ('a, 'b) foundornot = Found of 'a | Notfound of 'b
val make_full_cookie_name : string -> string -> string
val make_fullsessname : sp:server_params -> string option -> string
val make_fullsessname2 : string -> string option -> string
exception Eliom_retry_with of
            (Ocsigen_extensions.request_info * sess_info * Ocsigen_http_frame.cookieset *
             tables cookie_info)
module Perstables :
  sig
    val empty : 'a list
    val add : 'a -> 'a list -> 'a list
    val fold : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
  end
val perstables : string list ref
val create_persistent_table : string -> 'a Ocsipersist.table
val persistent_cookies_table :
  (string * float option * timeout *
   Eliommod_sessiongroups.perssessgrp option)
  Ocsipersist.table
val remove_from_all_persistent_tables : string -> unit Lwt.t
val absolute_change_sitedata : sitedata -> unit
val get_current_sitedata : unit -> sitedata
val end_current_sitedata : unit -> unit
val add_unregistered : sitedata -> Ocsigen_extensions.url_path -> unit
val add_unregistered_na : sitedata -> na_key -> unit
val remove_unregistered : sitedata -> Ocsigen_extensions.url_path -> unit
val remove_unregistered_na : sitedata -> na_key -> unit
val verify_all_registered : sitedata -> unit
val during_eliom_module_loading : unit -> bool
val begin_load_eliom_module : unit -> unit
val end_load_eliom_module : unit -> unit
val global_register_allowed : unit -> (unit -> sitedata) option
val close_service_session2 :
  sitedata ->
  Eliommod_sessiongroups.sessgrp option -> SessionCookies.key -> unit
