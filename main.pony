actor Main
  new create(env:Env) =>
    let server = Server(env)

    let p1 = Publisher("niconare")
    let p2 = Publisher("nicolun")
    let s1 = Subscriber("user1", env)
    let s2 = Subscriber("user2", env)

    p1.register(server)
    p2.register(server)
    s1.register(server)
    s2.register(server)

    p1.publish(server, "new presentation!")
    p2.publish(server, "foo joined!")

