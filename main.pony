actor Main
  new create(env:Env) =>
    let server = Server(env)

    let p1: Publisher val = recover Publisher("niconare") end
    let p2: Publisher val = recover Publisher("nicolun") end
    let s1: Subscriber val = recover Subscriber("user1", env) end
    let s2: Subscriber val = recover Subscriber("user2", env) end

    p1.register(server)
    p2.register(server)
    s1.register(server)
    s2.register(server)

    p1.publish(server, "new presentation!")
    p2.publish(server, "foo joined!")

