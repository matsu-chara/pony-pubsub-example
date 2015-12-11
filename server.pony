use "collections"

actor Server
  let _env: Env
  var pubs: List[Publisher val] trn
  let sub_workers: List[Worker]

  new create(env': Env) =>
    _env = env'
    pubs = recover List[Publisher val] end
    sub_workers = List[Worker]

  be register_publisher(pub: Publisher val) =>
    pubs.push(pub)

  be reload(pubs': List[Publisher val] iso) =>
    pubs = consume pubs'

  be register_subscriber(sub: Subscriber val) =>
    sub_workers.push(Worker(sub))

  be publish(sender: Publisher val, message: String) =>
    var isRegistered = false
    for pub in pubs.values() do
      isRegistered = isRegistered or (sender == pub)
    end
    if isRegistered == false then return end

    for worker in sub_workers.values() do
      worker.receive(message)
    end

