use "collections"

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

    let p3 = Publisher("niconico")
    let p4 = Publisher("neconeco")
    let p5 = Publisher("noconoco")

    let new_publishers  = recover
      let ps = SetIs[Publisher val]
      ps.set(p3)
      ps.set(p4)
      ps.set(p5)
    end

    server.reload(consume new_publishers)
    p3.publish(server, "niconico!")
    p4.publish(server, "nyanyan!")
    p5.publish(server, "kameeee!")

    // this message will be ignored
    p1.publish(server, "new presentation!")

