for i in range(0, 0x10FFFE):
    try:
        string = ""
        string += chr(i)

        if not string.isprintable():
            continue
        print(f"{string.encode('utf-8').hex().upper()}={string}")
    except Exception as e:
        print(e)
        pass