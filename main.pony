use "collections"

actor Main
  new create(env:Env) =>
    let server = Server(env)

    let p1 = Publisher("foo")
    let p2 = Publisher("bar")
    let s1 = Subscriber("user1", env)
    let s2 = Subscriber("user2", env)

    p1.register(server)
    p2.register(server)
    s1.register(server)
    s2.register(server)

    p1.publish(server, "new!")
    p2.publish(server, "joined!")

    let p3 = Publisher("mofu")
    let p4 = Publisher("nyan")
    let p5 = Publisher("wan")

    let new_publishers  = recover
      Set[Publisher val]
        .>set(p3)
        .>set(p4)
        .>set(p5)
    end

    server.reload(consume new_publishers)
    p3.publish(server, "mofumofu!")
    p4.publish(server, "nyanyan!")
    p5.publish(server, "wanwan!")

    // this message will be ignored
    p1.publish(server, "new!!")

