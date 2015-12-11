use "collections"

actor Server
  let _env: Env
  var pubs: Set[Publisher val] trn
  let sub_workers: List[Worker]

  new create(env': Env) =>
    _env = env'
    pubs = recover Set[Publisher val] end
    sub_workers = List[Worker]

  be register_publisher(pub: Publisher val) =>
    pubs.set(pub)

  be reload(pubs': Set[Publisher val] iso) =>
    pubs = consume pubs'

  be register_subscriber(sub: Subscriber val) =>
    sub_workers.push(Worker(sub))

  be publish(sender: Publisher val, message: String) =>
    let isRegistered = (Set[Publisher val].set(sender) < pubs)
    if(isRegistered == false) then return end

    for worker in sub_workers.values() do
      worker.receive(message)
    end

