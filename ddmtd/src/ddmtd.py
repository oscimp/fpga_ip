from amaranth import Cat, ClockDomain, ClockSignal, DomainRenamer, Instance, Module, ResetSignal, Signal
from amaranth.lib.wiring import Component, In, Out

from src.deglitcher import Deglitcher
from src.fast_counter import FastCounter

class DDMTD(Component):
    def __init__(self, word_size=32):
        super().__init__({
            'clk_a': In(1),
            'clk_b': In(1),
            'phase': Out(word_size),
            'new_phase': Out(1),
            })
        self.word_size = word_size

    def elaborate(self, platform):
        m = Module()

        mult_a = Signal()
        m.submodules.ffa = Instance(
                'FDRE',
                i_D = self.clk_a,
                i_C = ClockSignal('sync'),
                o_Q = mult_a,
                i_CE = 1,
                i_R = 0,
                )
        mult_b = Signal()
        m.submodules.ffb = Instance(
                'FDRE',
                i_D = self.clk_b,
                i_C = ClockSignal('sync'),
                o_Q = mult_b,
                i_CE = 1,
                i_R = 0,
                )

        m.submodules.deglitch_a = deglitch_a = Deglitcher()
        m.d.comb += deglitch_a.sig_in.eq(mult_a)
        m.submodules.deglitch_b = deglitch_b = Deglitcher()
        m.d.comb += deglitch_b.sig_in.eq(mult_b)

        cnt = Signal(self.word_size)
        m.d.sync += cnt.eq(cnt + 1)

        ta = Signal.like(deglitch_a.median)
        t = Signal.like(cnt)

        with m.If(deglitch_a.begin_glitches):
            m.d.sync += cnt.eq(0)
        with m.If(deglitch_a.end_glitches):
            m.d.sync += ta.eq(deglitch_a.median)
        with m.If(deglitch_b.begin_glitches):
            m.d.sync += t.eq(cnt)
        with m.If(deglitch_b.end_glitches):
            m.d.sync += self.phase.eq(t - ta + deglitch_b.median)
            m.d.sync += self.new_phase.eq(True)
        with m.If(self.new_phase):
            m.d.sync += self.new_phase.eq(False)

        return m
