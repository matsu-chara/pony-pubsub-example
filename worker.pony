actor Worker
  let sub: Subscriber val

  new create(sub': Subscriber val) =>
    sub = sub'

  be receive(message: String) =>
    sub.receive(message)
