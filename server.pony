use "collections"

actor Server
  let _env: Env
  let pubs: List[Publisher val]
  let subs: List[Subscriber val]

  new create(env': Env) =>
    _env = env'
    pubs = List[Publisher val]
    subs = List[Subscriber val]

  be register_publisher(pub: Publisher val) =>
    pubs.push(pub)

  be register_subscriber(sub: Subscriber val) =>
    subs.push(sub)

  be publish(message: String) =>
    for sub in subs.values() do
      sub.receive(message)
    end

