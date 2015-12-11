class Publisher
  let name: String

  new val create(name': String) =>
    name = name'

  fun val register(server: Server) =>
    server.register_publisher(this)

  fun val publish(server: Server, message: String) =>
    server.publish(this, name + " sends " + message)

  fun box eq(that: Publisher box): Bool =>
    name == that.name

  fun box ne(that: Publisher box): Bool =>
    name != that.name

  fun hash(): U64 =>
    name.hash()

