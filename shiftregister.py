import collections
import copy

class ShiftRegister():
    def __init__(self, size):
        self.size = size
        self.register = collections.deque([False] * size, maxlen = size)
        self.buffer = collections.deque([False] * size, maxlen = size)
        self.registerchangedsinceprint = True
        self.data_val = False
        self.clock_val = False
        self.latch_val = True
        self.lastdata = False
        self.lastclock = False
        self.lastlatch = True


    def data(self, value):
        if value is not self.lastdata:
            self.data_val = value
            # if value:
            #     print ("data high")
            # else:
            #     print ("data low")

        self.lastdata = value


    def clock(self, value):
        if value is not self.lastclock: # only if clock signal has changed
            self.clock_val = value
            if value: # clock went high
                # print ("clock high")
                if not self.latch_val: # latch is low so allow writes in
                    self.buffer.popleft()
                    self.buffer.append(self.data_val)
            # else:
            #     print ("clock low")

        self.lastclock = value


    def latch(self, value):
        if value is not self.lastlatch:
            self.latch_val = value
            if value:
                # print ("latch high; buffer to register")
                self.register = copy.deepcopy(self.buffer) # latch went high so update actual output
                self.registerchangedsinceprint = True
            # else:
            #     print ("latch low")

        self.lastlatch = value


    def getregister(self):
        return list(self.register)
    

    def getbuffer(self):
        return list(self.buffer)
    

    def bit(self, val, bit):
        return (val >> bit) & 1
    

    def printregister(self):
        if self.registerchangedsinceprint:
            ct = 0
            for i in self.register:
                print ("*" if i else "-", end='')
                ct += 1
                if ct % 8 == 0:
                    print ()
            print ()
            self.registerchangedsinceprint = False


    def printbuffer(self):
        for i in self.buffer:
            print ("*" if i else "-", end='')
        print ()

    


if __name__ == "__main__":
    sr = ShiftRegister(8)

    sr.latch(False)

    for i in range(0, 2):

        sr.data(True)
        sr.clock(True)
        sr.clock(False)
        sr.clock(True)
        sr.clock(False)


        sr.data(False)
        sr.clock(True)
        sr.clock(False)
        sr.clock(True)
        sr.clock(False)


    sr.latch(True)

    # for i in range(0, 8):

    #     sr.data(True)
    #     sr.clock(True)
    #     sr.clock(False)

    print (sr.getregister())