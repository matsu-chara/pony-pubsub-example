class Subscriber
  let name: String
  let _env: Env

  new val create(name': String, env': Env) =>
    name = name'
    _env = env'

  fun val register(server: Server) =>
    server.register_subscriber(this)

  fun box receive(message: String) =>
    _env.out.print(name + " received [" + message + "]")

