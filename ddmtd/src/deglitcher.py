from amaranth import Cat, Module, Signal
from amaranth.lib.wiring import Component, In, Out

from src.fast_counter import FastCounter


class Deglitcher(Component):
    def __init__(self,
                 counter_size = 8,
                 buf_metastablilities=2,
                 stable_threshold=100):
        super().__init__({
            'sig_in': In(1),
            'begin_glitches': Out(1),
            'median': Out(counter_size),
            'end_glitches': Out(1),
            })
        self.counter_size = counter_size
        self.buf_metastablilities = buf_metastablilities
        self.stable_threshold = stable_threshold

    def elaborate(self, platform):
        m = Module()

        buf = Signal(self.buf_metastablilities, reset_less=True)
        m.d.sync += buf.eq(Cat(buf[1:], self.sig_in))

        shift_reg = Signal(self.stable_threshold, reset_less=True)
        m.d.sync += shift_reg.eq(Cat(shift_reg[1:], buf[0]))

        m.submodules.cnt = cnt = FastCounter(self.counter_size)

        m.d.comb += self.median.eq(cnt.reg)

        with m.FSM(reset='wait_stable_zero'):
            with m.State('wait_stable_zero'):
                with m.If(~shift_reg.any()):
                    m.next = 'wait_edge'
            with m.State('wait_edge'):
                with m.If(buf[0]):
                    m.d.comb += cnt.rst.eq(True)
                    m.d.comb += self.begin_glitches.eq(True)
                    m.next = 'got_edge'
            with m.State('got_edge'):
                with m.If(~buf[0]):
                    m.d.comb += cnt.inc.eq(True)
                with m.If(shift_reg.all()):
                    m.d.comb += self.end_glitches.eq(True)
                    m.next = 'wait_stable_zero'
        return m
