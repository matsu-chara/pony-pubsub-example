class Publisher
  let name: String

  new create(name': String) =>
    name = name'

  fun val register(server: Server) =>
    server.register_publisher(this)

  fun publish(server: Server, message: String) =>
    server.publish(name + " sends " + message)

