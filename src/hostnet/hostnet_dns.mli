
module Policy(Files: Sig.FILES): Sig.DNS_POLICY
(** Global DNS configuration *)

module Config: sig
  type t = [
    | `Upstream of Dns_forward.Config.t (** use upstream servers *)
    | `Host (** use the host's resolver *)
  ]
  val to_string: t -> string
  val compare: t -> t -> int
end

module Make
    (Ip: V1_LWT.IPV4 with type prefix = Ipaddr.V4.t)
    (Udp: V1_LWT.UDPV4)
    (Tcp:V1_LWT.TCPV4)
    (Socket: Sig.SOCKETS)
    (Dns_resolver: Sig.DNS)
    (Time: V1_LWT.TIME)
    (Clock: V1.CLOCK)
    (Recorder: Sig.RECORDER) : sig

  type t
  (** A DNS proxy instance with a fixed configuration *)

  val create: local_address:Dns_forward.Config.Address.t -> host_names:Dns.Name.t list -> Config.t -> t Lwt.t
  (** Create a DNS forwarding instance based on the given configuration, either
      [`Upstream config]: send DNS requests to the given upstream servers
      [`Host]: use the Host's resolver.
      The parameter [~local_address] will be used in any .pcap trace as the
      source address of DNS requests sent from this host. *)

  val set_recorder: Recorder.t -> unit

  val handle_udp: t:t -> udp:Udp.t -> src:Ipaddr.V4.t -> dst:Ipaddr.V4.t -> src_port:int -> Cstruct.t -> unit Lwt.t

  val handle_tcp: t:t -> (int -> (Tcp.flow -> unit Lwt.t) option) Lwt.t

  val destroy: t -> unit Lwt.t
end
