from math import ceil
from amaranth import Module, Signal
from amaranth.lib.wiring import Component, In, Out
from amaranth.sim import Simulator, SimulatorContext


class FastCounter(Component):
    def __init__(self, size, chunk_size:int = 4):
        super().__init__({
            'reg': Out(size),
            'inc': In(1),
            'rst': In(1),
            })
        self.size = size
        self.chunk_size = chunk_size

    def elaborate(self, platform):
        m = Module()

        ith_chunk_overflow = Signal(self.size//self.chunk_size, reset_less=True)

        with m.If(self.inc):
            for i in range(len(ith_chunk_overflow) + 1):
                with m.If(ith_chunk_overflow[:i].all()):
                    chunk = self.reg[i*self.chunk_size:(i+1)*self.chunk_size]
                    m.d.sync += chunk.eq(chunk + 1)
                    if i < len(ith_chunk_overflow): # not the last chunk
                        m.d.sync += ith_chunk_overflow[i].eq(chunk == 2**self.chunk_size - 2) # set overflow flag

        with m.If(self.rst):
            m.d.sync += self.reg.eq(0)
            m.d.sync += ith_chunk_overflow.eq(0)

        return m

if __name__ == '__main__':
    size = 8
    timer = FastCounter(size, 3)
    sim = Simulator(timer)
    async def test_timer(ctx: SimulatorContext):
        ctx.set(timer.inc, True)
        for _ in range(5):
            ctx.set(timer.rst, True)
            await ctx.tick()
            ctx.set(timer.rst, False)
            for i in range(2**size):
                assert ctx.get(timer.reg) == i
                await ctx.tick()

    sim.add_testbench(test_timer)
    sim.add_clock(1)
    with sim.write_vcd('test_fast_counter.vcd'):
        sim.run()
