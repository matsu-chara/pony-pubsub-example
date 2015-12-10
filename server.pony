use "collections"

actor Server
  let _env: Env
  let pubs: List[Publisher val]
  let sub_workers: List[Worker]

  new create(env': Env) =>
    _env = env'
    pubs = List[Publisher val]
    sub_workers = List[Worker]

  be register_publisher(pub: Publisher val) =>
    pubs.push(pub)

  be register_subscriber(sub: Subscriber val) =>
    sub_workers.push(Worker(sub))

  be publish(message: String) =>
    for worker in sub_workers.values() do
      worker.receive(message)
    end

